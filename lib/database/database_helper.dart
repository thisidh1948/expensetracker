import 'package:expense_tracker/database/fieldsmodel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'transmodel.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'expense_manager.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Alldata (
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
    await db
        .execute('CREATE TABLE Accounts (name TEXT PRIMARY KEY, icon INTEGER)');
    await db
        .execute('CREATE TABLE Sections (name TEXT PRIMARY KEY, icon INTEGER)');
    await db.execute(
        'CREATE TABLE Categories (name TEXT PRIMARY KEY, icon INTEGER)');
    await db.execute(
        'CREATE TABLE Subcategories (name TEXT PRIMARY KEY, icon INTEGER)');
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

  Future<void> insertField(
      String fieldType, Map<String, dynamic> fieldData) async {
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




  Future<void> deleteDatabase() async {
    String path = join(await getDatabasesPath(), 'expense_manager.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
