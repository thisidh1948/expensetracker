import 'package:expense_tracker/database/transactions_crud.dart';
import 'package:expense_tracker/database/models/dbtransaction.dart';
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
  double _totalCredit = 0.0;
  double _totalDebit = 0.0;
  List<DbTransaction> _transactions = [];
  DateTimeRange? _selectedDateRange;
  bool _isLoading = true;
  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  @override
  void initState() {
    super.initState();
    _selectedDateRange = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 30)),
      end: DateTime.now(),
    );
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    try {
      List<DbTransaction> transactions = await TransactionCRUD().getAllTransactions();
      List<DbTransaction> accountTransactions = transactions
          .where((transaction) => transaction.account == widget.account)
          .toList();

      if (_selectedDateRange != null) {
        accountTransactions = accountTransactions.where((transaction) {
          final transactionDate = transaction.date;
          return transactionDate!.isAfter(_selectedDateRange!.start
                  .subtract(const Duration(days: 1))) &&
              transactionDate.isBefore(
                  _selectedDateRange!.end.add(const Duration(days: 1)));
        }).toList();
      }

      double totalBalance = 0.0;
      double totalCredit = 0.0;
      double totalDebit = 0.0;

      for (var transaction in accountTransactions) {
        if (transaction.cd) {
          totalBalance += transaction.amount;
          totalCredit += transaction.amount;
        } else {
          totalBalance -= transaction.amount;
          totalDebit += transaction.amount;
        }
      }

      setState(() {
        _transactions = accountTransactions;
        _totalBalance = totalBalance;
        _totalCredit = totalCredit;
        _totalDebit = totalDebit;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading transactions: $e')),
      );
    }
  }

Widget _buildSummaryCard() {
  return Card(
    elevation: 4,
    margin: const EdgeInsets.all(16),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Account Summary',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton.icon(
                onPressed: _selectDateRange,
                icon: const Icon(Icons.date_range),
                label: Text(
                  _selectedDateRange != null
                      ? '${DateFormat('MMM d').format(_selectedDateRange!.start)} - ${DateFormat('MMM d').format(_selectedDateRange!.end)}'
                      : 'Select Date',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const Divider(),
          LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: constraints.maxWidth / 3 - 8,
                    child: _buildSummaryItem(
                      'Balance',
                      _totalBalance,
                      _totalBalance >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                  SizedBox(
                    width: constraints.maxWidth / 3 - 8,
                    child: _buildSummaryItem(
                      'Credit',
                      _totalCredit,
                      Colors.green,
                    ),
                  ),
                  SizedBox(
                    width: constraints.maxWidth / 3 - 8,
                    child: _buildSummaryItem(
                      'Debit',
                      _totalDebit,
                      Colors.red,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    ),
  );
}

Widget _buildSummaryItem(String label, double amount, Color color) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      const SizedBox(height: 4),
      Text(
        _currencyFormat.format(amount),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: color,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    ],
  );
}

Future<void> _selectDateRange() async {
  final DateTimeRange? picked = await showDateRangePicker(
    context: context,
    firstDate: DateTime(2020),
    lastDate: DateTime.now(),
    initialDateRange: _selectedDateRange,
  );

  if (picked != null) {
    setState(() {
      _selectedDateRange = picked;
    });
    _loadTransactions();
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSummaryCard(),
                if (_selectedDateRange != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.date_range, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${DateFormat('MMM d, y').format(_selectedDateRange!.start)} - '
                          '${DateFormat('MMM d, y').format(_selectedDateRange!.end)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = _transactions[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: transaction.cd == true
                                ? Colors.green.withOpacity(0.2)
                                : Colors.red.withOpacity(0.2),
                            child: Icon(
                              transaction.cd == true
                                  ? Icons.add
                                  : Icons.remove,
                              color: transaction.cd == true
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          title: Text(
                            transaction.category ?? 'No Category',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${transaction.section} - ${transaction.date}',
                          ),
                          trailing: Text(
                            _currencyFormat.format(transaction.amount),
                            style: TextStyle(
                              color: transaction.cd == true
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
