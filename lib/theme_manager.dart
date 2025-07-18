import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Color _primaryColor = Colors.blue;

  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;

  ThemeManager() {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString('themeMode');
    if (themeModeString != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.toString() == themeModeString,
        orElse: () => ThemeMode.system,
      );
      notifyListeners();
    }
    final colorValue = prefs.getInt('primaryColor');
    if (colorValue != null) {
      _primaryColor = Color(colorValue);
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('themeMode', mode.toString());
    }
  }

  Future<void> setPrimaryColor(Color color) async {
    if (_primaryColor != color) {
      _primaryColor = color;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('primaryColor', color.value);
    }
  }

  // Placeholder for other theme-related properties if needed
  double get shadowElevation => 1.0; // Example
  double get cardRadius => 8.0; // Example
  double get blurLevel => 0.0; // Example
}
