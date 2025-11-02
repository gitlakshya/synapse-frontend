import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  Future<void> signOut() async {
    _user = null;
    notifyListeners();
  }

  void mockSignIn(String name, String email) {
    _user = UserModel(
      uid: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      name: name,
    );
    notifyListeners();
  }
}
