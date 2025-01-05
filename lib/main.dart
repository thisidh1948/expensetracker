import 'package:expense_tracker/app.dart';
import 'package:expense_tracker/screens/auth/authprovider.dart';
import 'package:expense_tracker/screens/themes/theme.dart';
import 'package:expense_tracker/screens/themes/themeprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider(lightTheme)),
      ],
      child: MyApp(),
    ),
  );
}
