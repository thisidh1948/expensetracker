import 'package:expense_tracker/screens/drawer/runsqlpage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/screens/home/views/field_managementpage.dart';
import 'package:expense_tracker/screens/themes/theme.dart';
import '../../backup/backup_manager_page.dart';
import '../../services/csv_management_page.dart';
import '../themes/themeprovider.dart';

Drawer customDrawer(BuildContext context) {
  return Drawer(
    child: Column(
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Manage Fields',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildDrawerItem(
                context: context,
                icon: Icons.account_balance,
                title: 'Accounts',
                fieldType: 'Accounts',
              ),
              _buildDrawerItem(
                context: context,
                icon: Icons.category,
                title: 'Sections',
                fieldType: 'Sections',
              ),
              _buildDrawerItem(
                context: context,
                icon: Icons.folder,
                title: 'Categories',
                fieldType: 'Categories',
              ),
              _buildDrawerItem(
                context: context,
                icon: Icons.folder_open,
                title: 'Subcategories',
                fieldType: 'Subcategories',
              ),
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

Widget _buildDrawerItem({
  required BuildContext context,
  required IconData icon,
  required String title,
  required String fieldType,
}) {
  return ListTile(
    leading: Icon(icon),
    title: Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w500),
    ),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FieldManagementPage(
            fieldType: fieldType,
          ),
        ),
      );
    },
  );
}

