import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../database/models/dbtransaction.dart';
import '../../../widgets/customIcons.dart';

class TransactionListTile extends StatelessWidget {
  final DbTransaction transaction;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Map<String, Map<String, String>> structureIcons;

  const TransactionListTile({
    Key? key,
    required this.transaction,
    required this.onTap,
    required this.onLongPress,
    required this.structureIcons,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Safely access the maps with null checks
    final itemsMap = structureIcons['items'] ?? {};
    final subcategoryMap = structureIcons['subcategory'] ?? {};
    final categoryMap = structureIcons['category'] ?? {};

    String iconName = (itemsMap[transaction.item?.toLowerCase()] ??
                     subcategoryMap[transaction.subcategory] ?? 
                     categoryMap[transaction.category] ?? 
                     'more_horiz');  // Default fallback icon

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: transaction.cd
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        child: CustomIcons.getIcon(
          iconName,
          size: 28.0,
        ),
      ),
      title: Row(
        children: [
          if (structureIcons['subcategory']?[transaction.subcategory] != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: CustomIcons.getIcon(
                structureIcons['subcategory']![transaction.subcategory]!,
                size: 20.0,
              ),
            ),
          const SizedBox(width: 8.0),
          Text(
            transaction.item ?? transaction.subcategory ?? transaction.category,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
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
