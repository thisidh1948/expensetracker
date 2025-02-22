import 'package:flutter/material.dart';
import 'loan_base_page.dart';

class LoanedPage extends StatelessWidget {
  const LoanedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const LoanBasePage(
      personRole: 'giver',
      title: 'Loaned',
    );
  }
} 