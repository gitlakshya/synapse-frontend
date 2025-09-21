import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/user_models.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? _currentUser;
  final StreamController<User?> _userController = StreamController<User?>.broadcast();
  
  Stream<User?> get userStream => _userController.stream;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Future<User?> signInWithGoogle() async {
    // Mock Google Sign In
    await Future.delayed(const Duration(seconds: 2));
    
    final user = User(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: 'user@gmail.com',
      name: 'Travel Enthusiast',
      photoUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face',
      profile: UserProfile(
        notifications: NotificationSettings(),
        travelStyle: 'balanced',
        preferredCurrency: 'INR',
        languages: ['English', 'Hindi'],
      ),
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
    
    _currentUser = user;
    _userController.add(user);
    await _saveUserLocally(user);
    return user;
  }

  Future<User?> signInWithApple() async {
    await Future.delayed(const Duration(seconds: 2));
    
    final user = User(
      id: 'apple_${DateTime.now().millisecondsSinceEpoch}',
      email: 'user@icloud.com',
      name: 'Apple User',
      photoUrl: null,
      profile: UserProfile(
        notifications: NotificationSettings(),
        travelStyle: 'luxury',
        preferredCurrency: 'INR',
      ),
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
    
    _currentUser = user;
    _userController.add(user);
    await _saveUserLocally(user);
    return user;
  }

  Future<User?> signInWithEmail(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    
    final user = User(
      id: _hashString(email),
      email: email,
      name: email.split('@')[0],
      photoUrl: null,
      profile: UserProfile(
        notifications: NotificationSettings(),
      ),
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
    
    _currentUser = user;
    _userController.add(user);
    await _saveUserLocally(user);
    return user;
  }

  Future<void> signOut() async {
    _currentUser = null;
    _userController.add(null);
    await _clearUserData();
  }

  Future<void> updateProfile(UserProfile profile) async {
    if (_currentUser != null) {
      _currentUser = User(
        id: _currentUser!.id,
        email: _currentUser!.email,
        name: _currentUser!.name,
        photoUrl: _currentUser!.photoUrl,
        profile: profile,
        createdAt: _currentUser!.createdAt,
        lastLoginAt: DateTime.now(),
      );
      _userController.add(_currentUser);
      await _saveUserLocally(_currentUser!);
    }
  }

  String _hashString(String input) {
    var bytes = utf8.encode(input);
    var digest = sha256.convert(bytes);
    return digest.toString().substring(0, 16);
  }

  Future<void> _saveUserLocally(User user) async {
    // Mock local storage
    print('Saving user: ${user.email}');
  }

  Future<void> _clearUserData() async {
    // Mock clear local storage
    print('Clearing user data');
  }

  void dispose() {
    _userController.close();
  }
}