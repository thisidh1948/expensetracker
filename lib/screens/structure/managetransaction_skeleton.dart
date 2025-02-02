import 'package:expense_tracker/screens/structure/com_structurepage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
 // Add this import

import '../../database/database_helper.dart';
import 'categoriespage.dart';
import '../../database/database_tables.dart';

class ManageTransactionSkeleton extends StatelessWidget {
  const ManageTransactionSkeleton({Key? key}) : super(key: key);

  Future<void> _showResetConfirmationDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Database'),
          content: const Text(
            'Are you sure you want to reset the database? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await DatabaseHelper().resetDatabase();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Database reset successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error resetting database: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Reset', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

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
                MaterialPageRoute(builder: (context) => const ComStructurePage(structureType: 'Sections')),
              ),
            ),
            const SizedBox(height: 16),
            _buildNavigationButton(
              context,
              'Sections',
                Icons.account_circle_rounded,
                  () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ComStructurePage(structureType: 'Sections')),
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
            const SizedBox(height: 16),
            _buildNavigationButton(
              context,
              'SubCategories',
              Icons.subject_rounded,
                  () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ComStructurePage(structureType: 'SubCategories')),
              ),
            ),
            const SizedBox(height: 16),
            _buildNavigationButton(
              context,
              'Items',
              Icons.add,
                  () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ComStructurePage(structureType: 'Items')),
              ),
            ),
            const SizedBox(height: 16),
            _buildNavigationButton(
              context,
              'Reset Database',
              Icons.delete_forever,
              () => _showResetConfirmationDialog(context),
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
          backgroundColor: title == 'Reset Database'
              ? Colors.red
              : Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
