import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';

/// Web-optimized storage service that uses browser localStorage for web deployment.
/// This service is optimized for web-only deployment and doesn't require flutter_secure_storage.
/// All token and user data storage is handled via browser localStorage which is secure and persistent.
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // Session Storage Keys
  static const String _sessionIdKey = 'guest_session_id';
  static const String _sessionExpiryKey = 'session_expiry';
  
  // User Data Keys
  static const String _userTokenKey = 'user_auth_token';
  static const String _userProfileKey = 'user_profile';
  static const String _userDataKey = 'user_data';

  // Generate unique session ID
  String generateSessionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp * 1000 + (timestamp % 1000)).toString();
    return 'guest_${random}_${DateTime.now().microsecond}';
  }

  // Session Management
  Future<void> storeSessionId(String sessionId) async {
    final expiry = DateTime.now().add(const Duration(hours: 4));
    html.window.localStorage[_sessionIdKey] = sessionId;
    html.window.localStorage[_sessionExpiryKey] = expiry.toIso8601String();
    _setupSessionCleanup();
  }

  Future<void> storeSessionData(String sessionId, String? expireAt) async {
    html.window.localStorage[_sessionIdKey] = sessionId;
    if (expireAt != null) {
      html.window.localStorage[_sessionExpiryKey] = expireAt;
    } else {
      final expiry = DateTime.now().add(const Duration(hours: 4));
      html.window.localStorage[_sessionExpiryKey] = expiry.toIso8601String();
    }
    _setupSessionCleanup();
  }

  Future<String?> getSessionId() async {
    try {
      final sessionId = html.window.localStorage[_sessionIdKey];
      final expiryStr = html.window.localStorage[_sessionExpiryKey];
      
      if (sessionId == null || expiryStr == null) return null;
      
      final expiry = DateTime.parse(expiryStr);
      if (DateTime.now().isAfter(expiry)) {
        await clearSession();
        return null;
      }
      
      return sessionId;
    } catch (e) {
      return null;
    }
  }

  Future<void> renewSession() async {
    final currentSessionId = await getSessionId();
    if (currentSessionId != null) {
      await storeSessionId(currentSessionId);
    }
  }

  Future<void> clearSession() async {
    html.window.localStorage.remove(_sessionIdKey);
    html.window.localStorage.remove(_sessionExpiryKey);
  }

  /// Get session expiry time as string
  Future<String?> getSessionExpiry() async {
    try {
      return html.window.localStorage[_sessionExpiryKey];
    } catch (e) {
      return null;
    }
  }

  // User Data Management
  Future<void> storeUserToken(String token) async {
    html.window.localStorage[_userTokenKey] = token;
  }

  Future<String?> getUserToken() async {
    return html.window.localStorage[_userTokenKey];
  }

  Future<void> storeUserProfile(Map<String, dynamic> profile) async {
    final profileJson = jsonEncode(profile);
    html.window.localStorage[_userProfileKey] = profileJson;
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final profileJson = html.window.localStorage[_userProfileKey];
      if (profileJson != null) {
        return jsonDecode(profileJson) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> storeUserData(String key, Map<String, dynamic> data) async {
    try {
      final dataJson = jsonEncode(data);
      html.window.localStorage['${_userDataKey}_$key'] = dataJson;
    } catch (e) {
      print('Error storing user data: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserData(String key) async {
    try {
      final dataJson = html.window.localStorage['${_userDataKey}_$key'];
      if (dataJson != null) {
        return jsonDecode(dataJson) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Data Synchronization
  Future<void> syncUserData(Map<String, dynamic> serverData, String key) async {
    final localData = await getUserData(key);
    
    if (localData == null) {
      await storeUserData(key, serverData);
      return;
    }
    
    // Simple conflict resolution: server data wins if newer
    final serverTimestamp = DateTime.tryParse(serverData['lastModified'] ?? '');
    final localTimestamp = DateTime.tryParse(localData['lastModified'] ?? '');
    
    if (serverTimestamp != null && localTimestamp != null) {
      if (serverTimestamp.isAfter(localTimestamp)) {
        await storeUserData(key, serverData);
      }
    } else {
      await storeUserData(key, serverData);
    }
  }

  // Security & Cleanup
  Future<void> clearAllUserData() async {
    // Clear user data from localStorage
    html.window.localStorage.remove(_userTokenKey);
    html.window.localStorage.remove(_userProfileKey);
    
    // Clear all user data keys
    final keys = html.window.localStorage.keys.toList();
    for (final key in keys) {
      if (key.startsWith(_userDataKey)) {
        html.window.localStorage.remove(key);
      }
    }
  }

  Future<void> secureDelete(String key) async {
    html.window.localStorage.remove(key);
  }

  // Web-specific session cleanup on tab close
  void _setupSessionCleanup() {
    if (kIsWeb) {
      html.window.addEventListener('beforeunload', (event) {
        // Session persists in localStorage, only clear on explicit sign-out
      });
      
      html.window.addEventListener('unload', (event) {
        // Optional: Clear sensitive data on tab close
        // Uncomment if needed: clearSession();
      });
    }
  }

  // Storage quota management
  Future<bool> checkStorageQuota() async {
    if (kIsWeb) {
      try {
        // Estimate storage usage for web
        final estimate = await html.window.navigator.storage?.estimate();
        if (estimate != null) {
          final usage = estimate['usage'] as num?;
          final quota = estimate['quota'] as num?;
          if (usage != null && quota != null) {
            return (usage / quota) < 0.8; // 80% threshold
          }
        }
      } catch (e) {
        return true; // Assume OK if can't check
      }
    }
    return true; // Mobile storage is managed by OS
  }
}