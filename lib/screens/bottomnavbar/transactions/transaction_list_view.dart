import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../database/models/dbtransaction.dart';
import 'transaction_list_tile.dart';

class TransactionListView extends StatelessWidget {
  final List<DbTransaction> transactions;
  final bool isLoading;
  final Function(DbTransaction) onTapTransaction;
  final Function(DbTransaction) onLongPressTransaction;
  final Map<String, Map<String, String>> structureIcons;

  const TransactionListView({
    Key? key,
    required this.transactions,
    required this.isLoading,
    required this.onTapTransaction,
    required this.onLongPressTransaction,
    required this.structureIcons,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No transactions found',
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        String? previousDate;
        String currentDate =
        DateFormat('dd MMMM yyyy').format(transaction.date!);

        if (index > 0) {
          previousDate = DateFormat('dd MMMM yyyy').format(transactions[index - 1].date!);
        }

        final bool showDateHeader = index == 0 || previousDate != currentDate;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showDateHeader)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  currentDate,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 3,
              color: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: TransactionListTile(
                transaction: transaction,
                onTap: () => onTapTransaction(transaction),
                onLongPress: () => onLongPressTransaction(transaction),
                structureIcons: structureIcons,
              ),
            ),
          ],
        );
      },
    );
  }
}
