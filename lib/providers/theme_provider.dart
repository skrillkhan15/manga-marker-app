import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Color _primaryColor = AppConstants.primaryColor;
  Color _secondaryColor = AppConstants.secondaryColor;
  Color _accentColor = AppConstants.accentColor;
  String _headlineFont = 'Roboto Slab';
  String _bodyFont = 'Open Sans';
  double _fontSize = 16.0;
  bool _highContrast = false;

  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;
  Color get secondaryColor => _secondaryColor;
  Color get accentColor => _accentColor;
  String get headlineFont => _headlineFont;
  String get bodyFont => _bodyFont;
  double get fontSize => _fontSize;
  bool get highContrast => _highContrast;

  ThemeProvider() {
    _loadThemePrefs();
  }

  Future<void> _loadThemePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(AppConstants.themeKey) ?? 0;
    _themeMode = ThemeMode.values[themeIndex];

    // Load custom colors if they exist
    final primaryColorValue = prefs.getInt('primary_color');
    if (primaryColorValue != null) {
      _primaryColor = Color(primaryColorValue);
    }

    final secondaryColorValue = prefs.getInt('secondary_color');
    if (secondaryColorValue != null) {
      _secondaryColor = Color(secondaryColorValue);
    }

    final accentColorValue = prefs.getInt('accent_color');
    if (accentColorValue != null) {
      _accentColor = Color(accentColorValue);
    }

    // Load fonts
    _headlineFont = prefs.getString('headline_font') ?? 'Roboto Slab';
    _bodyFont = prefs.getString('body_font') ?? 'Open Sans';
    _fontSize = prefs.getDouble('font_size') ?? 16.0;
    _highContrast = prefs.getBool('high_contrast') ?? false;

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.themeKey, mode.index);
    notifyListeners();
  }

  Future<void> setPrimaryColor(Color color) async {
    _primaryColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('primary_color', color.toARGB32());
    notifyListeners();
  }

  Future<void> setSecondaryColor(Color color) async {
    _secondaryColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('secondary_color', color.toARGB32());
    notifyListeners();
  }

  Future<void> setAccentColor(Color color) async {
    _accentColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('accent_color', color.toARGB32());
    notifyListeners();
  }

  Future<void> setHeadlineFont(String font) async {
    _headlineFont = font;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('headline_font', font);
    notifyListeners();
  }

  Future<void> setBodyFont(String font) async {
    _bodyFont = font;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('body_font', font);
    notifyListeners();
  }

  Future<void> setFontSize(double size) async {
    _fontSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('font_size', size);
    notifyListeners();
  }

  Future<void> setHighContrast(bool value) async {
    _highContrast = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('high_contrast', value);
    notifyListeners();
  }

  Future<void> resetToDefaults() async {
    _primaryColor = AppConstants.primaryColor;
    _secondaryColor = AppConstants.secondaryColor;
    _accentColor = AppConstants.accentColor;
    _headlineFont = 'Roboto Slab';
    _bodyFont = 'Open Sans';
    _fontSize = 16.0;
    _highContrast = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('primary_color');
    await prefs.remove('secondary_color');
    await prefs.remove('accent_color');
    await prefs.remove('headline_font');
    await prefs.remove('body_font');
    await prefs.remove('font_size');
    await prefs.remove('high_contrast');

    notifyListeners();
  }
}
