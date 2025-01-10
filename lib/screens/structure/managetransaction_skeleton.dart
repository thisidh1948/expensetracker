import 'package:expense_tracker/screens/structure/sectionspage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'accountspage.dart';
import 'categoriespage.dart';

class ManageTransactionSkeleton extends StatelessWidget {
  const ManageTransactionSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Transaction Skeleton'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildNavigationButton(
              context,
              'Accounts',
              Icons.account_balance,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AccountsPage()),
              ),
            ),
            const SizedBox(height: 16),
            _buildNavigationButton(
              context,
              'Sections',
              Icons.access_alarms,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SectionsPage()),
              ),
            ),
            const SizedBox(height: 16),
            _buildNavigationButton(
              context,
              'Categories',
              Icons.category,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CategoriesPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(title),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
