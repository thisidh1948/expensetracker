import 'dart:io';
import 'package:expense_tracker/database/database_tables.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../screens/utils/id_generator.dart';


class DatabaseHelper {

  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

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
    await db.execute(DatabaseTables.createTransactionTable);
    await db.execute(DatabaseTables.createAccountsTable);
    await db.execute(DatabaseTables.createSectionTable);
    await db.execute(DatabaseTables.createCategoriesTable);
    await db.execute(DatabaseTables.createSubCategoriesTable);
    await db.execute(DatabaseTables.createItemsTable);
    await db.execute(DatabaseTables.createSubcategoriesForCategoryTable);
    await db.execute(DatabaseTables.createItemsForSubcategoryTable);
    await db.execute(DatabaseTables.createTemplatesTable);
    await db.execute(DatabaseTables.createAppDataTable);
    await db.execute(DatabaseTables.createLoansTable);

    await db.execute(DatabaseTables.insertDefaultAccounts);
    await db.execute(DatabaseTables.insertDefaultSections);
    await db.execute(DatabaseTables.insertDefaultItems);
    await db.execute(DatabaseTables.insertDefaultCategories);
    await db.execute(DatabaseTables.insertDefaultSubCategories);
    await db.execute(DatabaseTables.insertDefaultSubcategoriesForCategory);
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
