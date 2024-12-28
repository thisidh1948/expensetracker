import 'package:expense_tracker/database/database_helper.dart';
import 'package:expense_tracker/database/transmodel.dart';
import 'package:expense_tracker/screens/homescreen/add_transaction.dart';
import 'package:flutter/material.dart';

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({super.key});

  @override
  _TransactionListPageState createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  List<TransModel> transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    List<TransModel> allTransactions = await DatabaseHelper().getTransactions();
    setState(() {
      transactions = allTransactions.reversed.take(15).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, int i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ExpansionTile(
                leading: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: transactions[i].cd == 'Credit' ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const Icon(Icons.account_balance_wallet),
                  ],
                ),
                title: Text(
                  transactions[i].note ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Theme.of(context).textTheme.headlineSmall?.color,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transactions[i].amount.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Theme.of(context).textTheme.headlineSmall?.color,
                      ),
                    ),
                    Text(
                      transactions[i].date,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Theme.of(context).textTheme.headlineSmall?.color,
                      ),
                    ),
                  ],
                ),
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Theme.of(context).iconTheme.color),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddTransactionPage(transaction: transactions[i]),
                            ),
                          );
                          _loadTransactions();
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Theme.of(context).iconTheme.color),
                        onPressed: () {
                          _deleteTransaction(transactions[i].id!);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _deleteTransaction(int id) async {
    await DatabaseHelper().deleteTransaction(id);
    _loadTransactions();
  }
}
