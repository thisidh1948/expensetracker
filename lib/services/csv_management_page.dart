// lib/screens/csv_management_page.dart
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import '../database/database_helper.dart';

class CSVManagementPage extends StatefulWidget {
  const CSVManagementPage({Key? key}) : super(key: key);

  @override
  State<CSVManagementPage> createState() => _CSVManagementPageState();
}

class _CSVManagementPageState extends State<CSVManagementPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  bool _isLoading = false;

  Future<void> _exportToCSV() async {
    setState(() => _isLoading = true);
    try {
      // Get data from database
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> data = await db!.query('Alldata');

      if (data.isEmpty) {
        _showMessage('No data to export', isError: true);
        return;
      }

      // Convert data to CSV
      List<List<dynamic>> csvData = [];

      // Add headers
      csvData.add(data.first.keys.toList());

      // Add rows
      for (var row in data) {
        csvData.add(row.values.toList());
      }

      String csv = const ListToCsvConverter().convert(csvData);

      // Get save location
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory == null) return;

      // Create file name with timestamp
      final String timestamp = DateTime.now().toString().replaceAll(RegExp(r'[^0-9]'), '');
      final String filePath = '$selectedDirectory/expense_data_$timestamp.csv';

      // Write CSV file
      final File file = File(filePath);
      await file.writeAsString(csv);

      _showMessage('Data exported successfully to: $filePath');
    } catch (e) {
      _showMessage('Export failed: ${e.toString()}', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _importCSV() async {
    setState(() => _isLoading = true);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null) {
        _showMessage('No file selected', isError: true);
        return;
      }

      final file = File(result.files.single.path!);
      final contents = await file.readAsString();
      final rows = const CsvToListConverter().convert(contents);

      if (rows.isEmpty) {
        _showMessage('File is empty', isError: true);
        return;
      }

      // Validate and process data
      final headers = rows[0].map((e) => e.toString().toLowerCase()).toList();
      final requiredHeaders = [
        'account', 'section', 'category', 'subcategory',
        'amount', 'cd', 'note', 'date', 'quantity', 'price', 'tax'
      ];

      for (final header in requiredHeaders) {
        if (!headers.contains(header)) {
          _showMessage('Missing required column: $header', isError: true);
          return;
        }
      }

      // Process rows
      final db = await _databaseHelper.database;
      int processedRows = 0;

      await db?.transaction((txn) async {
        for (int i = 1; i < rows.length; i++) {
          try {
            final row = rows[i];
            if (row.length != headers.length) continue;

            final Map<String, dynamic> rowMap = {};
            for (int j = 0; j < headers.length; j++) {
              rowMap[headers[j]] = row[j];
            }

            await txn.insert(
              'Alldata',
              {
                'account': rowMap['account'] ?? '',
                'section': rowMap['section'] ?? '',
                'category': rowMap['category'] ?? '',
                'subCategory': rowMap['subcategory'] ?? '',
                'amount': double.tryParse(rowMap['amount'].toString()) ?? 0.0,
                'cd': rowMap['cd'] ?? '',
                'note': rowMap['note'] ?? '',
                'date': rowMap['date'] ?? '',
                'quantity': rowMap['quantity']?.toString() ?? '',
                'price': rowMap['price']?.toString() ?? '',
                'tax': rowMap['tax']?.toString() ?? '',
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
            processedRows++;
          } catch (e) {
            print('Error processing row $i: $e');
          }
        }
      });

      _showMessage('Successfully imported $processedRows records');
    } catch (e) {
      _showMessage('Import failed: ${e.toString()}', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Management'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Export Data',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Export all your expense data to a CSV file that can be opened in Excel or other spreadsheet applications.',
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _exportToCSV,
                          icon: const Icon(Icons.file_download),
                          label: const Text('Export to CSV'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Import Data',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Import expense data from a CSV file. Make sure the file has the correct format with all required columns.',
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _importCSV,
                          icon: const Icon(Icons.file_upload),
                          label: const Text('Import from CSV'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
