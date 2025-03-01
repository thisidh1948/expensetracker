import 'package:expense_tracker/database/transactions_crud.dart';
import 'package:expense_tracker/database/models/dbtransaction.dart';
import 'package:expense_tracker/screens/utils/transaction_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../database/models/summary.dart';
import '../../database/structures_crud.dart';
import '../../widgets/confirmation_dialog.dart';
import '../bottomnavbar/transactions/transaction_list_view.dart';

class DetailsPage extends StatefulWidget {
  final String structureType;
  final String name;

  const DetailsPage(
      {super.key, required this.structureType, required this.name});

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  double _totalBalance = 0.0;
  double _totalCredit = 0.0;
  double _totalDebit = 0.0;
  List<DbTransaction> _transactions = [];
  DateTimeRange? _selectedDateRange;
  bool _isLoading = true;
  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
  final StructuresCRUD _structuresCRUD = StructuresCRUD();
  Map<String, Map<String, String>> structureIcons = {};

  @override
  void initState() {
    super.initState();
    _selectedDateRange = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 30)),
      end: DateTime.now(),
    );
    _loadTransactions();
    _loadStructureIcons();
  }

  Future<void> _loadStructureIcons() async {
    final icons = await _structuresCRUD.getAllStructureIcons();
    setState(() {
      structureIcons = icons;
    });
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    try {
      List<DbTransaction> transactions =
          await TransactionCRUD().getAllTransactions();
      List<DbTransaction> structureTransactions = transactions
          .where((transaction) => transaction.account == widget.name)
          .toList();

      if (_selectedDateRange != null) {
        structureTransactions = structureTransactions.where((transaction) {
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

      for (var transaction in structureTransactions) {
        if (transaction.cd) {
          totalBalance += transaction.amount;
          totalCredit += transaction.amount;
        } else {
          totalBalance -= transaction.amount;
          totalDebit += transaction.amount;
        }
      }

      setState(() {
        _transactions = structureTransactions;
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
        title: Text('${widget.name} Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSummaryCard(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: _selectDateRange,
                      icon: const Icon(Icons.date_range),
                      label: Text(
                        _selectedDateRange != null
                            ? '${DateFormat('MMM d, y').format(_selectedDateRange!.start)} - '
                                '${DateFormat('MMM d, y').format(_selectedDateRange!.end)}'
                            : 'Select Date',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : TransactionListView(
                          transactions: _transactions,
                          isLoading: _isLoading,
                          onTapTransaction: (transaction) =>
                              TransactionUtils.showTransactionDetails(
                            context,
                            transaction,
                            structureIcons,
                          ),
                          onLongPressTransaction: (transaction) =>
                              TransactionUtils.editTransaction(
                                  context, transaction,
                                  onRefresh: _loadTransactions),
                          structureIcons: structureIcons,
                        ),
                ),
              ],
            ),
    );
  }
}
