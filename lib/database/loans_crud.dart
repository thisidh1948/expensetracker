import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import 'models/loan.dart';

class LoansCRUD {
  final DatabaseHelper _databaseHelper;

  LoansCRUD({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper();

  Future<int> insert(Loan loan) async {
    final db = await _databaseHelper.database;
    return await db!.insert('Loans', loan.toMap());
  }

  Future<void> update(Loan loan) async {
    final db = await _databaseHelper.database;
    await db!.update(
      'Loans',
      loan.toMap(),
      where: 'id = ?',
      whereArgs: [loan.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _databaseHelper.database;
    await db!.delete(
      'Loans',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Loan>> getLoans({required String personRole}) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db!.query(
      'Loans',
      where: 'role = ?',
      whereArgs: [personRole],
      orderBy: 'loan_date DESC',
    );
    return List.generate(maps.length, (i) => Loan.fromMap(maps[i]));
  }

  Future<double> getTotalAmount({required String personRole, String? status}) async {
    final db = await _databaseHelper.database;
    String whereClause = 'role = ?';
    List<dynamic> whereArgs = [personRole];
    
    if (status != null) {
      whereClause += ' AND status = ?';
      whereArgs.add(status);
    }

    final result = await db!.rawQuery(
      '''SELECT COALESCE(SUM(amount), 0) as total 
         FROM Loans 
         WHERE $whereClause''',
      whereArgs,
    );
    
    return result.first['total'] as double? ?? 0.0;
  }

  Future<List<Loan>> searchLoans({
    required String personRole,
    String? searchTerm,
    String? status,
  }) async {
    final db = await _databaseHelper.database;
    String whereClause = 'role = ?';
    List<dynamic> whereArgs = [personRole];

    if (searchTerm != null && searchTerm.isNotEmpty) {
      whereClause += ' AND (entity_name LIKE ? OR remarks LIKE ?)';
      whereArgs.addAll(['%$searchTerm%', '%$searchTerm%']);
    }

    if (status != null) {
      whereClause += ' AND status = ?';
      whereArgs.add(status);
    }

    final List<Map<String, dynamic>> maps = await db!.query(
      'Loans',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'loan_date DESC',
    );

    return List.generate(maps.length, (i) => Loan.fromMap(maps[i]));
  }
} 