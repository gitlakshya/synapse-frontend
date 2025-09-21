import 'package:flutter/material.dart';
import 'dart:html' as html;

class ThemeService extends ChangeNotifier {
  static const _key = 'theme_mode';
  
  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;

  ThemeService() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final savedTheme = html.window.localStorage[_key];
      if (savedTheme != null) {
        _themeMode = ThemeMode.values.firstWhere(
          (mode) => mode.toString() == savedTheme,
          orElse: () => ThemeMode.dark,
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error loading theme: $e');
    }
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    html.window.localStorage[_key] = _themeMode.toString();
    notifyListeners();
  }

  bool get isDark => _themeMode == ThemeMode.dark;

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    cardColor: Colors.white,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFFFF7A18),
      secondary: Color(0xFF4DD0E1),
      background: Color(0xFFF5F5F5),
      surface: Colors.white,
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0B0F14),
    cardColor: const Color(0xFF0F1722),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFFF7A18),
      secondary: Color(0xFF4DD0E1),
      background: Color(0xFF0B0F14),
      surface: Color(0xFF0F1722),
    ),
  );
}