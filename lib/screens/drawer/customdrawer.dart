import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

import 'package:expense_tracker/screens/drawer/runsqlpage.dart';
import 'package:expense_tracker/screens/themes/theme.dart';
import 'package:expense_tracker/services/csv_management_page.dart';
import 'package:expense_tracker/screens/structure/managetransaction_skeleton.dart';
import 'package:expense_tracker/screens/themes/themeprovider.dart';

import '../../backup/backup_manager_page.dart';
import '../auth/authprovider.dart'; // Make sure this path is correct

Drawer customDrawer(BuildContext context) {
  return Drawer(
    child: Stack(
      children: [
        // Blurred background
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.black.withOpacity(0.1), // More transparent background
          ),
        ),
        // Drawer content
        Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            final user = authProvider.user;

            return Column(
              children: [
                UserAccountsDrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.transparent, // Make header transparent to see the blur effect
                  ),
                  currentAccountPicture: CircleAvatar(
                    backgroundImage: user != null && user.photoUrl != null
                        ? NetworkImage(user.photoUrl!)
                        : null,
                    child: user?.photoUrl == null
                        ? const Icon(
                      CupertinoIcons.person_fill,
                      color: Colors.black54,
                    )
                        : null,
                  ),
                  accountName: Text(
                    user != null ? user.displayName ?? 'Guest User' : 'Guest User',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  accountEmail: Text(
                    user != null ? user.email : 'Please sign in',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
                  ),
                  onDetailsPressed: () {
                    // You can add navigation to a Profile page here if needed
                  },
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      // Section: Tools
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                        child: Text(
                          'Tools',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.code, color: Theme.of(context).iconTheme.color),
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
                      ListTile(
                        leading: Icon(Icons.backup, color: Theme.of(context).iconTheme.color),
                        title: const Text(
                          'Backup & Restore',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BackupManagerPage(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.data_usage, color: Theme.of(context).iconTheme.color),
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
                      ListTile(
                        leading: Icon(Icons.architecture, color: Theme.of(context).iconTheme.color),
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
                      const Divider(),
                      // Section: Settings
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                        child: Text(
                          'Settings',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
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
                      // Authentication Section
                      authProvider.isSignedIn
                          ? ListTile(
                        leading: Icon(Icons.logout, color: Theme.of(context).iconTheme.color),
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
            );
          },
        ),
      ],
    ),
  );
}
