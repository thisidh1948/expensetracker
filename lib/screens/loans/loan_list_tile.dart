import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../database/models/loan.dart';

class LoanListTile extends StatelessWidget {
  final Loan loan;
  final VoidCallback onTap;

  const LoanListTile({
    Key? key,
    required this.loan,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: loan.status == 'paid'
              ? Colors.green.withOpacity(0.1)
              : Colors.red.withOpacity(0.1),
          child: Icon(
            loan.status == 'paid' ? Icons.check_circle : Icons.pending,
            color: loan.status == 'paid' ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          loan.entityName ?? 'Self',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('dd MMM yyyy').format(loan.loanDate),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (loan.remarks != null && loan.remarks!.isNotEmpty)
              Text(
                loan.remarks!,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '₹${loan.amount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            Text(
              '${loan.interestRate}% p.a.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
} 