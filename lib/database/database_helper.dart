import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../screens/utils/id_generator.dart';


class TransactioRepositry {
  static const _createTransactionTable = '''
    CREATE TABLE IF NOT EXISTS Alldata (
      id INTEGER PRIMARY KEY,
      Account TEXT NOT NULL,
      section TEXT,
      category TEXT NOT NULL,
      subcategory TEXT NOT NULL,
      item TEXT,
      cd BOOLEAN NOT NULL,
      units REAL,
      ppu REAL,
      tax REAL,
      amount REAL NOT NULL,
      date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
      note TEXT
    )
  ''';

  static const _createAccountsTable = '''
    CREATE TABLE IF NOT EXISTS Accounts (
      name TEXT PRIMARY KEY,
      icon TEXT
    )
  ''';

  static const _createSectionTable = '''
    CREATE TABLE IF NOT EXISTS Sections (
      name TEXT PRIMARY KEY,
      icon TEXT
    )
  ''';

  static const _createCategoriesTable = '''
    CREATE TABLE IF NOT EXISTS Categories (
      name TEXT PRIMARY KEY,
      icon TEXT
    )
  ''';

  static const _createSubCategoriesTable = '''
    CREATE TABLE IF NOT EXISTS SubCategories (
      name TEXT PRIMARY KEY,
      icon TEXT
    )
  ''';

  static const _createItemsTable = '''
    CREATE TABLE IF NOT EXISTS Items (
      name TEXT PRIMARY KEY,
      icon TEXT
    )
  ''';

  static const _createSubcategoriesForCategoryTable = '''
    CREATE TABLE IF NOT EXISTS SubcategoriesForCategory (
      parent TEXT,
      child TEXT,
      PRIMARY KEY (parent, child),
      FOREIGN KEY (parent) REFERENCES Categories(name) ON DELETE CASCADE,
      FOREIGN KEY (child) REFERENCES SubCategories(name) ON DELETE CASCADE
    )
  ''';

  static const _createItemsForSubcategoryTable = '''
    CREATE TABLE IF NOT EXISTS ItemsForSubcategory (
      parent TEXT,
      child TEXT,
      PRIMARY KEY (parent, child),
      FOREIGN KEY (parent) REFERENCES SubCategories(name) ON DELETE CASCADE,
      FOREIGN KEY (child) REFERENCES Items(name) ON DELETE CASCADE
    )
  ''';

  static final TransactioRepositry _instance = TransactioRepositry._internal();
  static Database? _database;

  factory TransactioRepositry() => _instance;

  TransactioRepositry._internal();

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database ??= await _initDatabase();
    return _database!;
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
    await db.execute(_createTransactionTable);
    await db.execute(_createAccountsTable);
    await db.execute(_createSectionTable);
    await db.execute(_createCategoriesTable);
    await db.execute(_createSubCategoriesTable);
    await db.execute(_createItemsTable);
    await db.execute(_createSubcategoriesForCategoryTable);
    await db.execute(_createItemsForSubcategoryTable);
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

  Future<bool?> idExists(int id) async {
    final db = await database;
    final result = await db?.query(
      'Alldata',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result?.isNotEmpty;
  }

  Future<int> generateUniqueId() async {
    return IDGenerator.generateUniqueId((id) => idExists(id));
  }

  // Method to ensure database exists and is initialized
  Future<Database> ensureDatabase() async {
    final db = await database;
    if (db == null) {
      _database = await _initDatabase();
    }
    return _database!;
  }

  Future<void> resetDatabase() async {
    await closeDatabase();
    final String path = join(await getDatabasesPath(), 'expense_tracker.db');
    await deleteDatabase(path);
    _database = null;
  }
}
