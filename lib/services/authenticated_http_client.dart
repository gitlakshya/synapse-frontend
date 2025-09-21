import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import '../services/web_auth_service.dart';
import '../services/session_service.dart';
import '../config/api_config.dart';

/// HTTP client service that automatically handles authentication headers for both
/// authenticated users (Firebase ID Token) and guest users (Session ID)
class AuthenticatedHttpClient {
  static final AuthenticatedHttpClient _instance = AuthenticatedHttpClient._internal();
  factory AuthenticatedHttpClient() => _instance;
  AuthenticatedHttpClient._internal();

  // Timeout configurations for different operations
  static const Duration _defaultTimeout = Duration(seconds: 120);
  static const Duration _planTripTimeout = Duration(seconds: 120); // 120 seconds for trip planning
  static const Duration _smartAdjustTimeout = Duration(seconds: 120); // 120 seconds for smart adjust
  static const Duration _chatTimeout = Duration(seconds: 120); // 120 seconds for chat

  final WebAuthService _authService = WebAuthService();
  final SessionService _sessionService = SessionService();
  
  // Map to store active requests for cancellation
  final Map<String, Completer<http.Response>> _activeRequests = {};

  /// Make authenticated/guest GET request
  Future<http.Response> get(
    String url, {
    Map<String, String>? headers,
    bool includeAuth = true,
    bool forceGuest = false,
    Duration? timeout,
  }) async {
    final finalHeaders = await _buildHeaders(headers, includeAuth, forceGuest);
    final requestTimeout = timeout ?? _defaultTimeout;
    
    try {
      final response = await http.get(Uri.parse(url), headers: finalHeaders)
          .timeout(requestTimeout);
      return await _handleTokenExpiry(response, () => 
        http.get(Uri.parse(url), headers: finalHeaders).timeout(requestTimeout)
      );
    } catch (e) {
      print('GET request error: $e');
      rethrow;
    }
  }

  /// Make authenticated/guest POST request with cancellation support
  Future<http.Response> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
    bool includeAuth = true,
    bool forceGuest = false,
    Duration? timeout,
    String? requestId,
  }) async {
    final finalHeaders = await _buildHeaders(headers, includeAuth, forceGuest);
    final requestBody = await _buildBody(body, includeAuth, forceGuest);
    final requestTimeout = timeout ?? _getTimeoutForUrl(url);
    
    // Generate request ID if not provided
    final id = requestId ?? DateTime.now().millisecondsSinceEpoch.toString();
    
    try {
      // Create a completer for this request
      final completer = Completer<http.Response>();
      _activeRequests[id] = completer;
      
      // Start the actual HTTP request
      final httpRequest = http.post(
        Uri.parse(url), 
        headers: finalHeaders,
        body: requestBody,
      );
      
      // Set up timeout and cancellation
      Timer? timeoutTimer;
      timeoutTimer = Timer(requestTimeout, () {
        if (!completer.isCompleted) {
          _activeRequests.remove(id);
          completer.completeError(TimeoutException('Request timed out after ${requestTimeout.inSeconds} seconds', requestTimeout));
          timeoutTimer?.cancel();
        }
      });
      
      // Execute the request
      httpRequest.then((response) {
        timeoutTimer?.cancel();
        if (!completer.isCompleted) {
          _activeRequests.remove(id);
          completer.complete(response);
        }
      }).catchError((error) {
        timeoutTimer?.cancel();
        if (!completer.isCompleted) {
          _activeRequests.remove(id);
          completer.completeError(error);
        }
      });
      
      final response = await completer.future;
      return await _handleTokenExpiry(response, () => 
        post(url, headers: headers, body: body, includeAuth: includeAuth, forceGuest: forceGuest, timeout: timeout)
      );
    } catch (e) {
      _activeRequests.remove(id);
      if (e is TimeoutException) {
        print('POST request timed out: $url after ${requestTimeout.inSeconds} seconds');
        throw TimeoutException('Server did not respond within ${requestTimeout.inSeconds} seconds. Please try again.', requestTimeout);
      }
      print('POST request error: $e');
      rethrow;
    }
  }

  /// Make authenticated/guest PUT request
  Future<http.Response> putRequest(
    String url, {
    Map<String, String>? headers,
    Object? body,
    bool includeAuth = true,
    bool forceGuest = false,
    Duration? timeout,
  }) async {
    final finalHeaders = await _buildHeaders(headers, includeAuth, forceGuest);
    final requestBody = await _buildBody(body, includeAuth, forceGuest);
    final requestTimeout = timeout ?? _defaultTimeout;
    
    try {
      final response = await http.put(
        Uri.parse(url), 
        headers: finalHeaders,
        body: requestBody,
      ).timeout(requestTimeout);
      return await _handleTokenExpiry(response, () => 
        http.put(
          Uri.parse(url), 
          headers: finalHeaders,
          body: requestBody,
        ).timeout(requestTimeout)
      );
    } catch (e) {
      print('PUT request error: $e');
      rethrow;
    }
  }

  /// Make authenticated/guest DELETE request
  Future<http.Response> deleteRequest(
    String url, {
    Map<String, String>? headers,
    bool includeAuth = true,
    bool forceGuest = false,
    Duration? timeout,
  }) async {
    final finalHeaders = await _buildHeaders(headers, includeAuth, forceGuest);
    final requestTimeout = timeout ?? _defaultTimeout;
    
    try {
      final response = await http.delete(Uri.parse(url), headers: finalHeaders)
          .timeout(requestTimeout);
      return await _handleTokenExpiry(response, () => 
        http.delete(Uri.parse(url), headers: finalHeaders).timeout(requestTimeout)
      );
    } catch (e) {
      print('DELETE request error: $e');
      rethrow;
    }
  }

  /// Build headers with authentication (Firebase ID Token) or guest session
  Future<Map<String, String>> _buildHeaders(
    Map<String, String>? customHeaders, 
    bool includeAuth,
    bool forceGuest,
  ) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add custom headers
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    // Handle authentication/session
    if (includeAuth && !forceGuest) {
      // Check if user is authenticated
      final idToken = await _authService.getIdToken();
      
      if (idToken != null) {
        // User is authenticated - use Firebase ID Token
        headers['Authorization'] = 'Bearer $idToken';
        print('Using authenticated request with Firebase ID Token');
      } else {
        // User is not authenticated - use guest session
        await _addGuestSession(headers);
      }
    } else if (forceGuest) {
      // Force guest session even if user is authenticated
      await _addGuestSession(headers);
    }

    return headers;
  }

  /// Add guest session information to headers
  Future<void> _addGuestSession(Map<String, String> headers) async {
    final sessionId = _sessionService.guestSessionId;
    
    if (sessionId != null) {
      headers['X-Session-ID'] = sessionId;
      print('Using guest session: $sessionId');
    } else {
      // Ensure valid session exists (only creates if no auth token and no valid session)
      final newSessionId = await _sessionService.ensureValidSession();
      if (newSessionId != null) {
        headers['X-Session-ID'] = newSessionId;
        print('Using session: $newSessionId');
      }
    }
  }

  /// Build request body, adding session info for guest users
  Future<String> _buildBody(Object? body, bool includeAuth, bool forceGuest) async {
    Map<String, dynamic> requestData = {};
    
    // Parse existing body
    if (body != null) {
      if (body is Map<String, dynamic>) {
        requestData = Map<String, dynamic>.from(body);
      } else if (body is String) {
        try {
          requestData = jsonDecode(body);
        } catch (e) {
          return body; // Return as-is if not JSON
        }
      } else {
        return jsonEncode(body); // Return encoded if other type
      }
    }

    // Add session context for guest users
    if (includeAuth && !forceGuest) {
      final idToken = await _authService.getIdToken();
      
      if (idToken == null) {
        // Guest user - add session info to body
        await _addGuestSessionToBody(requestData);
      }
      // Authenticated users don't need session info in body (it's in headers)
    } else if (forceGuest) {
      // Force guest session info in body
      await _addGuestSessionToBody(requestData);
    }

    return jsonEncode(requestData);
  }

  /// Add guest session information to request body
  Future<void> _addGuestSessionToBody(Map<String, dynamic> requestData) async {
    final sessionId = _sessionService.guestSessionId;
    
    if (sessionId != null) {
      requestData['sessionId'] = sessionId;
      requestData['authenticated'] = false;
    } else {
      // Ensure valid session exists (only creates if no auth token and no valid session)
      final newSessionId = await _sessionService.ensureValidSession();
      if (newSessionId != null) {
        requestData['sessionId'] = newSessionId;
        requestData['authenticated'] = false;
      }
    }
  }

  /// Handle token expiry and retry with refreshed token
  Future<http.Response> _handleTokenExpiry(
    http.Response response,
    Future<http.Response> Function() retryRequest,
  ) async {
    // If token expired (401), try to refresh and retry
    if (response.statusCode == 401) {
      try {
        print('Token expired, attempting to refresh...');
        final newToken = await _authService.refreshIdToken();
        
        if (newToken != null) {
          print('Token refreshed successfully, retrying request...');
          return await retryRequest();
        }
      } catch (e) {
        print('Token refresh failed: $e');
      }
    }
    
    return response;
  }

  /// Get appropriate timeout for specific URLs
  Duration _getTimeoutForUrl(String url) {
    if (url.contains('/plantrip') || url.contains('/plan-trip')) {
      return _planTripTimeout;
    } else if (url.contains('/smartadjust') || url.contains('/smart-adjust')) {
      return _smartAdjustTimeout;
    } else if (url.contains('/chat')) {
      return _chatTimeout;
    }
    return _defaultTimeout;
  }

  /// Helper method for API requests with base URL
  Future<http.Response> apiGet(
    String endpoint, {
    Map<String, String>? headers,
    bool includeAuth = true,
    bool forceGuest = false,
    Duration? timeout,
  }) async {
    return get(
      '${ApiConfig.baseUrl}$endpoint',
      headers: headers,
      includeAuth: includeAuth,
      forceGuest: forceGuest,
      timeout: timeout,
    );
  }

  /// Helper method for API POST requests with base URL and cancellation support
  Future<http.Response> apiPost(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    bool includeAuth = true,
    bool forceGuest = false,
    Duration? timeout,
    String? requestId,
  }) async {
    return post(
      '${ApiConfig.baseUrl}$endpoint',
      headers: headers,
      body: body,
      includeAuth: includeAuth,
      forceGuest: forceGuest,
      timeout: timeout,
      requestId: requestId,
    );
  }

  /// Cancel a specific request by ID
  void cancelRequest(String requestId) {
    final completer = _activeRequests[requestId];
    if (completer != null && !completer.isCompleted) {
      _activeRequests.remove(requestId);
      completer.completeError(const SocketException('Request cancelled by user'));
    }
  }

  /// Cancel all active requests
  void cancelAllRequests() {
    final requestIds = List<String>.from(_activeRequests.keys);
    for (final id in requestIds) {
      cancelRequest(id);
    }
  }

  /// Get count of active requests
  int get activeRequestCount => _activeRequests.length;

  /// Check if a specific request is active
  bool isRequestActive(String requestId) => _activeRequests.containsKey(requestId);

  /// Helper method for API PUT requests with base URL
  Future<http.Response> apiPut(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    bool includeAuth = true,
    bool forceGuest = false,
    Duration? timeout,
  }) async {
    return putRequest(
      '${ApiConfig.baseUrl}$endpoint',
      headers: headers,
      body: body,
      includeAuth: includeAuth,
      forceGuest: forceGuest,
      timeout: timeout,
    );
  }

  /// Helper method for API DELETE requests with base URL
  Future<http.Response> apiDelete(
    String endpoint, {
    Map<String, String>? headers,
    bool includeAuth = true,
    bool forceGuest = false,
    Duration? timeout,
  }) async {
    return deleteRequest(
      '${ApiConfig.baseUrl}$endpoint',
      headers: headers,
      includeAuth: includeAuth,
      forceGuest: forceGuest,
      timeout: timeout,
    );
  }

  /// Get current user/session status
  Future<Map<String, dynamic>> getRequestContext() async {
    final idToken = await _authService.getIdToken();
    
    if (idToken != null) {
      return {
        'type': 'authenticated',
        'userId': _authService.currentUser?.uid,
        'email': _authService.currentUser?.email,
      };
    } else {
      final sessionId = _sessionService.guestSessionId;
      return {
        'type': 'guest',
        'sessionId': sessionId,
      };
    }
  }

  /// Initialize guest session if needed
  Future<void> ensureGuestSession() async {
    if (_sessionService.guestSessionId == null) {
      await _sessionService.ensureValidSession();
    }
  }
}