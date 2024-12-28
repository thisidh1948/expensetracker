import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.blue,
  secondaryHeaderColor: Colors.white,
  colorScheme: ColorScheme.light(
    primary: Colors.blue,
    secondary: Colors.amber,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
  ),
  scaffoldBackgroundColor: Colors.white,
  cardColor: Colors.white,
  iconTheme: IconThemeData(color: Colors.blue),
  textTheme: TextTheme(
    headlineSmall: TextStyle(color: Colors.black),
    bodyLarge: TextStyle(color: Colors.black),
    bodyMedium: TextStyle(color: Colors.black54),
    bodySmall: TextStyle(color: Colors.black26),

  ),
  inputDecorationTheme: InputDecorationTheme(
    fillColor: Colors.grey.shade200,
    hintStyle: TextStyle(color: Colors.black54),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.black,
  secondaryHeaderColor: Color(0xFF0F172A),
  colorScheme: ColorScheme.dark(
    primary: Colors.black,
    secondary: Color(0xFF0F172A),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
  ),
  scaffoldBackgroundColor: Colors.black,
  cardColor: Color(0xFF0F172A),
  iconTheme: IconThemeData(color: Colors.white),
  textTheme: TextTheme(
    headlineSmall: TextStyle(color: Colors.white),
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white70),
    bodySmall: TextStyle(color: Colors.white12)
  ),
  inputDecorationTheme: InputDecorationTheme(
    fillColor: Colors.grey.shade800,
    hintStyle: TextStyle(color: Colors.white70),
  ),
);
