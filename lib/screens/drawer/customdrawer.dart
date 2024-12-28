import 'package:expense_tracker/screens/drawer/runsqlpage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/screens/home/views/field_managementpage.dart';
import 'package:expense_tracker/screens/themes/theme.dart';

import '../themes/themeprovider.dart';

Drawer customDrawer(BuildContext context) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        const DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          child: Text(
            'Manage Fields',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        ),
        ListTile(
          title: const Text('Accounts'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FieldManagementPage(
                  fieldType: 'Accounts',
                ),
              ),
            );
          },
        ),
        ListTile(
          title: const Text('Sections'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FieldManagementPage(
                  fieldType: 'Sections',
                ),
              ),
            );
          },
        ),
        ListTile(
          title: const Text('Categories'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FieldManagementPage(
                  fieldType: 'Categories',
                ),
              ),
            );
          },
        ),
        ListTile(
          title: const Text('Subcategories'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FieldManagementPage(
                  fieldType: 'Subcategories',
                ),
              ),
            );
          },
        ),
        ListTile(
          title: Text('Run SQL'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RunSQLPage()),
            );
          },
        ),
        SwitchListTile(
          title: const Text('Dark Mode'),
          value: Provider.of<ThemeProvider>(context).getTheme() == darkTheme,
          onChanged: (value) {
            if (value) {
              Provider.of<ThemeProvider>(context, listen: false).setDarkTheme();
            } else {
              Provider.of<ThemeProvider>(context, listen: false)
                  .setLightTheme();
            }
          },
        ),
      ],
    ),
  );
}
