import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData;

  ThemeProvider(this._themeData) {
    _loadTheme();
  }

  ThemeData get themeData => _themeData;

  setLightTheme() {
    _themeData = lightTheme;
    _saveTheme('light');
    notifyListeners();
  }

  setDarkTheme() {
    _themeData = darkTheme;
    _saveTheme('dark');
    notifyListeners();
  }

  getTheme() => _themeData;

  _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString('theme') ?? 'light';
    if (theme == 'light') {
      _themeData = lightTheme;
    } else {
      _themeData = darkTheme;
    }
    notifyListeners();
  }

  // Save the theme to shared preferences
  _saveTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('theme', theme);
  }
}
