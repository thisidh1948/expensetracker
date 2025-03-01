import 'package:expense_tracker/screens/utils/number_formatter.dart';
import 'package:sqflite/sqflite.dart';

import '../screens/home/monthly_bar_chart.dart';
import 'database_helper.dart';
import 'models/dbtransaction.dart';
import 'models/monthlydata_chart.dart';
import 'models/summary.dart';
import 'models/summary_with_transactions.dart';

class TransactionCRUD {
  final DatabaseHelper _databaseHelper;

  TransactionCRUD({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper();

  Future<void> insert(DbTransaction transaction) async {
    final db = await _databaseHelper.database;
    await db!.insert(
      'Alldata',
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(DbTransaction transaction) async {
    final db = await _databaseHelper.database;
    print('Saving transaction with cd 456256442 value: {}' +
        transaction.cd.toString());
    await db!.update(
      'Alldata',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _databaseHelper.database;
    await db!.delete(
      'Alldata',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<DbTransaction>> getAllTransactions() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db!.query('Alldata');
    return List.generate(maps.length, (i) => DbTransaction.fromMap(maps[i]));
  }

  Future<String> getTotalBalance() async {
    final db = await _databaseHelper.database;
    if (db == null) {
      return '₹0.00';
    }
    try {
      // Get total credits and debits from Alldata
      final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT
        COALESCE(SUM(CASE WHEN cd = 1 THEN amount ELSE 0 END), 0) as credits,
        COALESCE(SUM(CASE WHEN cd = 0 THEN amount ELSE 0 END), 0) as debits,
        (SELECT COALESCE(SUM(balance), 0) FROM Accounts) as initial_balance
      FROM Alldata ''');

      final double totalCredit = result.first['credits']?.toDouble() ?? 0.0;
      final double totalDebit = result.first['debits']?.toDouble() ?? 0.0;
      final double initialBalance = result.first['initial_balance']?.toDouble() ?? 0.0;

      // Calculate final balance
      final double totalBalance = initialBalance + totalCredit - totalDebit;

      // Format and return the balance
      return '₹${NumberFormatter.formatIndianNumber(totalBalance)}';
    } catch (e) {
      print('Error calculating total balance: $e');
      return '₹0.00';
    }
  }

  Future<Summary> getStatsSummary() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> credits = await db!.rawQuery(
        'SELECT COALESCE(SUM(amount), 0) as total FROM Alldata WHERE cd = 1 AND category != \'SELF TRANSFER\'');
    final List<Map<String, dynamic>> debits = await db.rawQuery(
        'SELECT COALESCE(SUM(amount), 0) as total FROM Alldata WHERE cd = 0 AND category != \'SELF TRANSFER\'');

    final double totalCredit = credits.first['total']?.toDouble() ?? 0.0;
    final double totalDebit = debits.first['total']?.toDouble() ?? 0.0;

    return Summary(credit: totalCredit, debit: totalDebit, initialBalance: 0.0);
  }

  Future<SummaryWithTransactions> getTransactionsAndSummary({
    String? columnName,
    dynamic columnValue,
    DateTime? startDate,
    DateTime? endDate,
  }) async
  {
    final db = await _databaseHelper.database;

    final List<String> whereConditions = [];
    final List<dynamic> whereArgs = [];

    // Add column-based filter if provided
    if (columnName != null && columnValue != null) {
      whereConditions.add('$columnName = ?');
      whereArgs.add(columnValue);
    }

    // Add date range filters if provided
    if (startDate != null) {
      whereConditions.add('date >= ?');
      whereArgs.add(startDate.toIso8601String());
    }
    if (endDate != null) {
      whereConditions.add('date <= ?');
      whereArgs.add(endDate.toIso8601String());
    }

    final String whereClause =
        whereConditions.isEmpty ? '' : 'WHERE ${whereConditions.join(' AND ')}';

    // Get transactions
    final List<Map<String, dynamic>> transactionMaps = await db!.rawQuery(
      'SELECT * FROM Alldata $whereClause ORDER BY date DESC',
      whereArgs,
    );

    final List<DbTransaction> transactions = List.generate(
        transactionMaps.length,
        (i) => DbTransaction.fromMap(transactionMaps[i]));

    // Calculate summary
    double totalCredit = 0.0;
    double totalDebit = 0.0;

    for (var transaction in transactions) {
      if (transaction.category == 'SELF TRANSFER') continue;
      if (transaction.cd == '1') {
        // true for credit
        totalCredit += transaction.amount;
      } else {
        totalDebit += transaction.amount;
      }
    }

    return SummaryWithTransactions(
      credit: totalCredit,
      debit: totalDebit,
      transactions: transactions,
    );
  }

  Future<double> getAccountBalance(String accountName) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> result = await db!.rawQuery('''
    SELECT
      COALESCE(SUM(CASE WHEN cd = 1 THEN amount ELSE 0 END), 0) as credits,
      COALESCE(SUM(CASE WHEN cd = 0 THEN amount ELSE 0 END), 0) as debits,
      (SELECT COALESCE(balance, 0) FROM Accounts WHERE name = ?) as initial_balance
    FROM Alldata
    WHERE account = ?
  ''', [accountName, accountName]);

    final double totalCredit = result.first['credits']?.toDouble() ?? 0.0;
    final double totalDebit = result.first['debits']?.toDouble() ?? 0.0;
    final double initialBalance = result.first['initial_balance']?.toDouble() ?? 0.0;

    return initialBalance + totalCredit - totalDebit;
  }

  Future<List<MonthlyData>> getMonthlyTransactions() async {
    final db = await _databaseHelper.database;

    final List<Map<String, dynamic>> result = await db!.rawQuery('''
    WITH RECURSIVE dates(date) AS (
      SELECT date('now', 'start of month', '-5 months')
      UNION ALL
      SELECT date(date, '+1 month')
      FROM dates
      WHERE date < date('now', 'start of month')
    )
    SELECT 
      strftime('%Y-%m', dates.date) as month,
      COALESCE(SUM(CASE WHEN cd = 1 AND category NOT IN ('SELF TRANSFER') THEN amount ELSE 0 END), 0) as credits,
      COALESCE(SUM(CASE WHEN cd = 0 AND category NOT IN ('SELF TRANSFER') THEN amount ELSE 0 END), 0) as debits
    FROM dates
    LEFT JOIN Alldata ON strftime('%Y-%m', Alldata.date) = strftime('%Y-%m', dates.date)
    GROUP BY month
    ORDER BY month ASC
    LIMIT 6
  ''');

    return List.generate(result.length, (i) {
      final String month = result[i]['month'];
      final double totalCredit = result[i]['credits']?.toDouble() ?? 0.0;
      final double totalDebit = result[i]['debits']?.toDouble() ?? 0.0;

      return MonthlyData(
        month: month, // Using the previously created method
        income: totalCredit,
        expense: totalDebit,
      );
    });
  }

  Future<List<DbTransaction>> getTransactionsByDateRange(
      DateTime startDate, DateTime endDate) async {
    final db = await _databaseHelper.database;

    final List<Map<String, dynamic>> maps = await db!.query(
      'Alldata',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
    );

    return List.generate(maps.length, (i) => DbTransaction.fromMap(maps[i]));
  }

  Future<Map<String, Map<String, String>>> getAllStructureIcons() async {
    final db = await _databaseHelper.database;
    Map<String, Map<String, String>> result = {
      'accounts': {},
      'category': {},
      'subcategory': {},
      'items': {},
    };

    // Get icons from accounts table
    final List<Map<String, dynamic>> accountMaps = await db!.query(
      'accounts',
      columns: ['name', 'icon'],
    );
    result['accounts'] = Map.fromEntries(accountMaps
        .map((map) => MapEntry(map['name'] as String, map['icon'] as String)));

    // Get icons from category table
    final List<Map<String, dynamic>> categoryMaps = await db.query(
      'category',
      columns: ['name', 'icon'],
    );
    result['category'] = Map.fromEntries(categoryMaps
        .map((map) => MapEntry(map['name'] as String, map['icon'] as String)));

    // Get icons from subcategory table
    final List<Map<String, dynamic>> subcategoryMaps = await db.query(
      'subcategory',
      columns: ['name', 'icon'],
    );
    result['subcategory'] = Map.fromEntries(subcategoryMaps
        .map((map) => MapEntry(map['name'] as String, map['icon'] as String)));

    // Get icons from items table
    final List<Map<String, dynamic>> itemMaps = await db.query(
      'items',
      columns: ['name', 'icon'],
    );
    result['items'] = Map.fromEntries(itemMaps
        .map((map) => MapEntry(map['name'] as String, map['icon'] as String)));

    return result;
  }
}
