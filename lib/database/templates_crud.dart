
import 'package:expense_tracker/database/database_helper.dart';
import 'package:expense_tracker/database/models/template_model.dart';
import 'package:sqflite/sqflite.dart';

class Templates_crud {
  final DatabaseHelper database;

  Templates_crud({DatabaseHelper? databaseHelper})
      : database = databaseHelper ?? DatabaseHelper();

  // Create
  Future<void> insertTemplate(Template template) async {
    final db = await database.database;
    await db!.insert(
      'Templates',
      template.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Read
  Future<Template?> getTemplate(String tName) async {
    final db = await database.database;

    final List<Map<String, dynamic>> maps = await db!.query(
      'Templates',
      where: 'TName = ?',
      whereArgs: [tName],
    );

    if (maps.isEmpty) return null;
    return Template.fromMap(maps.first);
  }

  Future<List<Template>> getAllTemplates() async {
    final db = await database.database;

    final List<Map<String, dynamic>> maps = await db!.query('Templates');
    print("data:67898000");
    print(maps.toString());
    return List.generate(maps.length, (i) => Template.fromMap(maps[i]));
  }

  // Update
  Future<int> updateTemplate(Template template) async {
    final db = await database.database;
    return await db!.update(
      'Templates',
      template.toMap(),
      where: 'TName = ?',
      whereArgs: [template.tName],
    );
  }

  // Delete
  Future<int> deleteTemplate(String tName) async {
    final db = await database.database;

    return await db!.delete(
      'Templates',
      where: 'TName = ?',
      whereArgs: [tName],
    );
  }

  // Additional useful queries

  Future<List<Template>> getTemplatesByAccount(String account) async {
    final db = await database.database;

    final List<Map<String, dynamic>> maps = await db!.query(
      'Templates',
      where: 'account = ?',
      whereArgs: [account],
    );
    return List.generate(maps.length, (i) => Template.fromMap(maps[i]));
  }

  Future<List<Template>> getTemplatesBySection(String section) async {
    final db = await database.database;
    final List<Map<String, dynamic>> maps = await db!.query(
      'Templates',
      where: 'section = ?',
      whereArgs: [section],
    );
    return List.generate(maps.length, (i) => Template.fromMap(maps[i]));
  }

  // Search templates
  Future<List<Template>> searchTemplates(String query) async {
    final db = await database.database;
    final List<Map<String, dynamic>> maps = await db!.query(
      'Templates',
      where: 'TName LIKE ? OR account LIKE ? OR section LIKE ? OR category LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) => Template.fromMap(maps[i]));
  }
}
