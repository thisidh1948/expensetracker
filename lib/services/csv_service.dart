import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:expense_tracker/database/models/dbtransaction.dart';
import '../database/transactions_crud.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'dart:isolate';

class CSVImportResult {
  final int successCount;
  final int failureCount;
  final List<String> errors;

  CSVImportResult({
    required this.successCount,
    required this.failureCount,
    required this.errors,
  });
}

class CSVService {
  final TransactionCRUD _repository;
  final Uuid _uuid = Uuid();

  CSVService({TransactionCRUD? repository})
      : _repository = repository ?? TransactionCRUD();

  static List<String> get headers => [
    'id',
    'bank',
    'section',
    'category',
    'subcategory',
    'item',
    'cd',
    'units',
    'ppu',
    'tax',
    'amount',
    'date',
    'note',
  ];

  Future<CSVImportResult> importFromCSV(String csvContent) async {
    final rows = const CsvToListConverter().convert(csvContent);
    if (rows.isEmpty) {
      return CSVImportResult(
        successCount: 0,
        failureCount: 0,
        errors: ['Empty CSV file'],
      );
    }

    // Validate headers
    final headerRow = rows[0].map((e) => e.toString().toLowerCase()).toList();
    for (final requiredHeader in ['bank', 'category', 'subcategory', 'cd', 'amount']) {
      if (!headerRow.contains(requiredHeader)) {
        return CSVImportResult(
          successCount: 0,
          failureCount: rows.length - 1,
          errors: ['Missing required column: $requiredHeader'],
        );
      }
    }

    // Use Isolates for multi-threading
    final receivePort = ReceivePort();
    await Isolate.spawn(_processRows, {
      'rows': rows.skip(1).toList(),
      'headerRow': headerRow,
      'sendPort': receivePort.sendPort,
    });

    final result = await receivePort.first as Map<String, dynamic>;
    final transactions = result['transactions'] as List<DbTransaction>;
    final errors = result['errors'] as List<String>;
    print('Transactions: ${transactions.length}');
    //wat to print all transactions
    for (var transaction in transactions) {
      print(transaction.toMap());
    }
    // Insert valid transactions
    int successCount = 0;
    for (var transaction in transactions) {
      try {
        await _repository.insert(transaction);
        successCount++;
      } catch (e) {
        errors.add('Failed to insert transaction: ${e.toString()}');
      }
    }

    return CSVImportResult(
      successCount: successCount,
      failureCount: (rows.length - 1) - successCount,
      errors: errors,
    );
  }

  static Future<void> _processRows(Map<String, dynamic> data) async {
    final rows = data['rows'] as List<List<dynamic>>;
    final headerRow = data['headerRow'] as List<String>;
    final sendPort = data['sendPort'] as SendPort;

    final transactions = <DbTransaction>[];
    final errors = <String>[];
    int rowNum = 1;
    int lastTimestamp = DateTime.now().millisecondsSinceEpoch;

    for (final row in rows) {
      try {
        if (row.length != headerRow.length) {
          errors.add('Row $rowNum: Invalid number of columns (expected ${headerRow.length}, got ${row.length})');
          rowNum++;
          continue;
        }

        // Create row map
        final Map<String, dynamic> rowMap = {};
        for (var i = 0; i < headerRow.length; i++) {
          rowMap[headerRow[i]] = row[i] ?? ''; // Convert null to empty string
        }

        // Validate required fields without skipping immediately
        bool hasRequiredFields = true;
        final requiredFields = ['bank', 'category', 'subcategory', 'cd', 'amount'];
        for (var field in requiredFields) {
          if (rowMap[field] == null || rowMap[field].toString().trim().isEmpty) {
            errors.add('Row $rowNum: Missing required field "$field"');
            hasRequiredFields = false;
          }
        }

        if (!hasRequiredFields) {
          rowNum++;
          continue;
        }

        // Generate unique ID using timestamp
        int id = lastTimestamp++;  // Increment to ensure uniqueness even if processed in same millisecond

        // Convert cd value
        bool isCredit = false;
        var cdValue = rowMap['cd'];
        if (cdValue != null) {
          if (cdValue is num) {
            isCredit = cdValue == 1;
          } else if (cdValue is String) {
            // Try parsing as number first
            if (cdValue.trim().isNotEmpty) {
              try {
                isCredit = int.parse(cdValue) == 1;
              } catch (_) {
                isCredit = cdValue.toLowerCase() == 'credit';
              }
            }
          }
        }

        // Parse date with fallback
        DateTime date;
        try {
          date = rowMap['date'] != null && rowMap['date'].toString().isNotEmpty
              ? _parseDate(rowMap['date'].toString())
              : DateTime.now();
        } catch (e) {
          errors.add('Row $rowNum: Invalid date format: ${rowMap['date']}, using current date');
          date = DateTime.now();
        }

        // Parse amount
        double amount;
        try {
          amount = double.parse(rowMap['amount'].toString());
        } catch (e) {
          errors.add('Row $rowNum: Invalid amount format: ${rowMap['amount']}');
          rowNum++;
          continue;
        }

        // Parse optional numeric fields with better error handling
        double? units = _parseDoubleWithFallback(rowMap['units']?.toString(), 0);
        double? ppu = _parseDoubleWithFallback(rowMap['ppu']?.toString(), 0);
        double? tax = _parseDoubleWithFallback(rowMap['tax']?.toString(), 0);

        transactions.add(DbTransaction(
          id: id,
          account: rowMap['bank'].toString(),
          section: rowMap['section']?.toString(),
          category: rowMap['category'].toString(),
          subcategory: rowMap['subcategory'].toString(),
          item: rowMap['item']?.toString(),
          cd: isCredit,
          units: units,
          ppu: ppu,
          tax: tax,
          amount: amount,
          date: date,
          note: rowMap['note']?.toString(),
        ));

      } catch (e, stackTrace) {
        errors.add('Row $rowNum: Unexpected error: $e\n$stackTrace');
      }
      rowNum++;
    }

    sendPort.send({'transactions': transactions, 'errors': errors});
  }

  static double? _parseDoubleWithFallback(String? value, double fallback) {
    if (value == null || value.trim().isEmpty) return fallback;
    try {
      return double.parse(value);
    } catch (_) {
      return fallback;
    }
  }

  static DateTime _parseDate(String dateString) {
    try {
      return DateFormat('dd-MM-yyyy').parse(dateString);
    } catch (e) {
      throw FormatException('Invalid date format: $dateString');
    }
  }

  String exportToCSV(List<DbTransaction> transactions) {
    final buffer = StringBuffer();

    // Write headers
    buffer.writeln(headers.join(','));

    // Write data
    for (final transaction in transactions) {
      buffer.writeln([
        transaction.id?.toString() ?? '',
        transaction.account,
        transaction.section ?? '',
        transaction.category,
        transaction.subcategory,
        transaction.item ?? '',
        transaction.cd ? 'Credit' : 'Debit',
        transaction.units?.toString() ?? '',
        transaction.ppu?.toString() ?? '',
        transaction.tax?.toString() ?? '',
        transaction.amount.toString(),
        DateFormat('dd-MM-yyyy').format(transaction.date ?? DateTime.now()),
        transaction.note ?? '',
      ].join(','));
    }

    return buffer.toString();
  }
}
