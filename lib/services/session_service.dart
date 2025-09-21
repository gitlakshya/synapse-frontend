import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import '../config/api_config.dart';
import 'storage_service.dart';

class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  final StorageService _storageService = StorageService();
  String? _guestSessionId;
  Timer? _renewalTimer;

  Future<void> initialize() async {
    await _loadExistingSession();
    _setupSessionRenewal();
  }

  Future<void> _loadExistingSession() async {
    // Only load existing session, don't create new one automatically
    _guestSessionId = await _storageService.getSessionId();
    // Removed automatic session creation - sessions should only be created
    // when user explicitly interacts with the app (e.g., clicks "Get Started")
  }

  /// Check if a valid session exists and user is not authenticated
  /// Only creates a new session if no valid session exists and no auth token is present
  /// Properly checks session expiry and clears expired sessions
  Future<String?> ensureValidSession() async {
    try {
      // First check if user is authenticated
      if (await isAuthenticated()) {
        // User is authenticated, no need for guest session
        print('User is authenticated, no guest session needed');
        return null;
      }

      // Check for existing session with proper expiry validation
      final existingSessionId = await _storageService.getSessionId();
      if (existingSessionId != null && existingSessionId.isNotEmpty) {
        // Valid non-expired session exists, use it
        _guestSessionId = existingSessionId;
        print('Using existing valid session: $existingSessionId');
        return existingSessionId;
      }

      // No valid session or session expired (getSessionId() handles expiry and cleanup)
      print('No valid session found or session expired, creating new guest session');
      _guestSessionId = null; // Clear any stale session reference
      return await createGuestSession();
    } catch (e) {
      print('Error ensuring valid session: $e');
      // Clear any potentially corrupted session data
      _guestSessionId = null;
      await _storageService.clearSession();
      return null;
    }
  }

  Future<String?> createGuestSession() async {
    try {
      final sessionId = _storageService.generateSessionId();
      
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.sessionEndpoint}'),
        headers: ApiConfig.headers,
        body: jsonEncode({
          'type': 'guest',
          'sessionId': sessionId,
          'deviceId': await _getDeviceId(),
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _guestSessionId = data['sessionId'] ?? sessionId;
        final expireAt = data['expireAt'];
        await _storageService.storeSessionData(_guestSessionId!, expireAt);
        return _guestSessionId;
      } else {
        _guestSessionId = sessionId;
        await _storageService.storeSessionId(_guestSessionId!);
        return _guestSessionId;
      }
    } catch (e) {
      print('Create guest session error: $e');
      _guestSessionId = _storageService.generateSessionId();
      await _storageService.storeSessionId(_guestSessionId!);
      return _guestSessionId;
    }
  }

  Future<bool> migrateGuestSession(String token) async {
    if (_guestSessionId == null) return false;
    
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.sessionEndpoint}/migrate'),
        headers: ApiConfig.authHeaders(token),
        body: jsonEncode({
          'guestSessionId': _guestSessionId,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        await _storageService.clearSession();
        _guestSessionId = null;
        _cancelSessionRenewal();
        return true;
      }
      return false;
    } catch (e) {
      print('Migrate session error: $e');
      return false;
    }
  }

  Future<void> renewSession() async {
    if (_guestSessionId != null) {
      await _storageService.renewSession();
    }
  }

  void _setupSessionRenewal() {
    _renewalTimer = Timer.periodic(const Duration(hours: 4), (timer) {
      renewSession();
    });
  }

  void _cancelSessionRenewal() {
    _renewalTimer?.cancel();
    _renewalTimer = null;
  }

  Future<void> clearSession() async {
    await _storageService.clearSession();
    _guestSessionId = null;
    _cancelSessionRenewal();
  }

  /// Handle user logout - clear auth token and optionally create new guest session
  Future<void> handleUserLogout({bool createGuestSession = true}) async {
    try {
      // Clear user authentication data
      await _storageService.storeUserToken(''); // Clear token
      
      // Clear current session
      await clearSession();
      
      // Optionally create new guest session for continued browsing
      if (createGuestSession) {
        await this.createGuestSession();
      }
      
      print('User logout handled, guest session created: $createGuestSession');
    } catch (e) {
      print('Error handling logout: $e');
    }
  }

  String? get guestSessionId => _guestSessionId;

  /// Check if user is currently authenticated
  Future<bool> isAuthenticated() async {
    final authToken = await _storageService.getUserToken();
    return authToken != null && authToken.isNotEmpty;
  }

  /// Check if a valid guest session exists (includes expiry validation)
  Future<bool> hasValidGuestSession() async {
    final sessionId = await _storageService.getSessionId(); // This method handles expiry checking
    return sessionId != null && sessionId.isNotEmpty;
  }

  /// Get session expiry information for debugging
  Future<Map<String, dynamic>> getSessionInfo() async {
    try {
      final sessionId = _guestSessionId ?? await _storageService.getSessionId();
      final expiry = await _getSessionExpiry();
      final isExpired = expiry != null ? DateTime.now().isAfter(expiry) : null;
      
      return {
        'sessionId': sessionId,
        'expiry': expiry?.toIso8601String(),
        'isExpired': isExpired,
        'isAuthenticated': await isAuthenticated(),
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Helper method to get session expiry from storage
  Future<DateTime?> _getSessionExpiry() async {
    try {
      final expiryStr = await _storageService.getSessionExpiry();
      return expiryStr != null ? DateTime.parse(expiryStr) : null;
    } catch (e) {
      return null;
    }
  }

  Future<String> _getDeviceId() async {
    return 'device_${DateTime.now().millisecondsSinceEpoch}';
  }



  void dispose() {
    _cancelSessionRenewal();
  }
}