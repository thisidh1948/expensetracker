import 'database_helper.dart';
import 'models/mapping_model.dart';
import 'models/struct_model.dart';

class StructuresCRUD {
  final TransactioRepositry _db;

  StructuresCRUD({TransactioRepositry? databaseHelper})
      : _db = databaseHelper ?? TransactioRepositry();

  // Account operations
  Future<void> insert(String tableName, StructModel entity) async {
    final db = await _db.database;
    await db!.insert(tableName, entity.toMap());
  }

  Future<List<StructModel>> getAllTableData(String tableName) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps = await db!.query(tableName);
    return List.generate(maps.length, (i) => StructModel.fromMap(maps[i]));
  }

  Future<List<String>> getAllNames(String tableName) async {
    final db = await _db.database;

    final List<Map<String, dynamic>> maps = await db!.query(
      tableName,
      columns: ['name'],
    );
    return maps.map((map) => map['name'] as String).toList();
  }

  Future<void> update(String tableName, StructModel entity) async {
    final db = await _db.database;
    await db!.update(
      tableName,
      entity.toMap(),
      where: 'name = ?',
      whereArgs: [entity.name],
    );
  }

  Future<void> delete(String tableName, String name) async {
    final db = await _db.database;
    await db!.delete(tableName, where: 'name = ?', whereArgs: [name]);
  }

  // Mapping operations
  Future<void> insertSubcategoryForCategory(
      String category, String subCategory) async {
    final db = await _db.database;

    final List<Map<String, dynamic>> existing = await db!.query(
      'SubcategoriesForCategory',
      where: 'parent = ? AND child = ?',
      whereArgs: [category, subCategory],
    );

    if (existing.isNotEmpty) {
      return;
    }

    await db.insert('SubcategoriesForCategory', {
      'parent': category,
      'child': subCategory,
    });
  }

  Future<void> insertItemForSubcategory(String subCategory, String item) async {
    final db = await _db.database;

    final List<Map<String, dynamic>> existing = await db!.query(
      'ItemsForSubcategory',
      where: 'parent = ? AND child = ?',
      whereArgs: [subCategory, item],
    );

    if (existing.isNotEmpty) {
      return;
    }

    await db.insert('ItemsForSubcategory', {
      'parent': subCategory,
      'child': item,
    });
  }

  Future<void> deleteItemForSubcategory(String subCategory, String item) async {
    final db = await _db.database;
    await db!.delete(
      'ItemsForSubcategory',
      where: 'parent = ? AND child = ?',
      whereArgs: [subCategory, item],
    );
  }

  Future<void> deleteSubcategoryForCategory(
      String category, String subCategory) async {
    final db = await _db.database;
    await db!.delete(
      'SubcategoriesForCategory',
      where: 'parent = ? AND child = ?',
      whereArgs: [category, subCategory],
    );
  }

  Future<List<MappingModel>> getSubCategoriesForCategory(
      String categoryName) async {
    try {
      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db!.rawQuery('''
      SELECT * FROM SubcategoriesForCategory WHERE parent = ?
    ''', [categoryName]);
      return List.generate(maps.length, (i) => MappingModel.fromMap(maps[i]));
    } catch (e) {
      print('Error in getSubCategoriesForCategory: $e');
      return [];
    }
  }

  Future<List<MappingModel>> getItemsForSubcategory(
      String subcategoryName) async {
    try {
      final db = await _db.database;
      final List<Map<String, dynamic>> maps = await db!.rawQuery('''
      SELECT * FROM ItemsForSubcategory WHERE parent = ?
    ''', [subcategoryName]);
      return List.generate(maps.length, (i) => MappingModel.fromMap(maps[i]));
    } catch (e) {
      print('Error in getItemsForSubcategory: $e');
      return [];
    }
  }
}
