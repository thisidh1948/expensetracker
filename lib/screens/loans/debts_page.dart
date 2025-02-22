import 'package:flutter/material.dart';
import 'loan_base_page.dart';

class DebtsPage extends StatelessWidget {
  const DebtsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const LoanBasePage(
      personRole: 'taker',
      title: 'Debts',
    );
  }
} 