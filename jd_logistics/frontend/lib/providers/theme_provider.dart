import 'package:flutter/material.dart';
import 'package:jd_style_logistics/core/storage/local_storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDark => _themeMode == ThemeMode.dark;
  bool get isLight => _themeMode == ThemeMode.light;

  ThemeProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    final savedTheme = LocalStorageService.getThemeMode();

    if (savedTheme == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
      await LocalStorageService.saveThemeMode('light');
    }

    notifyListeners();
  }

  Future<void> setTheme(ThemeMode mode) async {
    if (mode == ThemeMode.system) {
      mode = ThemeMode.light;
    }

    _themeMode = mode;
    await LocalStorageService.saveThemeMode(
      mode == ThemeMode.dark ? 'dark' : 'light',
    );

    notifyListeners();
  }

  Future<void> setLightMode() async {
    await setTheme(ThemeMode.light);
  }

  Future<void> setDarkMode() async {
    await setTheme(ThemeMode.dark);
  }

  Future<void> toggleTheme() async {
    await setTheme(isDark ? ThemeMode.light : ThemeMode.dark);
  }

  IconData get themeIcon {
    return isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded;
  }

  String get themeLabel {
    return isDark ? 'Light Mode' : 'Dark Mode';
  }
}