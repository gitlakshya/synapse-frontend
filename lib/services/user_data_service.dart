import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user_models.dart';
import 'firebase_auth_service.dart';
import 'storage_service.dart';
import 'session_service.dart';
import '../config/api_config.dart';
import 'package:http/http.dart' as http;

/// Enhanced service for managing user data with backend validation
class UserDataService {
  static final UserDataService _instance = UserDataService._internal();
  factory UserDataService() => _instance;
  UserDataService._internal();

  final FirebaseAuthService _authService = FirebaseAuthService();
  final StorageService _storageService = StorageService();
  final SessionService _sessionService = SessionService();

  /// Store user details and validate with backend
  Future<bool> storeAndValidateUser(firebase_auth.User firebaseUser) async {
    try {
      // 1. Extract user data from Firebase User
      final userData = {
        'uid': firebaseUser.uid,
        'email': firebaseUser.email,
        'displayName': firebaseUser.displayName,
        'photoURL': firebaseUser.photoURL,
        'emailVerified': firebaseUser.emailVerified,
        'phoneNumber': firebaseUser.phoneNumber,
        'providerData': firebaseUser.providerData.map((p) => {
          'providerId': p.providerId,
          'uid': p.uid,
          'email': p.email,
          'displayName': p.displayName,
          'photoURL': p.photoURL,
        }).toList(),
        'metadata': {
          'creationTime': firebaseUser.metadata.creationTime?.toIso8601String(),
          'lastSignInTime': firebaseUser.metadata.lastSignInTime?.toIso8601String(),
        },
        'timestamp': DateTime.now().toIso8601String(),
      };

      // 2. Get Firebase ID Token for backend validation
      final idToken = await firebaseUser.getIdToken();
      if (idToken == null) {
        throw Exception('Failed to get Firebase ID token');
      }
      
      // 3. Send to backend for validation and user creation/update
      final backendResult = await _validateWithBackend(idToken, userData);
      
      if (backendResult != null) {
        // 4. Store validated user data locally
        await _storeUserDataLocally(userData, backendResult);
        
        // 5. Migrate any guest session data
        await _migrateGuestData(backendResult['token']);
        
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error storing and validating user: $e');
      return false;
    }
  }

  /// Validate user with backend and get app-specific data
  Future<Map<String, dynamic>?> _validateWithBackend(String idToken, Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.googleAuthEndpoint}'),
        headers: ApiConfig.headers,
        body: jsonEncode({
          'idToken': idToken,
          'userData': userData,
          'platform': 'web',
          'appVersion': '1.0.0',
          'sessionId': _sessionService.guestSessionId,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData;
      } else {
        print('Backend validation failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Backend validation error: $e');
      return null;
    }
  }

  /// Store user data locally after backend validation
  Future<void> _storeUserDataLocally(Map<String, dynamic> userData, Map<String, dynamic> backendData) async {
    try {
      // Store authentication token
      if (backendData.containsKey('token')) {
        await _storageService.storeUserToken(backendData['token']);
      }

      // Store user profile data
      if (backendData.containsKey('userProfile')) {
        await _storageService.storeUserProfile(backendData['userProfile']);
      }

      // Store Firebase user data
      await _storageService.storeUserData('main', {
        'firebaseUser': userData,
        'backendUser': backendData,
        'lastSync': DateTime.now().toIso8601String(),
      });

      // Store user preferences if provided (as part of user data)
      if (backendData.containsKey('preferences')) {
        await _storageService.storeUserData('preferences', backendData['preferences']);
      }

    } catch (e) {
      print('Error storing user data locally: $e');
    }
  }

  /// Migrate guest session data to authenticated user
  Future<void> _migrateGuestData(String authToken) async {
    try {
      await _sessionService.migrateGuestSession(authToken);
    } catch (e) {
      print('Error migrating guest data: $e');
    }
  }

  /// Get stored user data for API requests
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await _storageService.getUserToken();
    final headers = Map<String, String>.from(ApiConfig.headers);
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  /// Get user profile for UI display
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final profileData = await _storageService.getUserProfile();
      return profileData;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  /// Update user profile both locally and on backend
  Future<bool> updateUserProfile(Map<String, dynamic> profileData) async {
    try {
      final token = await _storageService.getUserToken();
      if (token == null) return false;

      // Update on backend
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.profileEndpoint}'),
        headers: await getAuthHeaders(),
        body: jsonEncode(profileData),
      );

      if (response.statusCode == 200) {
        // Update locally
        await _storageService.storeUserProfile(profileData);
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  /// Get user data for API requests (includes session info)
  Future<Map<String, dynamic>> getApiRequestData() async {
    final Map<String, dynamic> requestData = {};
    
    // Add authentication if available
    final token = await _storageService.getUserToken();
    if (token != null) {
      requestData['authenticated'] = true;
      // Token will be in headers, not body
    } else {
      // Add guest session info
      final sessionId = _sessionService.guestSessionId;
      if (sessionId != null) {
        requestData['sessionId'] = sessionId;
        requestData['authenticated'] = false;
      }
    }
    
    return requestData;
  }

  /// Clear all user data on sign out
  Future<void> clearUserData() async {
    await _storageService.clearAllUserData();
    await _sessionService.clearSession();
  }

  /// Check if user is properly authenticated with backend
  Future<bool> isAuthenticated() async {
    final token = await _storageService.getUserToken();
    final firebaseUser = _authService.currentUser;
    
    return token != null && firebaseUser != null;
  }

  /// Sync user data with backend (call periodically)
  Future<void> syncWithBackend() async {
    try {
      if (!await isAuthenticated()) return;
      
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.profileEndpoint}'),
        headers: await getAuthHeaders(),
      );
      
      if (response.statusCode == 200) {
        final serverData = jsonDecode(response.body);
        await _storeUserDataLocally({}, serverData);
      }
    } catch (e) {
      print('Sync with backend failed: $e');
    }
  }
}