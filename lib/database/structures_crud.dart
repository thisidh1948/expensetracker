import 'database_helper.dart';
import 'database_tables.dart';
import 'models/mapping_model.dart';
import 'models/struct_model.dart';

class StructuresCRUD {
  final DatabaseHelper _db;

  StructuresCRUD({DatabaseHelper? databaseHelper})
      : _db = databaseHelper ?? DatabaseHelper();

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

  Future<Map<String, Map<String, String>>> getAllStructureIcons() async {
    final db = await _db.database;
    Map<String, Map<String, String>> result = {
      'accounts': {},
      'category': {},
      'subcategory': {},
      'items': {},
    };

    // Get icons from accounts table
    final List<Map<String, dynamic>> accountMaps = await db!.query(
      ATableNames.accounts,
      columns: ['name', 'icon'],
    );
    result['accounts'] = Map.fromEntries(accountMaps
        .map((map) => MapEntry(map['name'] as String, map['icon'] as String)));

    // Get icons from category table
    final List<Map<String, dynamic>> categoryMaps = await db.query(
      ATableNames.categories,
      columns: ['name', 'icon'],
    );
    result['category'] = Map.fromEntries(categoryMaps
        .map((map) => MapEntry(map['name'] as String, map['icon'] as String)));

    // Get icons from subcategory table
    final List<Map<String, dynamic>> subcategoryMaps = await db.query(
      ATableNames.subCategories,
      columns: ['name', 'icon'],
    );
    result['subcategory'] = Map.fromEntries(subcategoryMaps
        .map((map) => MapEntry(map['name'] as String, map['icon'] as String)));

    // Get icons from items table
    final List<Map<String, dynamic>> itemMaps = await db.query(
      ATableNames.items,
      columns: ['name', 'icon'],
    );
    result['items'] = Map.fromEntries(itemMaps
        .map((map) => MapEntry(map['name'] as String, map['icon'] as String)));

    return result;
  }
}
