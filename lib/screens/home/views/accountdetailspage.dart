import 'package:expense_tracker/database/database_helper.dart';
import 'package:expense_tracker/database/transmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AccountDetailsPage extends StatefulWidget {
  final String account;

  const AccountDetailsPage({super.key, required this.account});

  @override
  _AccountDetailsPageState createState() => _AccountDetailsPageState();
}

class _AccountDetailsPageState extends State<AccountDetailsPage> {
  double _totalBalance = 0.0;
  List<TransModel> _transactions = [];
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    List<TransModel> transactions = await DatabaseHelper().getTransactions();
    double totalBalance = 0.0;
    List<TransModel> accountTransactions = transactions
        .where((transaction) => transaction.account == widget.account)
        .toList();

    for (var transaction in accountTransactions) {
      if (transaction.cd == 'Credit') {
        totalBalance += transaction.amount;
      } else {
        totalBalance -= transaction.amount;
      }
    }

    setState(() {
      _transactions = accountTransactions.take(30).toList(); // Limit to last 30 transactions
      _totalBalance = totalBalance;
    });
  }

  Future<void> _selectDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
        _filterTransactionsByDateRange();
      });
    }
  }

  void _filterTransactionsByDateRange() {
    if (_selectedDateRange != null) {
      List<TransModel> filteredTransactions = _transactions.where((transaction) {
        DateTime transactionDate = DateFormat('yyyy-MM-dd').parse(transaction.date);
        return transactionDate.isAfter(_selectedDateRange!.start) && transactionDate.isBefore(_selectedDateRange!.end);
      }).toList();

      setState(() {
        _transactions = filteredTransactions;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Total Balance: ₹$_totalBalance',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectDateRange,
              child: const Text('Filter by Date Range'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Transactions',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _transactions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_transactions[index].note ?? ''),
                    subtitle: Text(_transactions[index].date),
                    trailing: Text(
                      _transactions[index].amount.toString(),
                      style: TextStyle(
                        color: _transactions[index].cd == 'Credit' ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}