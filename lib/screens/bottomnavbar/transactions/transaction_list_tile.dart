import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../database/models/dbtransaction.dart';

class TransactionListTile extends StatelessWidget {
  final DbTransaction transaction;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const TransactionListTile({
    Key? key,
    required this.transaction,
    required this.onTap,
    required this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: transaction.cd
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        child: Icon(
          _getTransactionIcon(),
          color: transaction.cd ? Colors.green : Colors.red,
        ),
      ),
      title: Text(
        transaction.item ?? transaction.subcategory ?? transaction.category,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        transaction.note ?? '',
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.outline,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        '${transaction.cd ? '+' : '-'}₹${transaction.amount.toStringAsFixed(2)}',
        style: TextStyle(
          color: transaction.cd ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }

  IconData _getTransactionIcon() {
    if (transaction.item != null) {
      return Icons.shopping_bag;
    } else if (transaction.subcategory.isNotEmpty) {
      return Icons.category;
    } else {
      return Icons.account_balance_wallet;
    }
  }
}