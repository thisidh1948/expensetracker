import 'package:expense_tracker/database/transactions_crud.dart';
import 'package:expense_tracker/screens/addtransaction/add_transaction_page.dart';
import 'package:expense_tracker/screens/bottomnavbar/transactions/transaction_detailssheet.dart';
import 'package:expense_tracker/screens/bottomnavbar/transactions/transaction_list_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../database/models/dbtransaction.dart';
import '../../../widgets/confirmation_dialog.dart';
import '../../utils/transaction_utils.dart';
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
    try {
      final icons = await _structuresCRUD.getAllStructureIcons();
      setState(() {
        structureIcons = icons;
      });
    } catch (e, stackTrace) {
      print('Error loading structure icons: $e');
      print('Stack trace: $stackTrace');
      // Set default empty maps to prevent null errors
      setState(() {
        structureIcons = {
          'accounts': {},
          'category': {},
          'subcategory': {},
          'items': {},
        };
      });
    }
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
                  onTapTransaction: (transaction) => TransactionUtils.showTransactionDetails(
                    context,
                    transaction,
                    structureIcons,
                  ),
                  onLongPressTransaction: (transaction) => TransactionUtils.editTransaction(
                      context,
                      transaction,
                      onRefresh: _loadTransactions
                  ),
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