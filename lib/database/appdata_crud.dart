import 'package:expense_tracker/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

import 'models/appdata.dart';

class AppDataCrud {
  final DatabaseHelper _db;

  AppDataCrud({DatabaseHelper? databaseHelper})
      : _db = databaseHelper ?? DatabaseHelper();

  // Create - Insert new record
  Future<void> insert(AppData data) async {
    final db = await _db.database;
    try {
      await db!.insert(
        'AppData',
        data.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw DatabaseException('Failed to insert AppData: $e');
    }
  }

  // Read - Get all records
  Future<List<AppData>> getAllData() async {
    final db = await _db.database;

    try {
      final List<Map<String, dynamic>> maps = await db!.query('AppData');
      return List.generate(maps.length, (i) => AppData.fromMap(maps[i]));
    } catch (e) {
      throw DatabaseException('Failed to get AppData: $e');
    }
  }

  // Read - Get records by category
  Future<List<AppData>> getByCategory(String category) async {
    try {
      final db = await _db.database;

      final List<Map<String, dynamic>> maps = await db!.query(
        'AppData',
        where: 'category = ?',
        whereArgs: [category],
      );
      return List.generate(maps.length, (i) => AppData.fromMap(maps[i]));
    } catch (e) {
      throw DatabaseException('Failed to get AppData by category: $e');
    }
  }

  // Read - Get specific record
  Future<AppData?> get(String category, String key) async {
    try {
      final db = await _db.database;

      final List<Map<String, dynamic>> maps = await db!.query(
        'AppData',
        where: 'category = ? AND key = ?',
        whereArgs: [category, key],
      );

      if (maps.isEmpty) return null;
      return AppData.fromMap(maps.first);
    } catch (e) {
      throw DatabaseException('Failed to get specific AppData: $e');
    }
  }

  // Update record - Insert if not exists
  Future<int> update(AppData data) async {
    try {
      final db = await _db.database;
      
      // First check if the record exists
      final List<Map<String, dynamic>> existing = await db!.query(
        'AppData',
        where: 'category = ? AND key = ?',
        whereArgs: [data.category, data.key],
      );

      if (existing.isEmpty) {
        // Record doesn't exist, perform insert
        await db.insert(
          'AppData',
          data.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        return 1; // Return 1 to indicate success
      } else {
        // Record exists, perform update
        return await db.update(
          'AppData',
          data.toMap(),
          where: 'category = ? AND key = ?',
          whereArgs: [data.category, data.key],
        );
      }
    } catch (e) {
      throw DatabaseException('Failed to update/insert AppData: $e');
    }
  }

  // Delete record
  Future<int> delete(String category, String key) async {
    final db = await _db.database;

    try {
      return await db!.delete(
        'AppData',
        where: 'category = ? AND key = ?',
        whereArgs: [category, key],
      );
    } catch (e) {
      throw DatabaseException('Failed to delete AppData: $e');
    }
  }

  // Delete all records in a category
  Future<int> deleteCategory(String category) async {
    final db = await _db.database;

    try {
      return await db!.delete(
        'AppData',
        where: 'category = ?',
        whereArgs: [category],
      );
    } catch (e) {
      throw DatabaseException('Failed to delete category: $e');
    }
  }
}

class DatabaseException implements Exception {
  final String message;

  DatabaseException(this.message);

  @override
  String toString() => message;
}
