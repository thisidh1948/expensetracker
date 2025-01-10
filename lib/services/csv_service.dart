import 'package:csv/csv.dart';
import 'package:expense_tracker/database/models/dbtransaction.dart';
import '../database/transactions_crud.dart';

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

    final transactions = <DbTransaction>[];
    final errors = <String>[];
    int rowNum = 1;

    // Process data rows
    for (final row in rows.skip(1)) {
      try {
        if (row.length != headerRow.length) {
          errors.add('Row $rowNum: Invalid number of columns');
          continue;
        }

        final Map<String, dynamic> rowMap = {};
        for (var i = 0; i < headerRow.length; i++) {
          rowMap[headerRow[i]] = row[i];
        }

        transactions.add(DbTransaction(
          id: int.tryParse(rowMap['id']?.toString() ?? ''),
          account: rowMap['bank'].toString(),
          section: rowMap['section']?.toString(),
          category: rowMap['category'].toString(),
          subcategory: rowMap['subcategory'].toString(),
          item: rowMap['item']?.toString(),
          cd: rowMap['cd'].toString().toLowerCase() == 'credit',
          units: double.tryParse(rowMap['units']?.toString() ?? ''),
          ppu: double.tryParse(rowMap['ppu']?.toString() ?? ''),
          tax: double.tryParse(rowMap['tax']?.toString() ?? ''),
          amount: double.parse(rowMap['amount'].toString()),
          date: rowMap['date'] != null ? DateTime.parse(rowMap['date'].toString()) : null,
          note: rowMap['note']?.toString(),
        ));
      } catch (e) {
        errors.add('Row $rowNum: ${e.toString()}');
      }
      rowNum++;
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
        transaction.date?.toIso8601String() ?? '',
        transaction.note ?? '',
      ].join(','));
    }

    return buffer.toString();
  }
}
