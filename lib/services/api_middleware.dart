import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Production-ready API middleware for trip planner app
/// Handles authentication, guest sessions, token refresh, and unified error handling
class ApiMiddleware {
  static const String _baseUrl = String.fromEnvironment(
    'BACKEND_API_URL',
    defaultValue: 'https://synapse-backend-80902795823.asia-south2.run.app',
  );
  static const String _tokenKey = 'auth_token';
  static const String _sessionIdKey = 'session_id';
  static const String _deviceIdKey = 'device_id';
  
  static String? _cachedToken;
  static String? _cachedSessionId;
  static String? _cachedDeviceId;
  static bool _isRefreshing = false;

  /// Unified API response structure
  static Map<String, dynamic> _createResponse({
    required bool success,
    dynamic data,
    String? error,
    required int statusCode,
  }) {
    return {
      'success': success,
      'data': data,
      'error': error,
      'statusCode': statusCode,
    };
  }

  /// Get stored auth token
  static Future<String?> _getToken() async {
    if (_cachedToken != null) return _cachedToken;
    final prefs = await SharedPreferences.getInstance();
    _cachedToken = prefs.getString(_tokenKey);
    return _cachedToken;
  }

  /// Store auth token
  static Future<void> _setToken(String token) async {
    _cachedToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Clear auth token (logout or token expired)
  static Future<void> _clearToken() async {
    _cachedToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  /// Get or create device ID for guest sessions
  static Future<String> _getDeviceId() async {
    if (_cachedDeviceId != null) return _cachedDeviceId!;
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(_deviceIdKey);
    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await prefs.setString(_deviceIdKey, deviceId);
    }
    _cachedDeviceId = deviceId;
    return deviceId;
  }

  /// Get stored session ID
  static Future<String?> _getSessionId() async {
    if (_cachedSessionId != null) return _cachedSessionId;
    final prefs = await SharedPreferences.getInstance();
    _cachedSessionId = prefs.getString(_sessionIdKey);
    return _cachedSessionId;
  }

  /// Store session ID
  static Future<void> _setSessionId(String sessionId) async {
    _cachedSessionId = sessionId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionIdKey, sessionId);
  }

  /// Create new guest session
  static Future<String?> _createGuestSession() async {
    try {
      final deviceId = await _getDeviceId();
      final response = await http.post(
        Uri.parse('$_baseUrl/api/v1/session'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'type': 'guest', 'deviceId': deviceId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final sessionId = data['sessionId'] as String?;
        if (sessionId != null) {
          await _setSessionId(sessionId);
          return sessionId;
        }
      }
    } catch (e) {
      // Silent fail - will be handled by caller
    }
    return null;
  }

  /// Ensure guest session exists
  static Future<String?> _ensureGuestSession() async {
    String? sessionId = await _getSessionId();
    if (sessionId == null) {
      sessionId = await _createGuestSession();
    }
    return sessionId;
  }

  /// Build headers based on auth state
  static Future<Map<String, String>> _buildHeaders({bool includeSessionHeader = true}) async {
    final headers = {'Content-Type': 'application/json'};
    
    // Mode A: Authenticated user - add Bearer token
    final token = await _getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
      return headers;
    }
    
    // Mode B: Guest user - add session ID header
    if (includeSessionHeader) {
      final sessionId = await _ensureGuestSession();
      if (sessionId != null) {
        headers['X-Session-ID'] = sessionId;
      }
    }
    
    return headers;
  }

  /// Inject session ID into request body for guest users
  static Future<Map<String, dynamic>> _injectSessionId(Map<String, dynamic> body) async {
    final token = await _getToken();
    // Only add sessionId to body if user is NOT authenticated
    if (token == null) {
      final sessionId = await _ensureGuestSession();
      if (sessionId != null) {
        body['sessionId'] = sessionId;
      }
    }
    return body;
  }

  /// Handle 401 Unauthorized - attempt token refresh or session recreation
  static Future<bool> _handle401() async {
    if (_isRefreshing) return false;
    _isRefreshing = true;

    try {
      final token = await _getToken();
      
      // If authenticated user, clear token and revert to guest mode
      if (token != null) {
        await _clearToken();
        // Recreate guest session
        final sessionId = await _createGuestSession();
        _isRefreshing = false;
        return sessionId != null;
      }
      
      // If guest session expired, recreate it
      final sessionId = await _createGuestSession();
      _isRefreshing = false;
      return sessionId != null;
    } catch (e) {
      _isRefreshing = false;
      return false;
    }
  }

  /// Core HTTP request handler with retry logic
  static Future<Map<String, dynamic>> _request(
    String method,
    String endpoint,
    {Map<String, dynamic>? body, bool isRetry = false}
  ) async {
    try {
      final url = Uri.parse('$_baseUrl$endpoint');
      final headers = await _buildHeaders();
      
      // Inject sessionId into body for POST/PUT requests (guest mode only)
      Map<String, dynamic>? requestBody = body;
      if (body != null && (method == 'POST' || method == 'PUT')) {
        requestBody = await _injectSessionId(Map.from(body));
      }

      http.Response response;
      
      switch (method) {
        case 'GET':
          response = await http.get(url, headers: headers).timeout(const Duration(seconds: 30));
          break;
        case 'POST':
          response = await http.post(url, headers: headers, body: jsonEncode(requestBody)).timeout(const Duration(seconds: 30));
          break;
        case 'PUT':
          response = await http.put(url, headers: headers, body: jsonEncode(requestBody)).timeout(const Duration(seconds: 30));
          break;
        case 'DELETE':
          response = await http.delete(url, headers: headers).timeout(const Duration(seconds: 30));
          break;
        default:
          return _createResponse(success: false, error: 'Invalid HTTP method', statusCode: 400);
      }

      // Handle 401 Unauthorized - retry once after token/session refresh
      if (response.statusCode == 401 && !isRetry) {
        final refreshed = await _handle401();
        if (refreshed) {
          // Retry request once
          return await _request(method, endpoint, body: body, isRetry: true);
        }
        return _createResponse(
          success: false,
          error: 'Session expired. Please sign in again.',
          statusCode: 401,
        );
      }

      // Success responses (2xx)
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = response.body.isNotEmpty ? jsonDecode(response.body) : null;
        return _createResponse(success: true, data: data, statusCode: response.statusCode);
      }

      // Client errors (4xx)
      if (response.statusCode >= 400 && response.statusCode < 500) {
        String errorMsg = 'Request failed';
        try {
          final errorData = jsonDecode(response.body);
          errorMsg = errorData['error'] ?? errorData['message'] ?? errorMsg;
        } catch (_) {}
        return _createResponse(success: false, error: errorMsg, statusCode: response.statusCode);
      }

      // Server errors (5xx)
      return _createResponse(
        success: false,
        error: 'Server error. Please try again later.',
        statusCode: response.statusCode,
      );

    } catch (e) {
      // Network timeout or connection errors
      return _createResponse(
        success: false,
        error: 'Network error. Please check your connection.',
        statusCode: 0,
      );
    }
  }

  /// Public API methods

  /// GET request
  static Future<Map<String, dynamic>> apiGet(String endpoint) async {
    return await _request('GET', endpoint);
  }

  /// POST request
  static Future<Map<String, dynamic>> apiPost(String endpoint, Map<String, dynamic> body) async {
    return await _request('POST', endpoint, body: body);
  }

  /// PUT request
  static Future<Map<String, dynamic>> apiPut(String endpoint, Map<String, dynamic> body) async {
    return await _request('PUT', endpoint, body: body);
  }

  /// DELETE request
  static Future<Map<String, dynamic>> apiDelete(String endpoint) async {
    return await _request('DELETE', endpoint);
  }

  /// Endpoint-specific helper methods

  /// Plan a trip
  static Future<Map<String, dynamic>> planTrip({
    required String destination,
    required String startDate,
    required String endDate,
    required int days,
    required int budget,
    required Map<String, dynamic> preferences,
    required int people,
    String? specialRequirements,
  }) async {
    final body = {
      'destination': destination,
      'startDate': startDate,
      'endDate': endDate,
      'days': days,
      'budget': budget,
      'preferences': preferences,
      'people': people,
    };

    // Attach specialRequirements as a top-level string if provided (can be empty string)
    if (specialRequirements != null) {
      body['specialRequirements'] = specialRequirements;
    }

    return await apiPost('/api/v1/plantrip', body);
  }

  /// Send chat message
  static Future<Map<String, dynamic>> sendChatMessage({
    required String message,
    String context = 'itinerary_planning',
  }) async {
    return await apiPost('/api/v1/chat', {
      'message': message,
      'context': context,
    });
  }

  /// Google authentication
  static Future<Map<String, dynamic>> authenticateWithGoogle({
    required String idToken,
    required Map<String, dynamic> userData,
  }) async {
    final response = await apiPost('/api/v1/auth/google', {
      'idToken': idToken,
      'userData': userData,
    });

    // Store token on successful login
    if (response['success'] == true && response['data']?['token'] != null) {
      await _setToken(response['data']['token']);
    }

    return response;
  }

  /// Save itinerary
  static Future<Map<String, dynamic>> saveItinerary({
    required String tripId,
    required Map<String, dynamic> itinerary,
  }) async {
    return await apiPost('/api/v1/saveItinerary', {
      'tripId': tripId,
      'itinerary': itinerary,
    });
  }

  /// Smart adjust itinerary using AI
  static Future<Map<String, dynamic>> smartAdjust({
    required Map<String, dynamic> itinerary,
    required String userRequest,
    String? adjustmentType,
  }) async {
    // Get session ID (either auth token or guest session)
    final sessionId = await _getSessionId();
    
    return await apiPost('/api/v1/smartadjust', {
      'sessionId': sessionId,
      'itinerary': itinerary,
      'userRequest': userRequest,
    });
  }

  /// Logout - clear token and create new guest session
  static Future<void> logout() async {
    await _clearToken();
    await _createGuestSession();
  }

  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final token = await _getToken();
    return token != null;
  }
}
