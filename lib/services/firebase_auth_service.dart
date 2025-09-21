import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import 'storage_service.dart';
import 'session_service.dart';

class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final StorageService _storageService = StorageService();
  final SessionService _sessionService = SessionService();

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final idToken = await userCredential.user?.getIdToken();
      
      if (idToken != null) {
        final result = await _authenticateWithBackend(idToken);
        if (result != null) {
          await _handleSuccessfulAuth(result);
        }
        return result;
      }
      return null;
    } catch (e) {
      debugPrint('Google sign in error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> _authenticateWithBackend(String idToken) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.googleAuthEndpoint}'),
        headers: ApiConfig.headers,
        body: jsonEncode({'idToken': idToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await storeToken(data['token']);
        return data;
      }
      return null;
    } catch (e) {
      debugPrint('Backend auth error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.profileEndpoint}'),
        headers: ApiConfig.authHeaders(token),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Get profile error: $e');
      return null;
    }
  }

  Future<String?> refreshToken() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.refreshTokenEndpoint}'),
        headers: ApiConfig.authHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await storeToken(data['token']);
        return data['token'];
      }
      return null;
    } catch (e) {
      debugPrint('Refresh token error: $e');
      return null;
    }
  }

  Future<void> _handleSuccessfulAuth(Map<String, dynamic> authResult) async {
    if (authResult.containsKey('token')) {
      await _storageService.storeUserToken(authResult['token']);
    }
    
    if (authResult.containsKey('user')) {
      await _storageService.storeUserProfile(authResult['user']);
    }
    
    // Migrate guest session data
    if (authResult.containsKey('token')) {
      await _sessionService.migrateGuestSession(authResult['token']);
    }
    
    // Sync user data with server
    await _syncUserDataWithServer();
  }

  Future<void> _syncUserDataWithServer() async {
    try {
      final token = await getToken();
      if (token == null) return;
      
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/v1/user/data'),
        headers: ApiConfig.authHeaders(token),
      );
      
      if (response.statusCode == 200) {
        final serverData = jsonDecode(response.body);
        await _storageService.syncUserData(serverData, 'profile');
      }
    } catch (e) {
      print('Sync error: $e');
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    await _storageService.clearAllUserData();
    await _sessionService.clearSession();
  }

  Future<void> storeToken(String token) async {
    await _storageService.storeUserToken(token);
  }

  Future<String?> getToken() async {
    return await _storageService.getUserToken();
  }

  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && _auth.currentUser != null;
  }
}