import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/web_auth_service.dart';
import '../services/session_service.dart';
import '../config/api_config.dart';

/// HTTP client service that automatically handles authentication headers for both
/// authenticated users (Firebase ID Token) and guest users (Session ID)
class AuthenticatedHttpClient {
  static final AuthenticatedHttpClient _instance = AuthenticatedHttpClient._internal();
  factory AuthenticatedHttpClient() => _instance;
  AuthenticatedHttpClient._internal();

  final WebAuthService _authService = WebAuthService();
  final SessionService _sessionService = SessionService();

  /// Make authenticated/guest GET request
  Future<http.Response> get(
    String url, {
    Map<String, String>? headers,
    bool includeAuth = true,
    bool forceGuest = false,
  }) async {
    final finalHeaders = await _buildHeaders(headers, includeAuth, forceGuest);
    
    try {
      final response = await http.get(Uri.parse(url), headers: finalHeaders);
      return await _handleTokenExpiry(response, () => 
        http.get(Uri.parse(url), headers: finalHeaders)
      );
    } catch (e) {
      print('GET request error: $e');
      rethrow;
    }
  }

  /// Make authenticated/guest POST request
  Future<http.Response> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
    bool includeAuth = true,
    bool forceGuest = false,
  }) async {
    final finalHeaders = await _buildHeaders(headers, includeAuth, forceGuest);
    final requestBody = await _buildBody(body, includeAuth, forceGuest);
    
    try {
      final response = await http.post(
        Uri.parse(url), 
        headers: finalHeaders,
        body: requestBody,
      );
      return await _handleTokenExpiry(response, () => 
        http.post(
          Uri.parse(url), 
          headers: finalHeaders,
          body: requestBody,
        )
      );
    } catch (e) {
      print('POST request error: $e');
      rethrow;
    }
  }

  /// Make authenticated/guest PUT request
  Future<http.Response> put(
    String url, {
    Map<String, String>? headers,
    Object? body,
    bool includeAuth = true,
    bool forceGuest = false,
  }) async {
    final finalHeaders = await _buildHeaders(headers, includeAuth, forceGuest);
    final requestBody = await _buildBody(body, includeAuth, forceGuest);
    
    try {
      final response = await http.put(
        Uri.parse(url), 
        headers: finalHeaders,
        body: requestBody,
      );
      return await _handleTokenExpiry(response, () => 
        http.put(
          Uri.parse(url), 
          headers: finalHeaders,
          body: requestBody,
        )
      );
    } catch (e) {
      print('PUT request error: $e');
      rethrow;
    }
  }

  /// Make authenticated/guest DELETE request
  Future<http.Response> delete(
    String url, {
    Map<String, String>? headers,
    bool includeAuth = true,
    bool forceGuest = false,
  }) async {
    final finalHeaders = await _buildHeaders(headers, includeAuth, forceGuest);
    
    try {
      final response = await http.delete(Uri.parse(url), headers: finalHeaders);
      return await _handleTokenExpiry(response, () => 
        http.delete(Uri.parse(url), headers: finalHeaders)
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

  /// Helper method for API requests with base URL
  Future<http.Response> apiGet(
    String endpoint, {
    Map<String, String>? headers,
    bool includeAuth = true,
    bool forceGuest = false,
  }) async {
    return get(
      '${ApiConfig.baseUrl}$endpoint',
      headers: headers,
      includeAuth: includeAuth,
      forceGuest: forceGuest,
    );
  }

  /// Helper method for API POST requests with base URL
  Future<http.Response> apiPost(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    bool includeAuth = true,
    bool forceGuest = false,
  }) async {
    return post(
      '${ApiConfig.baseUrl}$endpoint',
      headers: headers,
      body: body,
      includeAuth: includeAuth,
      forceGuest: forceGuest,
    );
  }

  /// Helper method for API PUT requests with base URL
  Future<http.Response> apiPut(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    bool includeAuth = true,
    bool forceGuest = false,
  }) async {
    return put(
      '${ApiConfig.baseUrl}$endpoint',
      headers: headers,
      body: body,
      includeAuth: includeAuth,
      forceGuest: forceGuest,
    );
  }

  /// Helper method for API DELETE requests with base URL
  Future<http.Response> apiDelete(
    String endpoint, {
    Map<String, String>? headers,
    bool includeAuth = true,
    bool forceGuest = false,
  }) async {
    return delete(
      '${ApiConfig.baseUrl}$endpoint',
      headers: headers,
      includeAuth: includeAuth,
      forceGuest: forceGuest,
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