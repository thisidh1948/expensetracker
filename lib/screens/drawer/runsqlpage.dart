import 'package:flutter/material.dart';
import 'package:expense_tracker/database/database_helper.dart';

class RunSQLPage extends StatefulWidget {
  @override
  _RunSQLPageState createState() => _RunSQLPageState();
}

class _RunSQLPageState extends State<RunSQLPage> {
  final TextEditingController _sqlController = TextEditingController();
  String _result = '';

  Future<void> _runSQL() async {
    final db = await DatabaseHelper().database;
    try {
      var result = await db?.rawQuery(_sqlController.text);
      setState(() {
        _result = result.toString();
      });
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Run SQL'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _sqlController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter SQL Statement',
              ),
              maxLines: 4,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _runSQL,
              child: Text('Run'),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _result,
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
