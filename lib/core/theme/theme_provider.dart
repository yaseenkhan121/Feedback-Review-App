import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'user_theme_preference';
  ThemeMode _themeMode = ThemeMode.light;

  ThemeProvider() {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themeKey);
      
      if (savedTheme == 'dark') {
        _themeMode = ThemeMode.dark;
      } else {
        // Default strictly to Light Mode (ignore OS auto-switching unless user changes manually)
        _themeMode = ThemeMode.light;
      }
      notifyListeners();
    } catch (_) {
      _themeMode = ThemeMode.light;
    }
  }

  /// Manually toggle between Light and Dark mode and persist user's explicit choice
  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, isDark ? 'dark' : 'light');
    } catch (_) {}
  }
}
