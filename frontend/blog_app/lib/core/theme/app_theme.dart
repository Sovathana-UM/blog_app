import 'package:flutter/material.dart';
import 'app_color.dart';

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColor.primary,
        primary: AppColor.primary,
        secondary: AppColor.secondary,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: AppColor.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColor.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
    );
  }
}
