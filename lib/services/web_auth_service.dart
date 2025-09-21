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
    print('Initializing WebAuthService...');
    
    // Set up auth state listener
    _auth.authStateChanges().listen((user) async {
      print('Auth state changed: ${user?.email ?? 'null'}');
      _userController.add(user);
      
      // Store/clear ID token when auth state changes
      if (user != null) {
        await _storeIdToken(user);
        
        // Try to validate with backend, but don't fail auth if this fails
        try {
          await _userDataService.storeAndValidateUser(user);
        } catch (e) {
          print('Backend validation failed during auth state change: $e');
        }
      } else {
        await _clearIdToken();
      }
    });
    
    // Check for existing authentication and auto-login
    await _checkExistingAuth();
    print('WebAuthService initialization complete');
  }

  /// Check for existing authentication and attempt auto-login
  Future<void> _checkExistingAuth() async {
    try {
      // Check if Firebase has a persisted user
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        print('Firebase user found, validating with backend...');
        await _userDataService.storeAndValidateUser(currentUser);
        return;
      }
      
      // Check for stored ID token
      final storedToken = html.window.localStorage[_idTokenKey];
      if (storedToken != null) {
        print('Stored ID token found, attempting to restore session...');
        // Firebase should automatically restore the user if the token is valid
        // The authStateChanges listener will handle the rest
      }
    } catch (e) {
      print('Error checking existing auth: $e');
      await _clearIdToken();
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      print('Starting Google sign-in process...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('Google sign-in cancelled by user');
        return null;
      }

      print('Getting Google authentication credentials...');
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('Signing in with Firebase...');
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        print('Firebase sign-in successful for user: ${userCredential.user!.email}');
        
        // Store ID token immediately
        await _storeIdToken(userCredential.user!);
        
        // Attempt backend validation but don't fail if it doesn't work
        try {
          final success = await _userDataService.storeAndValidateUser(userCredential.user!);
          if (success) {
            print('User successfully validated with backend');
          } else {
            print('Backend validation failed, but Firebase auth succeeded - user can still use the app');
          }
        } catch (e) {
          print('Backend validation error (non-fatal): $e');
          // Continue with authentication even if backend validation fails
        }
        
        // Manually trigger auth state change to ensure UI updates
        _userController.add(userCredential.user);
        
        return userCredential.user;
      }
      
      return null;
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
    try {
      // Try to get from backend first
      final backendProfile = await _userDataService.getUserProfile();
      if (backendProfile != null) {
        return backendProfile;
      }
      
      // Fallback to Firebase user data if backend fails
      final user = _auth.currentUser;
      if (user != null) {
        return {
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          'emailVerified': user.emailVerified,
          'lastSignInTime': user.metadata.lastSignInTime?.toIso8601String(),
        };
      }
      
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  /// Check if user is authenticated (either with backend or Firebase)
  Future<bool> isAuthenticated() async {
    try {
      // Check backend authentication first
      final backendAuth = await _userDataService.isAuthenticated();
      if (backendAuth) return true;
      
      // Fallback to Firebase authentication
      final user = _auth.currentUser;
      return user != null;
    } catch (e) {
      print('Error checking authentication: $e');
      return false;
    }
  }

  void dispose() {
    _userController.close();
  }
}