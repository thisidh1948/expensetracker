// lib/screens/home/views/scrollable_accounts.dart

import 'package:flutter/material.dart';
import 'package:expense_tracker/database/structures_crud.dart';
import 'package:expense_tracker/database/transactions_crud.dart';
import 'package:expense_tracker/database/models/account_model.dart';
import 'package:expense_tracker/database/models/struct_model.dart';
import '../../widgets/customIcons.dart';
import 'details_page.dart';

class ScrollableAccountsView extends StatefulWidget {
  const ScrollableAccountsView({Key? key}) : super(key: key);

  @override
  State<ScrollableAccountsView> createState() => _ScrollableAccountsViewState();
}

class _ScrollableAccountsViewState extends State<ScrollableAccountsView> {
  List<AccountModel> _accounts = [];
  String _selectedAccount = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() => _isLoading = true);

    try {
      final List<StructModel> fields =
          await StructuresCRUD().getAllTableData('Accounts');

      List<AccountModel> accountModels = [];

      for (var field in fields) {
        double balance = await TransactionCRUD().getAccountBalance(field.name);

        accountModels.add(AccountModel(
            name: field.name,
            icon: field.icon,
            balance: balance,
            color: field.color));
      }

      setState(() {
        _accounts = accountModels;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading accounts: $e');
      setState(() => _isLoading = false);
      // You might want to show an error message to the user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading accounts: $e')),
        );
      }
    }
  }

  String _formatBalance(String balance) {
    try {
      final double amount = double.parse(balance);
      return amount.toStringAsFixed(2);
    } catch (e) {
      return balance;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_accounts.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(child: Text('No accounts available')),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: Row(
          children: _accounts.map((account) {
            final isSelected = account.name == _selectedAccount;

            return GestureDetector(
              onTap: () {
                setState(() => _selectedAccount = account.name);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DetailsPage(structureType: 'Accounts', name: account.name),
                  ),
                ).then((_) => _loadAccounts());
              },
              child: Card(
                elevation: isSelected ? 8 : 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (account.icon != null) ...[
                            CustomIcons.getIcon(account.icon, size: 25),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            account.name,
                            style: TextStyle(
                              color: account.color != null
                                  ? Color(int.parse(
                                      account.color!.replaceFirst('#', '0xFF')))
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹${account.balance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
