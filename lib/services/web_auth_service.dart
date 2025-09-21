import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import 'dart:html' as html;
import '../config/env_config.dart';
import 'user_data_service.dart';

class WebAuthService {
  static final WebAuthService _instance = WebAuthService._internal();
  factory WebAuthService() => _instance;
  WebAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: EnvConfig.googleClientId,
  );
  final UserDataService _userDataService = UserDataService();
  
  // ID token key for localStorage
  static const String _idTokenKey = 'firebase_id_token';

  final StreamController<User?> _userController = StreamController<User?>.broadcast();
  
  Stream<User?> get userStream => _userController.stream;
  User? get currentUser => _auth.currentUser;

  Future<void> initialize() async {
    _auth.authStateChanges().listen((user) async {
      _userController.add(user);
      
      // Store/clear ID token when auth state changes
      if (user != null) {
        await _storeIdToken(user);
        await _userDataService.storeAndValidateUser(user);
      } else {
        await _clearIdToken();
      }
    });
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // Store ID token and validate user with backend
      if (userCredential.user != null) {
        await _storeIdToken(userCredential.user!);
        
        final success = await _userDataService.storeAndValidateUser(userCredential.user!);
        if (success) {
          print('User successfully validated with backend');
        } else {
          print('Backend validation failed, but Firebase auth succeeded');
        }
      }
      
      return userCredential.user;
    } catch (e) {
      print('Google sign in error: $e');
      return null;
    }
  }

  /// Store Firebase ID Token in localStorage
  Future<void> _storeIdToken(User user) async {
    try {
      final idToken = await user.getIdToken();
      if (idToken != null) {
        html.window.localStorage[_idTokenKey] = idToken;
        print('ID Token stored successfully');
      }
    } catch (e) {
      print('Error storing ID token: $e');
    }
  }

  /// Clear ID Token from localStorage
  Future<void> _clearIdToken() async {
    try {
      html.window.localStorage.remove(_idTokenKey);
      print('ID Token cleared');
    } catch (e) {
      print('Error clearing ID token: $e');
    }
  }

  /// Get stored ID Token from localStorage
  Future<String?> getIdToken() async {
    try {
      return html.window.localStorage[_idTokenKey];
    } catch (e) {
      print('Error reading ID token: $e');
      return null;
    }
  }

  /// Refresh and store new ID Token
  Future<String?> refreshIdToken() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final idToken = await user.getIdToken(true); // Force refresh
        if (idToken != null) {
          html.window.localStorage[_idTokenKey] = idToken;
          return idToken;
        }
      }
      return null;
    } catch (e) {
      print('Error refreshing ID token: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    await _clearIdToken();
    await _userDataService.clearUserData();
  }

  /// Get authentication headers for API requests
  Future<Map<String, String>> getAuthHeaders() async {
    final idToken = await getIdToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (idToken != null) {
      headers['Authorization'] = 'Bearer $idToken';
    }
    
    return headers;
  }

  /// Get user profile data
  Future<Map<String, dynamic>?> getUserProfile() async {
    return await _userDataService.getUserProfile();
  }

  /// Check if user is authenticated with backend
  Future<bool> isAuthenticated() async {
    return await _userDataService.isAuthenticated();
  }

  void dispose() {
    _userController.close();
  }
}