import 'dart:math';
import 'package:expense_tracker/screens/drawer/customdrawer.dart';
import 'package:expense_tracker/screens/home/stats/stats.dart';
import 'package:expense_tracker/screens/homescreen/add_transaction.dart';
import 'package:expense_tracker/screens/home/views/main_screen.dart';
import 'package:expense_tracker/screens/homescreen/customappbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final double _totalBalance = 0.0;
  var wigetList = [
    const MainScreen(),
    const StatScreen(),
  ];

  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        child: BottomNavigationBar(
            onTap: (value) {
              setState(() {
                index = value;
              });
            },
            backgroundColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.black
                : Colors.white,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            elevation: 3,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.graph_square_fill),
                label: 'stats',
              ),
            ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTransactionPage()),
          );
        },
        shape: const CircleBorder(),
        child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                  Theme.of(context).colorScheme.tertiary,
                ], transform: const GradientRotation(pi / 4))),
            child: const Icon(CupertinoIcons.add)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      drawer: customDrawer(context),
      body: index == 0 ? const MainScreen() : const StatScreen(),
    );
  }
}
