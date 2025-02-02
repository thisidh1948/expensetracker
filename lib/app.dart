import 'package:expense_tracker/screens/auth/authprovider.dart';
import 'package:expense_tracker/screens/auth/signinpage.dart';
import 'package:expense_tracker/screens/home_screen.dart';
import 'package:expense_tracker/screens/themes/themeprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ThemeProvider>(
      builder: (context, authProvider, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'logger',
          theme: themeProvider.getTheme(),
          home: authProvider.isSignedIn ? HomeScreen() : SignInPage(),
        );
      },
    );
  }
}
