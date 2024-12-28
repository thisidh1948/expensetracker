import 'package:expense_tracker/screens/homescreen/home_screen.dart';
import 'package:expense_tracker/screens/themes/themeprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyAppView());
}

class MyAppView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(ThemeData.light()),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Expense Tracker',
            theme: themeProvider.getTheme(),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
