import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../database/transactions_crud.dart';
import 'csv_service.dart';

class CSVManagementPage extends StatefulWidget {
  const CSVManagementPage({Key? key}) : super(key: key);

  @override
  State<CSVManagementPage> createState() => _CSVManagementPageState();
}

class _CSVManagementPageState extends State<CSVManagementPage> {
  final CSVService _csvService = CSVService();
  final TransactionCRUD _repository = TransactionCRUD();
  bool _isLoading = false;

// In _CSVManagementPageState class, update the _exportCSV method:

  Future<void> _exportCSV() async {
    setState(() => _isLoading = true);
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) {
        setState(() => _isLoading = false);
        return;
      }

      final transactions = await _repository.getAllTransactions();
      if (transactions.isEmpty) {
        _showMessage('No data to export', isError: true);
        return;
      }

      final csvContent = _csvService.exportToCSV(transactions);

      final timestamp =
          DateTime.now().toString().replaceAll(RegExp(r'[^0-9]'), '');
      final filePath = '$selectedDirectory/expense_data_$timestamp.csv';

      final file = File(filePath);
      await file.writeAsString(csvContent);

      _showMessage('Data exported successfully to: $filePath');
    } catch (e) {
      _showMessage('Export failed: ${e.toString()}', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _importCSV() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null) return;

      setState(() => _isLoading = true);

      final file = File(result.files.single.path!);
      final csvContent = await file.readAsString();

      final importResult = await _csvService.importFromCSV(csvContent);

      if (importResult.errors.isEmpty) {
        _showMessage(
            'Successfully imported ${importResult.successCount} records');
      } else {
        _showErrorDialog(
          'Import Results',
          'Imported ${importResult.successCount} records with ${importResult.failureCount} failures',
          importResult.errors,
        );
      }
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

  void _showErrorDialog(String title, String summary, List<String> errors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(summary),
              if (errors.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Errors:'),
                const SizedBox(height: 8),
                ...errors.map((error) => Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 4),
                      child: Text('• $error'),
                    )),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
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
                          onPressed: _isLoading ? null : _exportCSV,
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
                          'Import expense data from a CSV file. Required columns: bank, category, subcategory, cd (Credit/Debit), amount.',
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Optional columns: section, item, units, ppu (price per unit), tax.',
                          style: TextStyle(fontStyle: FontStyle.italic),
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
