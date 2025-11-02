import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF007BFF);
  static const Color accentBlue = Color(0xFF0056B3);
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFF333333);
  static const Color lightGrey = Color(0xFF666666);
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color darkSurface = Color(0xFF2D2D2D);
  static const Color footerDark = Color(0xFF2C3E50);
  static const Color sectionBackground = Color(0xFFF8F9FA);
  static const Color featureBackground = Color(0xFFE3F2FD);

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: backgroundWhite,
      fontFamily: GoogleFonts.inter().fontFamily,
      focusColor: primaryBlue,
      dividerColor: const Color(0xFFE0E0E0),
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: accentBlue,
        surface: backgroundWhite,
        surfaceContainerHighest: sectionBackground,
        surfaceContainer: Color(0xFFF5F5F5),
        primaryContainer: featureBackground,
        onPrimary: Colors.white,
        onSurface: textGrey,
        onSurfaceVariant: lightGrey,
        outline: Color(0xFFE0E0E0),
        error: Color(0xFFD32F2F),
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.interTextTheme(const TextTheme(
        displayLarge: TextStyle(color: textGrey, fontSize: 42, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        displayMedium: TextStyle(color: textGrey, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        displaySmall: TextStyle(color: textGrey, fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: -0.25),
        headlineLarge: TextStyle(color: textGrey, fontSize: 24, fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(color: textGrey, fontSize: 20, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: textGrey, fontSize: 18, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: textGrey, fontSize: 16, height: 1.5),
        bodyMedium: TextStyle(color: lightGrey, fontSize: 14, height: 1.5),
        bodySmall: TextStyle(color: lightGrey, fontSize: 12, height: 1.4),
        labelLarge: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.5),
      )),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundWhite,
        foregroundColor: primaryBlue,
        elevation: 2,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadowColor: Colors.black.withValues(alpha: 0.08),
        color: backgroundWhite,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 3,
          shadowColor: primaryBlue.withValues(alpha: 0.3),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (states) => states.contains(WidgetState.hovered) ? Colors.white.withValues(alpha: 0.1) : null,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          side: const BorderSide(color: primaryBlue),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (states) => states.contains(WidgetState.hovered) ? primaryBlue.withValues(alpha: 0.1) : null,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBlue,
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (states) => states.contains(WidgetState.hovered) ? primaryBlue.withValues(alpha: 0.1) : null,
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: darkBackground,
      fontFamily: GoogleFonts.inter().fontFamily,
      focusColor: primaryBlue,
      dividerColor: const Color(0xFF404040),
      colorScheme: const ColorScheme.dark(
        primary: primaryBlue,
        secondary: accentBlue,
        surface: darkSurface,
        surfaceContainerHighest: footerDark,
        surfaceContainer: Color(0xFF383838),
        primaryContainer: Color(0xFF1E3A5F),
        onPrimary: Colors.white,
        onSurface: Colors.white,
        onSurfaceVariant: Color(0xFFB0B0B0),
        outline: Color(0xFF505050),
        error: Color(0xFFEF5350),
        onError: Colors.black,
      ),
      textTheme: GoogleFonts.interTextTheme(const TextTheme(
        displayLarge: TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        displayMedium: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        displaySmall: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: -0.25),
        headlineLarge: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
        bodyMedium: TextStyle(color: Color(0xFFB0B0B0), fontSize: 14, height: 1.5),
        bodySmall: TextStyle(color: Color(0xFFB0B0B0), fontSize: 12, height: 1.4),
        labelLarge: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.5),
      )),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: primaryBlue,
        elevation: 2,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadowColor: Colors.black.withValues(alpha: 0.4),
        color: darkSurface,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          shadowColor: primaryBlue.withValues(alpha: 0.4),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (states) => states.contains(WidgetState.hovered) ? Colors.white.withValues(alpha: 0.1) : null,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          side: const BorderSide(color: primaryBlue),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (states) => states.contains(WidgetState.hovered) ? primaryBlue.withValues(alpha: 0.1) : null,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBlue,
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (states) => states.contains(WidgetState.hovered) ? primaryBlue.withValues(alpha: 0.1) : null,
          ),
        ),
      ),
    );
  }
}
