import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../database/models/dbtransaction.dart';

class TransactionDetailsSheet extends StatelessWidget {
  final DbTransaction transaction;

  const TransactionDetailsSheet({
    Key? key,
    required this.transaction,
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
          _buildDetailRow('Date', transaction.date?.toString().split(' ')[0] ?? ''),
          _buildDetailRow('Account', transaction.account),
          if (transaction.section != null)
            _buildDetailRow('Section', transaction.section!),
          _buildDetailRow('Category', transaction.category),
          _buildDetailRow('Subcategory', transaction.subcategory),
          if (transaction.item != null)
            _buildDetailRow('Item', transaction.item!),
          _buildDetailRow('Type', transaction.cd ? 'Credit' : 'Debit'),
          _buildDetailRow('Amount', '₹${transaction.amount.toStringAsFixed(2)}'),
          if (transaction.units != null)
            _buildDetailRow('Units', transaction.units.toString()),
          if (transaction.ppu != null)
            _buildDetailRow('Price per Unit', '₹${transaction.ppu!.toStringAsFixed(2)}'),
          if (transaction.tax != null)
            _buildDetailRow('Tax', '₹${transaction.tax!.toStringAsFixed(2)}'),
          if (transaction.note != null && transaction.note!.isNotEmpty)
            _buildDetailRow('Note', transaction.note!),
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
}
