import 'package:expense_tracker/database/database_helper.dart';
import 'package:expense_tracker/database/fieldsmodel.dart';
import 'package:expense_tracker/screens/home/views/accountdetailspage.dart';
import 'package:flutter/material.dart';

class ScrollableAccountsView extends StatefulWidget {
  const ScrollableAccountsView({super.key});

  @override
  _ScrollableAccountsViewState createState() => _ScrollableAccountsViewState();
}

class AccountModel extends FieldModel {
  String balance;
  AccountModel({required String name, required this.balance}) : super(name: name);
}

class _ScrollableAccountsViewState extends State<ScrollableAccountsView> {
  List<AccountModel> _accounts = [];
  String _selectedAccount = '';

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    List<FieldModel> fields = await DatabaseHelper().getFields('Accounts');
    List<AccountModel> accountModels = [];
    for (var field in fields) {
      String balance = await DatabaseHelper().getAccountBalance(field.name);
      accountModels.add(AccountModel(name: field.name, balance: balance));
    }
    setState(() {
      _accounts = accountModels;
    });
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: Row(
          children: _accounts.map((account) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AccountDetailsPage(account: account.name),
                  ),
                );
              },
              child: Container(
                width: 200,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade800
                      : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black.withOpacity(0.5)
                          : Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 1,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      account.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      '₹${account.balance}', // Display the balance
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
