import 'package:expense_tracker/database/transactions_crud.dart';
import 'package:expense_tracker/database/models/dbtransaction.dart';
import 'package:expense_tracker/database/models/summary.dart';
import 'package:flutter/material.dart';

class StatScreen extends StatefulWidget {
  const StatScreen({super.key});

  @override
  State<StatScreen> createState() => _StatScreenState();
}

class _StatScreenState extends State<StatScreen> {
  final TransactionCRUD _transactionRepository = TransactionCRUD();

  Summary _summary = Summary(credit: 0.0, debit: 0.0, initialBalance: 0.0);
  List<DbTransaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final transactions = await _transactionRepository.getAllTransactions();
    final Summary summary = await _transactionRepository.getStatsSummary();
    setState(() {
      _transactions = transactions;
      _summary =  summary;
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalExpenses = _summary.debit;
    final totalIncome = _summary.credit;
    final balance = _summary.balance;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadTransactions,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
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
