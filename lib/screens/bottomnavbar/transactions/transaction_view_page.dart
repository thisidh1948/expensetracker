import 'package:expense_tracker/database/transactions_crud.dart';
import 'package:expense_tracker/screens/addtransaction/add_transaction_page.dart';
import 'package:expense_tracker/screens/bottomnavbar/transactions/transaction_detailssheet.dart';
import 'package:expense_tracker/screens/bottomnavbar/transactions/transaction_list_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../database/models/dbtransaction.dart';
import 'month_selector.dart';
import 'package:expense_tracker/database/structures_crud.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({Key? key}) : super(key: key);

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final ScrollController _scrollController = ScrollController();
  DateTime _currentDate = DateTime.now();
  List<DbTransaction> transactions = [];
  bool _isLoading = false;
  final TransactionCRUD _transactionCRUD = TransactionCRUD();
  final StructuresCRUD _structuresCRUD = StructuresCRUD();
  Map<String, Map<String, String>> structureIcons = {};
  int _currentPage = 1000;

  @override
  void initState() {
    super.initState();
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
      final DateTime firstDay =
      DateTime(_currentDate.year, _currentDate.month, 1);
      final DateTime lastDay =
      DateTime(_currentDate.year, _currentDate.month + 1, 0);

      final List<DbTransaction> loadedTransactions =
      await _transactionCRUD.getTransactionsByDateRange(
        firstDay,
        lastDay,
      );
      setState(() {
        transactions = loadedTransactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading transactions: $e')),
      );
    }
  }

  void _showTransactionDetails(DbTransaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor, // or any specific color you want
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: TransactionDetailsSheet(
          transaction: transaction,
          structureIcons: structureIcons,
        ),
      ),
    );
  }



  void _editTransaction(DbTransaction transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionPage(
          transaction: transaction, isUpdate: true, // Pass the transaction for editing
        ),
      ),
    ).then((result) {
      // Refresh the transactions list when returning from edit page
      if (result == true) {
        _loadTransactions(); // Reload transactions if changes were made
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transactions',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Add filter functionality here
            },
          ),
        ],
      ),
      body: PageView.builder(
        controller: PageController(initialPage: 1000), // Start from a large number to allow infinite scrolling
        onPageChanged: (page) {
          _changeMonth(page - _currentPage);
          _currentPage = page;
        },
        itemBuilder: (context, page) {
          return Column(
            children: [
              MonthSelector(
                selectedDate: _currentDate,
                onMonthSelected: (DateTime date) {
                  setState(() {
                    _currentDate = date;
                  });
                  _loadTransactions();
                },
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : TransactionListView(
                  transactions: transactions,
                  isLoading: _isLoading,
                  onTapTransaction: _showTransactionDetails,
                  onLongPressTransaction: _editTransaction,
                  structureIcons: structureIcons,
                ),
              ),
            ],
          );
        },
      ),

    );
  }

  void _changeMonth(int months) {
    setState(() {
      _currentDate = DateTime(
        _currentDate.year,
        _currentDate.month + months,
        _currentDate.day,
      );
    });
    _loadTransactions();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
