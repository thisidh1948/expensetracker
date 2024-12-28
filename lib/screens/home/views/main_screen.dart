import 'dart:math';

import 'package:expense_tracker/database/database_helper.dart';
import 'package:expense_tracker/database/transmodel.dart';
import 'package:expense_tracker/screens/home/views/scrollable_accounts.dart';
import 'package:expense_tracker/screens/home/views/transactionlist.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  double _totalBalance = 0.0;

  @override
  void initState() {
    super.initState();
    _calculateTotalBalance();
  }

  Future<void> _calculateTotalBalance() async {
    List<TransModel> transactions = await DatabaseHelper().getTransactions();
    setState(() {
      _totalBalance = transactions.fold(0.0, (sum, item) {
        if (item.cd == 'Credit') {
          return sum + item.amount;
        } else {
          return sum - item.amount;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Column(
          children: [
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Balance: ",
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,

                  ),
                ),
                Text(
                  _totalBalance.toStringAsFixed(2),
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),

            ScrollableAccountsView(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text(
                "Transactions",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  "View All",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
              )
            ]),
            const SizedBox(
              height: 20,
            ),
            TransactionListPage(),
          ],
        ),
      ),
    );
  }
}
