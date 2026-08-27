import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends GetxService {
  final SharedPreferences _prefs;
  final String _key = 'isDarkMode';
  
  late final RxBool isDarkModeRx;

  ThemeService(this._prefs) {
    isDarkModeRx = (_prefs.getBool(_key) ?? false).obs;
  }

  ThemeMode get theme {
    return isDarkModeRx.value ? ThemeMode.dark : ThemeMode.light;
  }

  bool get isDarkMode => isDarkModeRx.value;

  void toggleTheme() {
    final newMode = !isDarkMode;
    isDarkModeRx.value = newMode;
    _prefs.setBool(_key, newMode);
    Get.changeThemeMode(newMode ? ThemeMode.dark : ThemeMode.light);
  }
}
