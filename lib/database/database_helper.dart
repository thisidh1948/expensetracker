import 'dart:io';

import 'package:expense_tracker/database/fieldsmodel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'transmodel.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), 'expense_tracker.db');
    print('Database path: $path'); // Debug print to verify path

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Alldata (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        account TEXT,
        section TEXT,
        category TEXT,
        subCategory TEXT,
        amount REAL,
        cd TEXT,
        note TEXT,
        date TEXT,
        quantity TEXT,
        price TEXT,
        tax TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS Accounts (
        name TEXT PRIMARY KEY, 
        icon INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS Sections (
        name TEXT PRIMARY KEY, 
        icon INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS Categories (
        name TEXT PRIMARY KEY, 
        icon INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS Subcategories (
        name TEXT PRIMARY KEY, 
        icon INTEGER
      )
    ''');
  }

  // Method to ensure database exists and is initialized
  Future<void> ensureDatabase() async {
    final db = await database;
    if (db == null) {
      throw Exception('Failed to initialize database');
    }
  }

  // Method to check if database exists
  Future<bool> databaseExists() async {
    final String path = join(await getDatabasesPath(), 'expense_tracker.db');
    return await File(path).exists();
  }

  // Method to get database file
  Future<File> getDatabaseFile() async {
    final String path = join(await getDatabasesPath(), 'expense_tracker.db');
    return File(path);
  }

  // Method to close database
  Future<void> closeDatabase() async {
    final db = await database;
    if (db != null && db.isOpen) {
      await db.close();
      _database = null;
    }
  }

  Future<int> insertTransaction(TransModel transaction) async {
    final db = await database;
    return await db!.insert('Alldata', transaction.toMap());
  }

  Future<List<TransModel>> getTransactions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query('Alldata');

    return List.generate(maps.length, (i) {
      return TransModel(
        id: maps[i]['id'],
        account: maps[i]['account'],
        section: maps[i]['section'],
        category: maps[i]['category'],
        subCategory: maps[i]['subCategory'],
        amount: maps[i]['amount'],
        cd: maps[i]['cd'],
        note: maps[i]['note'],
        date: maps[i]['date'],
        quantity: maps[i]['quantity'],
        price: maps[i]['quantity'],
        tax: maps[i]['quantity'],
      );
    });
  }

  Future<void> deleteTransaction(int id) async {
    final db = await database;
    await db!.delete(
      'Alldata',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateTransaction(TransModel transaction) async {
    final db = await database;
    return await db!.update(
      'Alldata',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<void> insertField(String fieldType, Map<String, dynamic> fieldData) async {
    final db = await database;
    await db!.insert(
      fieldType,
      fieldData,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<FieldModel>> getFields(String fieldType) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query(fieldType);
    return List.generate(maps.length, (i) {
      return FieldModel.fromMap(maps[i]);
    });
  }

  Future<String> getAccountBalance(String account) async {
    final db = await database;
    final result = await db?.rawQuery('''
    SELECT 
      SUM(CASE 
          WHEN cd = 'Credit' THEN amount 
          WHEN cd = 'Debit' THEN -amount 
          ELSE 0 
        END) as totalBalance 
    FROM Alldata 
    WHERE account = ?
  ''', [account]);

    if (result!.isNotEmpty && result?[0]['totalBalance'] != null) {
      return (result[0]['totalBalance'] as num).toDouble().toString();
    } else {
      return '0.0';
    }
  }

  Future<void> deleteField(String tableName, String fieldName) async {
    final db = await database;
    try {
      await db?.delete(
        tableName,
        where: 'name = ?',
        whereArgs: [fieldName],
      );
    } catch (e) {
      print('Error deleting field: $e');
      throw Exception('Failed to delete field: $e');
    }
  }

  Future<void> deleteDatabase() async {
    String path = join(await getDatabasesPath(), 'expense_manager.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
