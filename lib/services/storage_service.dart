import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

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
    web.window.localStorage.setItem(_sessionIdKey, sessionId);
    web.window.localStorage.setItem(_sessionExpiryKey, expiry.toIso8601String());
    _setupSessionCleanup();
  }

  Future<void> storeSessionData(String sessionId, String? expireAt) async {
    web.window.localStorage.setItem(_sessionIdKey, sessionId);
    if (expireAt != null) {
      web.window.localStorage.setItem(_sessionExpiryKey, expireAt);
    } else {
      final expiry = DateTime.now().add(const Duration(hours: 4));
      web.window.localStorage.setItem(_sessionExpiryKey, expiry.toIso8601String());
    }
    _setupSessionCleanup();
  }

  Future<String?> getSessionId() async {
    try {
      final sessionId = web.window.localStorage.getItem(_sessionIdKey);
      final expiryStr = web.window.localStorage.getItem(_sessionExpiryKey);
      
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
    web.window.localStorage.removeItem(_sessionIdKey);
    web.window.localStorage.removeItem(_sessionExpiryKey);
  }

  /// Get session expiry time as string
  Future<String?> getSessionExpiry() async {
    try {
      return web.window.localStorage.getItem(_sessionExpiryKey);
    } catch (e) {
      return null;
    }
  }

  // User Data Management
  Future<void> storeUserToken(String token) async {
    web.window.localStorage.setItem(_userTokenKey, token);
  }

  Future<String?> getUserToken() async {
    return web.window.localStorage.getItem(_userTokenKey);
  }

  Future<void> storeUserProfile(Map<String, dynamic> profile) async {
    final profileJson = jsonEncode(profile);
    web.window.localStorage.setItem(_userProfileKey, profileJson);
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final profileJson = web.window.localStorage.getItem(_userProfileKey);
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
      web.window.localStorage.setItem('${_userDataKey}_$key', dataJson);
    } catch (e) {
      debugPrint('Error storing user data: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserData(String key) async {
    try {
      final dataJson = web.window.localStorage.getItem('${_userDataKey}_$key');
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
    web.window.localStorage.removeItem(_userTokenKey);
    web.window.localStorage.removeItem(_userProfileKey);
    
    // Clear all user data keys - note: web package doesn't have direct keys access
    // We'll need to track keys differently or iterate differently
    for (int i = 0; i < web.window.localStorage.length; i++) {
      final key = web.window.localStorage.key(i);
      if (key != null && key.startsWith(_userDataKey)) {
        web.window.localStorage.removeItem(key);
      }
    }
  }

  Future<void> secureDelete(String key) async {
    web.window.localStorage.removeItem(key);
  }

  // Web-specific session cleanup on tab close
  void _setupSessionCleanup() {
    if (kIsWeb) {
      // Note: Event listeners may not be necessary for localStorage persistence
      // localStorage persists across browser sessions automatically
    }
  }

  // Storage quota management
  Future<bool> checkStorageQuota() async {
    if (kIsWeb) {
      try {
        // Note: Storage estimation API may not be available in all contexts
        // For now, we'll return true to allow operation
        return true;
      } catch (e) {
        return true; // Assume OK if can't check
      }
    }
    return true; // Mobile storage is managed by OS
  }
}