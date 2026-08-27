import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2E6FF2),
        primary: const Color(0xFF2E6FF2),
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2E6FF2),
        primary: const Color(0xFF2E6FF2),
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF121212),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF1E1E1E),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Color(0xFF1E1E1E),
      ),
    );
  }
}
