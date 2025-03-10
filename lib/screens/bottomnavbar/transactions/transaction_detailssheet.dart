import 'package:expense_tracker/database/transactions_crud.dart';
import 'package:flutter/material.dart';

import '../../../database/models/dbtransaction.dart';
import '../../../widgets/confirmation_dialog.dart';
import '../../../widgets/customIcons.dart';

class TransactionDetailsSheet extends StatelessWidget {
  final DbTransaction transaction;
  final Map<String, Map<String, String>> structureIcons;

  const TransactionDetailsSheet({
    Key? key,
    required this.transaction,
    required this.structureIcons,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transaction Details',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
              'Date', transaction.date?.toString().split(' ')[0] ?? ''),
          _buildDetailRow('Account', transaction.account),
          if (transaction.section != null)
            _buildDetailRow('Section', transaction.section!),
          _buildDetailRowWithIcon('Category', transaction.category,
              structureIcons['category']?[transaction.category]),
          _buildDetailRowWithIcon('Subcategory', transaction.subcategory,
              structureIcons['subcategory']?[transaction.subcategory]),
          if (transaction.item != null)
            _buildDetailRow('Item', transaction.item!),
          _buildDetailRow('Type', transaction.cd ? 'Credit' : 'Debit'),
          _buildDetailRow(
              'Amount', '₹${transaction.amount.toStringAsFixed(2)}'),
          if (transaction.units != null)
            _buildDetailRow('Units', transaction.units.toString()),
          if (transaction.ppu != null)
            _buildDetailRow(
                'Price per Unit', '₹${transaction.ppu!.toStringAsFixed(2)}'),
          if (transaction.tax != null)
            _buildDetailRow('Tax', '₹${transaction.tax!.toStringAsFixed(2)}'),
          if (transaction.note != null && transaction.note!.isNotEmpty)
            _buildDetailRow('Note', transaction.note!),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => ConfirmationDialog(
                      title: 'Delete Transaction',
                      content:
                          'Are you sure you want to delete the transaction?',
                      onConfirm: () async {
                        await TransactionCRUD().delete(transaction.id!);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Transaction deleted')),
                        );
                        Navigator.pop(context); // Close the details sheet
                      },
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black12,
                  elevation: 2,
                ),
                child: const Text('Delete Transaction',
                    style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        letterSpacing: 1.2,
                        fontStyle: FontStyle.italic)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRowWithIcon(
      String label, String value, String? iconLabel) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          if (iconLabel != null) CustomIcons.getIcon(iconLabel, size: 24.0),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
