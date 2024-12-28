import 'package:flutter/material.dart';
import 'theme.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData;

  ThemeProvider(this._themeData);

  getTheme() => _themeData;

  setLightTheme() {
    _themeData = lightTheme;
    notifyListeners();
  }

  setDarkTheme() {
    _themeData = darkTheme;
    notifyListeners();
  }
}
