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
      'uuid': _uuid,
    });

    final result = await receivePort.first as Map<String, dynamic>;
    final transactions = result['transactions'] as List<DbTransaction>;
    final errors = result['errors'] as List<String>;

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
    final uuid = data['uuid'] as Uuid;

    final transactions = <DbTransaction>[];
    final errors = <String>[];
    int rowNum = 1;

    for (final row in rows) {
      try {
        if (row.length != headerRow.length) {
          errors.add('Row $rowNum: Invalid number of columns');
          continue;
        }

        final Map<String, dynamic> rowMap = {};
        for (var i = 0; i < headerRow.length; i++) {
          rowMap[headerRow[i]] = row[i];
        }
        String uuid = Uuid().v4();
        int id = int.parse(utf8.encode(uuid).fold(0, (a, b) => a + b).toString());

        transactions.add(DbTransaction(
          id: id,
          account: rowMap['bank'].toString(),
          section: rowMap['section']?.toString(),
          category: rowMap['category'].toString(),
          subcategory: rowMap['subcategory'].toString(),
          item: rowMap['item']?.toString(),
          cd: rowMap['cd'] != null ? rowMap['cd'].toString().toLowerCase() == 'credit' : false,
          units: double.tryParse(rowMap['units']?.toString() ?? ''),
          ppu: double.tryParse(rowMap['ppu']?.toString() ?? ''),
          tax: double.tryParse(rowMap['tax']?.toString() ?? ''),
          amount: double.parse(rowMap['amount'].toString()),
          date: _parseDate(rowMap['date'].toString()),
          note: rowMap['note']?.toString(),
        ));

        // Add a small delay between processing rows
        await Future.delayed(Duration(milliseconds: 10));
      } catch (e) {
        errors.add('Row $rowNum: ${e.toString()}');
      }
      rowNum++;
    }

    sendPort.send({'transactions': transactions, 'errors': errors});
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
