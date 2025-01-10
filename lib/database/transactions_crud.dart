import 'package:sqflite/sqflite.dart';

import '../screens/home/monthly_bar_chart.dart';
import 'database_helper.dart';
import 'models/dbtransaction.dart';
import 'models/monthlydata_chart.dart';
import 'models/summary.dart';
import 'models/summary_with_transactions.dart';

class TransactionCRUD {
  final TransactioRepositry _databaseHelper;

  TransactionCRUD({TransactioRepositry? databaseHelper})
      : _databaseHelper = databaseHelper ?? TransactioRepositry();

  Future<void> insert(DbTransaction transaction) async {
    print('Saving transaction with cd value: {}' + transaction.cd.toString());
    final db = await _databaseHelper.database;
    await db!.insert(
      'Alldata',
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(DbTransaction transaction) async {
    final db = await _databaseHelper.database;
    print('Saving transaction with cd 456256442 value: {}' + transaction.cd.toString());
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

  Future<Summary> getAllDataSummary() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> credits = await db!.rawQuery(
        'SELECT COALESCE(SUM(amount), 0) as total FROM Alldata WHERE cd = 1');
    final List<Map<String, dynamic>> debits = await db.rawQuery(
        'SELECT COALESCE(SUM(amount), 0) as total FROM Alldata WHERE cd = 0');

    final double totalCredit = credits.first['total']?.toDouble() ?? 0.0;
    final double totalDebit = debits.first['total']?.toDouble() ?? 0.0;

    return Summary(
      credit: totalCredit,
      debit: totalDebit,
    );
  }

  Future<SummaryWithTransactions> getTransactionsAndSummary({
    String? columnName,
    dynamic columnValue,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
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
        COALESCE(SUM(CASE WHEN cd = 0 THEN amount ELSE 0 END), 0) as debits
      FROM Alldata 
      WHERE Account = ?
    ''', [accountName]);

    final double totalCredit = result.first['credits']?.toDouble() ?? 0.0;
    final double totalDebit = result.first['debits']?.toDouble() ?? 0.0;

    return totalCredit - totalDebit;
  }

  Future<Summary> getSelectBalance(
      String columnName, dynamic columnValue) async {
    final db = await _databaseHelper.database;

    // Calculate total credit
    final List<Map<String, dynamic>> credits = await db!.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total 
      FROM Alldata 
      WHERE $columnName = ? AND cd = 1
      ''', [columnValue]);

    // Calculate total debit
    final List<Map<String, dynamic>> debits = await db.rawQuery('''
      SELECT COALESCE(SUM(amount), 0) as total 
      FROM Alldata 
      WHERE $columnName = ? AND cd = 0
      ''', [columnValue]);

    final double totalCredit = credits.first['total']?.toDouble() ?? 0.0;
    final double totalDebit = debits.first['total']?.toDouble() ?? 0.0;

    return Summary(
      credit: totalCredit,
      debit: totalDebit,
    );
  }

  Future<List<MonthlyData>> getMonthlyTransactions() async {
    final db = await _databaseHelper.database;

    final List<Map<String, dynamic>> result = await db!.rawQuery('''
      SELECT 
        strftime('%Y-%m', date) as month,
        COALESCE(SUM(CASE WHEN cd = 1 THEN amount ELSE 0 END), 0) as credits,
        COALESCE(SUM(CASE WHEN cd = 0 THEN amount ELSE 0 END), 0) as debits
      FROM Alldata 
      GROUP BY month
      ORDER BY month DESC
    ''');

    return List.generate(result.length, (i) {
      final String month = result[i]['month'];
      final double totalCredit = result[i]['credits']?.toDouble() ?? 0.0;
      final double totalDebit = result[i]['debits']?.toDouble() ?? 0.0;

      return MonthlyData(
        month: month,
        income: totalCredit,
        expense: totalDebit,
      );
    });
  }

}
