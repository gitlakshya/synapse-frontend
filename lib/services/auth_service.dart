import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../config.dart';
import 'api_middleware.dart';

/// Auth Service - Handles Firebase authentication and backend synchronization
/// 
/// Dual Authentication System:
/// 1. Firebase Auth for user authentication
/// 2. Backend sync via POST /api/v1/auth/google
/// 
/// The backend receives Firebase idToken and user data, validates it,
/// and returns a JWT token for API access. This token is automatically
/// stored by ApiMiddleware for subsequent API calls.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: Config.googleSignInClientId,
  );

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with Google and sync with backend
  /// 
  /// Flow:
  /// 1. Authenticate with Firebase using Google Sign-In
  /// 2. Get Firebase idToken
  /// 3. Send to backend POST /api/v1/auth/google with idToken + userData + sessionId
  /// 4. Backend validates token and returns JWT
  /// 5. ApiMiddleware stores JWT for authenticated API calls
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Step 1: Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Step 2: Firebase Authentication
      final userCredential = await _auth.signInWithCredential(credential);
      
      // Step 3: Sync with backend
      if (googleAuth.idToken != null && userCredential.user != null) {
        try {
          final user = userCredential.user!;
          await ApiMiddleware.authenticateWithGoogle(
            idToken: googleAuth.idToken!,
            userData: {
              'uid': user.uid,
              'email': user.email,
              'displayName': user.displayName,
              'photoURL': user.photoURL,
            },
          );
          // ApiMiddleware.authenticateWithGoogle automatically stores the JWT token
        } catch (e) {
          print('Backend sync failed: $e');
          // Continue with Firebase auth even if backend sync fails
        }
      }

      return userCredential;
    } catch (e) {
      throw Exception('Google sign-in failed: $e');
    }
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Sync with backend
      try {
        final idToken = await userCredential.user?.getIdToken();
        if (idToken != null) {
          await ApiMiddleware.authenticateWithGoogle(
            idToken: idToken,
            userData: {
              'uid': userCredential.user!.uid,
              'email': userCredential.user!.email,
              'displayName': userCredential.user!.displayName,
              'photoURL': userCredential.user!.photoURL,
            },
          );
        }
      } catch (e) {
        print('Backend sync failed: $e');
      }
      
      return userCredential;
    } catch (e) {
      throw Exception('Email sign-in failed: $e');
    }
  }

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Sync with backend
      try {
        final idToken = await userCredential.user?.getIdToken();
        if (idToken != null) {
          await ApiMiddleware.authenticateWithGoogle(
            idToken: idToken,
            userData: {
              'uid': userCredential.user!.uid,
              'email': userCredential.user!.email,
              'displayName': userCredential.user!.displayName,
              'photoURL': userCredential.user!.photoURL,
            },
          );
        }
      } catch (e) {
        print('Backend sync failed: $e');
      }
      
      return userCredential;
    } catch (e) {
      throw Exception('Sign-up failed: $e');
    }
  }

  /// Sign out from Firebase and backend
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
    
    // Clear backend session and create new guest session
    await ApiMiddleware.logout();
  }
}
