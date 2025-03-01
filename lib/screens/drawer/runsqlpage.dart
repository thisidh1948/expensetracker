import 'dart:io';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:expense_tracker/database/database_helper.dart';
import '../utils/fileutils.dart';

class RunSQLPage extends StatefulWidget {
  @override
  _RunSQLPageState createState() => _RunSQLPageState();
}

class _RunSQLPageState extends State<RunSQLPage> {
  final TextEditingController _sqlController = TextEditingController();
  List<Map<String, dynamic>> _results = [];
  String _errorMessage = '';
  bool _isLoading = false;

  Future<void> _runSQL() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _results = [];
    });

    final db = await DatabaseHelper().database;
    try {
      var results = await db?.rawQuery(_sqlController.text);
      setState(() {
        _results = results ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadCSV() async {
    if (_results.isEmpty) return;

    List<List<dynamic>> csvData = [
      _results.first.keys.toList(), // Header row
      ..._results.map((row) => row.values.toList()), // Data rows
    ];

    String csv = const ListToCsvConverter().convert(csvData);
    await FileUtils.saveCSVFile(context, csv, 'results');
  }

  Widget _buildResultTable() {
    if (_results.isEmpty) return const SizedBox();
    if (_results.first.isEmpty) return const Text('No columns in result');

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          headingTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
          dataRowHeight: 56,
          headingRowHeight: 64,
          columnSpacing: 24,
          horizontalMargin: 16,
          columns: _results.first.keys.map((column) {
            return DataColumn(
              label: Text(
                column.toString(),
                style: const TextStyle(fontSize: 16),
              ),
            );
          }).toList(),
          rows: _results.map((row) {
            return DataRow(
              cells: row.values.map((value) {
                return DataCell(
                  Text(
                    value?.toString() ?? 'null',
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Run SQL'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _sqlController.clear();
              setState(() {
                _results = [];
                _errorMessage = '';
              });
            },
            tooltip: 'Clear',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _downloadCSV,
            tooltip: 'Download CSV',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _sqlController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter SQL query...',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _runSQL,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Execute Query'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            )
          else
            Expanded(
              child: _results.isEmpty
                  ? const Center(
                child: Text('No results to display'),
              )
                  : Card(
                margin: const EdgeInsets.all(16),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Results (${_results.length} rows)',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Divider(),
                      Expanded(
                        child: _buildResultTable(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _sqlController.dispose();
    super.dispose();
  }
}