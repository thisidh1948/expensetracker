import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../database/loans_crud.dart';
import '../../database/models/loan.dart';

class LoanDetailsSheet extends StatelessWidget {
  final Loan loan;
  final VoidCallback onUpdate;

  const LoanDetailsSheet({
    Key? key,
    required this.loan,
    required this.onUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loan.role == 'taker' ? 'Debt Details' : 'Loan Details',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow(context, 'Date', 
            DateFormat('dd MMM yyyy').format(loan.loanDate)),
          _buildDetailRow(context, 'Amount', 
            '₹${loan.amount.toStringAsFixed(2)}'),
          _buildDetailRow(context, 'Interest Rate', 
            '${loan.interestRate}% p.a.'),
          if (loan.entityName != null)
            _buildDetailRow(context, 'Entity', loan.entityName!),
          _buildDetailRow(context, 'Purpose', loan.purpose ?? 'N/A'),
          if (loan.remarks != null)
            _buildDetailRow(context, 'Remarks', loan.remarks!),
          _buildDetailRow(context, 'Status', 
            loan.status.toUpperCase(),
            valueColor: loan.status == 'paid' ? Colors.green : Colors.red),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (loan.status == 'unpaid')
                ElevatedButton.icon(
                  onPressed: () => _updateLoanStatus(context, 'paid'),
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Mark as Paid'),
                )
              else
                ElevatedButton.icon(
                  onPressed: () => _updateLoanStatus(context, 'unpaid'),
                  icon: const Icon(Icons.unpublished),
                  label: const Text('Mark as Unpaid'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                ),
              OutlinedButton.icon(
                onPressed: () => _deleteLoan(context),
                icon: const Icon(Icons.delete),
                label: const Text('Delete'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, 
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: valueColor,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateLoanStatus(BuildContext context, String newStatus) async {
    try {
      final updatedLoan = loan.copyWith(status: newStatus);
      await LoansCRUD().update(updatedLoan);
      onUpdate();
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Loan marked as ${newStatus.toUpperCase()}'),
            backgroundColor: newStatus == 'paid' ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating loan: $e')),
        );
      }
    }
  }

  Future<void> _deleteLoan(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Loan'),
        content: const Text('Are you sure you want to delete this loan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        await LoansCRUD().delete(loan.id!);
        onUpdate();
        if (context.mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting loan: $e')),
          );
        }
      }
    }
  }
} 