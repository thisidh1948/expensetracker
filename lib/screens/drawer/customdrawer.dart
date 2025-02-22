import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/screens/drawer/runsqlpage.dart';
import 'package:expense_tracker/screens/themes/theme.dart';
import 'package:expense_tracker/services/csv_management_page.dart';
import 'package:expense_tracker/screens/structure/managetransaction_skeleton.dart';
import 'package:expense_tracker/screens/themes/themeprovider.dart';
import 'package:expense_tracker/backup/backup_manager_page.dart';
import '../loans/debts_page.dart';
import '../loans/loaned_page.dart';

import '../auth/authprovider.dart';

Drawer customDrawer(BuildContext context) {
  return Drawer(
    child: Stack(
      children: [
        Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            final user = authProvider.user;

            return Column(
              children: [
                UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: user?.photoUrl != null
                        ? NetworkImage(user!.photoUrl!)
                        : null,
                    child: user?.photoUrl == null
                        ? const Icon(
                      CupertinoIcons.person_fill,
                      color: Colors.black54,
                    )
                        : null,
                  ),
                  accountName: Text(
                    user?.displayName ?? 'Guest User',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  accountEmail: Text(
                    user?.email ?? 'Please sign in',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onSecondary),
                  ),
                  onDetailsPressed: () {},
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      // Section: Tools
                      const SectionTitle(title: 'Tools'),
                      _buildDrawerListTile(
                        context,
                        icon: Icons.code,
                        title: 'Run SQL',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RunSQLPage()),
                        ),
                      ),
                      _buildDrawerListTile(
                        context,
                        icon: Icons.backup,
                        title: 'Backup & Restore',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BackupManagerPage(),
                          ),
                        ),
                      ),
                      _buildDrawerListTile(
                        context,
                        icon: Icons.data_usage,
                        title: 'Data Management',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CSVManagementPage(),
                          ),
                        ),
                      ),
                      _buildDrawerListTile(
                        context,
                        icon: Icons.architecture,
                        title: 'Skeleton',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ManageTransactionSkeleton(),
                          ),
                        ),
                      ),
                      const Divider(),
                      // Money Management Section
                      const SectionTitle(title: 'Money Management'),
                      _buildDrawerListTile(
                        context,
                        icon: Icons.money_off,
                        title: 'Debts',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DebtsPage(),
                          ),
                        ),
                      ),
                      _buildDrawerListTile(
                        context,
                        icon: Icons.attach_money,
                        title: 'Loaned',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoanedPage(),
                          ),
                        ),
                      ),
                      const Divider(),
                      // Section: Settings
                      const SectionTitle(title: 'Settings'),
                      Consumer<ThemeProvider>(
                        builder: (context, themeProvider, _) => SwitchListTile(
                          secondary: Icon(
                            themeProvider.getTheme() == darkTheme
                                ? Icons.dark_mode
                                : Icons.light_mode,
                            color: Theme.of(context).iconTheme.color,
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
                      _buildAuthTile(context, authProvider),
                    ],
                  ),
                ),
                Padding(
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
            );
          },
        ),
      ],
    ),
  );
}

Widget _buildDrawerListTile(BuildContext context,
    {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
  return ListTile(
    leading: Icon(icon, color: Theme.of(context).iconTheme.color),
    title: Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w500),
    ),
    onTap: onTap,
  );
}

Widget _buildAuthTile(BuildContext context, AuthProvider authProvider) {
  return authProvider.isSignedIn
      ? ListTile(
    leading:
    Icon(Icons.logout, color: Theme.of(context).iconTheme.color),
    title: const Text(
      'Logout',
      style: TextStyle(fontWeight: FontWeight.w500),
    ),
    onTap: () async {
      await authProvider.signOut();
      Navigator.of(context).pop(); // Close the drawer
      // Optionally, show a confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully')),
      );
    },
  )
      : ListTile(
    leading: Icon(Icons.login, color: Theme.of(context).iconTheme.color),
    title: const Text(
      'Sign In',
      style: TextStyle(fontWeight: FontWeight.w500),
    ),
    onTap: () async {
      await authProvider.signIn();
      if (authProvider.isSignedIn) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signed in successfully')),
        );
      } else if (authProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(authProvider.errorMessage!)),
        );
      }
      Navigator.of(context).pop(); // Close the drawer
    },
  );
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 8.0),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}
