import 'package:expense_tracker/screens/drawer/runsqlpage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/screens/themes/theme.dart';
import '../../backup/backup_manager_page.dart';
import '../../services/csv_management_page.dart';
import '../structure/managetransaction_skeleton.dart';
import '../themes/themeprovider.dart';

Drawer customDrawer(BuildContext context) {
  return Drawer(
    child: Column(
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Expense Tracker',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Manage your expenses',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const Divider(),
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text(
                  'Run SQL',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RunSQLPage()),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.backup),
                title: const Text('Backup & Restore'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BackupManagerPage(),
                    ),
                  );
                },
              ),
              const Divider(),
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) => SwitchListTile(
                  secondary: Icon(
                    themeProvider.getTheme() == darkTheme
                        ? Icons.dark_mode
                        : Icons.light_mode,
                  ),
                  title: const Text(
                    'Dark Mode',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  value: themeProvider.getTheme() == darkTheme,
                  onChanged: (value) {
                    if (value) {
                      themeProvider.setDarkTheme();
                    } else {
                      themeProvider.setLightTheme();
                    }
                  },
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.data_usage),
                title: const Text(
                  'Data Management',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CSVManagementPage(),
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.architecture),
                title: const Text(
                  'Skeleton',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ManageTransactionSkeleton(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        // Version info at bottom
        Container(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Version 1.0.0',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
              fontSize: 12,
            ),
          ),
        ),
      ],
    ),
  );
}
