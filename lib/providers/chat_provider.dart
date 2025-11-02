import 'package:flutter/material.dart';

class ChatProvider extends ChangeNotifier {
  bool _isOpen = false;

  bool get isOpen => _isOpen;

  void toggleChat() {
    _isOpen = !_isOpen;
    notifyListeners();
  }

  void closeChat() {
    _isOpen = false;
    notifyListeners();
  }
}
