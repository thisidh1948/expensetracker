import 'package:flutter/material.dart';

// Custom theme colors extension
extension CustomThemeColors on ThemeData {
  Color get successColor => brightness == Brightness.light
      ? Colors.green
      : Colors.green[700]!;

  Color get errorColor => brightness == Brightness.light
      ? Colors.red
      : Colors.red[700]!;

  Color get warningColor => brightness == Brightness.light
      ? Colors.orange
      : Colors.orange[700]!;
}

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  primaryColor: Colors.blue,
  secondaryHeaderColor: Colors.white,
  colorScheme: ColorScheme.light(
    primary: Colors.blue,
    secondary: Colors.amber,
    error: Colors.red,
    background: Colors.white,
    surface: Colors.white,
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onError: Colors.white,
    onBackground: Colors.black,
    onSurface: Colors.black,
    tertiary: Colors.black38,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
  ),
  scaffoldBackgroundColor: Colors.grey[100],
  cardColor: Colors.white,
  cardTheme: CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    color: Colors.white,
  ),
  iconTheme: const IconThemeData(color: Colors.blue),
  textTheme: const TextTheme(
    headlineSmall: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(color: Colors.black),
    bodyMedium: TextStyle(color: Colors.black54),
    bodySmall: TextStyle(color: Colors.black38),
  ),
  inputDecorationTheme: InputDecorationTheme(
    fillColor: Colors.grey.shade200,
    filled: true,
    hintStyle: const TextStyle(color: Colors.black54),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.blue),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      elevation: 2,
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
    elevation: 4,
  ),
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  primaryColor: Colors.blue,
  secondaryHeaderColor: const Color(0xFF0F172A),
  colorScheme: ColorScheme.dark(
    primary: Colors.blue,
    secondary: Colors.amber,
    error: Colors.red[700]!,
    background: Colors.black,
    surface: const Color(0xFF0F172A),
    onPrimary: Colors.white,
    onSecondary: Colors.white38,
    onError: Colors.white,
    onBackground: Colors.white,
    onSurface: Colors.white,
    tertiary: Colors.white38
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF0F172A),
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
  ),
  scaffoldBackgroundColor: Colors.black,
  cardColor: const Color(0xFF0F172A),
  cardTheme: CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    color: const Color(0xFF0F172A),
  ),
  iconTheme: const IconThemeData(color: Colors.white),
  textTheme: const TextTheme(
    headlineSmall: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white70),
    bodySmall: TextStyle(color: Colors.white38),
  ),
  inputDecorationTheme: InputDecorationTheme(
    fillColor: Colors.grey.shade900,
    filled: true,
    hintStyle: const TextStyle(color: Colors.white70),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.blue),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.red),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      elevation: 2,
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
    elevation: 4,
  ),
);
