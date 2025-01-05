import 'package:flutter/material.dart';
import 'package:expense_tracker/database/database_helper.dart';
import 'package:expense_tracker/database/transmodel.dart';

class StatScreen extends StatefulWidget {
  const StatScreen({super.key});

  @override
  State<StatScreen> createState() => _StatScreenState();
}

class _StatScreenState extends State<StatScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<TransModel> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final transactions = await _databaseHelper.getTransactions();
    setState(() {
      _transactions = transactions;
    });
  }

  double _calculateTotalExpenses() {
    return _transactions
        .where((t) => t.cd == 'Debit')
        .fold(0, (sum, t) => sum + t.amount);
  }

  double _calculateTotalIncome() {
    return _transactions
        .where((t) => t.cd == 'Credit')
        .fold(0, (sum, t) => sum + t.amount);
  }

  @override
  Widget build(BuildContext context) {
    final totalExpenses = _calculateTotalExpenses();
    final totalIncome = _calculateTotalIncome();
    final balance = totalIncome - totalExpenses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadTransactions,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Overview',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildStatRow('Total Income', totalIncome, Colors.green),
                      const SizedBox(height: 8),
                      _buildStatRow('Total Expenses', totalExpenses, Colors.red),
                      const Divider(),
                      _buildStatRow('Balance', balance,
                          balance >= 0 ? Colors.green : Colors.red),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Transaction Summary',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Total Transactions: ${_transactions.length}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, double amount, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
