// transaction_utils.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../database/models/dbtransaction.dart';
import '../addtransaction/add_transaction_page.dart';
import '../bottomnavbar/transactions/transaction_detailssheet.dart';

typedef RefreshCallback = void Function();

class TransactionUtils {

  static void showTransactionDetails(
      BuildContext context,
      DbTransaction transaction,
      Map<String, Map<String, String>> structureIcons,
      ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
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

  static void editTransaction(
    BuildContext context,
      DbTransaction transaction,
    {RefreshCallback? onRefresh}
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionPage(
          transaction: transaction, isUpdate: true, // Pass the transaction for editing
        ),
      ),
    ).then((value) {
      if (value == true) {
        onRefresh?.call();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaction updated successfully')),
          );
        }
      }
    });
  }
}
