// database_tables.dart
class DatabaseTables {
  static const createTransactionTable = '''
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

  static const createAccountsTable = '''
    CREATE TABLE IF NOT EXISTS Accounts (
      name TEXT PRIMARY KEY,
      icon TEXT,
      color TEXT NOT NULL DEFAULT '#FF000000'
    )
  ''';

  static const createAppDataTable = '''
    CREATE TABLE IF NOT EXISTS AppData (
      category TEXT NOT NULL,
      key TEXT NOT NULL,
      value TEXT NOT NULL,
      PRIMARY KEY (category, key, value)
    )
  ''';

  static const createSectionTable = '''
    CREATE TABLE IF NOT EXISTS Sections (
      name TEXT PRIMARY KEY,
      icon TEXT,
      color TEXT NOT NULL DEFAULT '#FF000000'
    )
  ''';

  static const createCategoriesTable = '''
    CREATE TABLE IF NOT EXISTS Categories (
      name TEXT PRIMARY KEY,
      icon TEXT,
      color TEXT NOT NULL DEFAULT '#FF000000'
    )
  ''';

  static const createSubCategoriesTable = '''
    CREATE TABLE IF NOT EXISTS SubCategories (
      name TEXT PRIMARY KEY,
      icon TEXT,
      color TEXT NOT NULL DEFAULT '#FF000000'
    )
  ''';

  static const createItemsTable = '''
    CREATE TABLE IF NOT EXISTS Items (
      name TEXT PRIMARY KEY,
      icon TEXT,
      color TEXT NOT NULL DEFAULT '#FF000000'
    )
  ''';

  static const createSubcategoriesForCategoryTable = '''
    CREATE TABLE IF NOT EXISTS SubcategoriesForCategory (
      parent TEXT,
      child TEXT,
      PRIMARY KEY (parent, child),
      FOREIGN KEY (parent) REFERENCES Categories(name) ON DELETE CASCADE,
      FOREIGN KEY (child) REFERENCES SubCategories(name) ON DELETE CASCADE
    )
  ''';

  static const createItemsForSubcategoryTable = '''
    CREATE TABLE IF NOT EXISTS ItemsForSubcategory (
      parent TEXT,
      child TEXT,
      PRIMARY KEY (parent, child),
      FOREIGN KEY (parent) REFERENCES SubCategories(name) ON DELETE CASCADE,
      FOREIGN KEY (child) REFERENCES Items(name) ON DELETE CASCADE
    )
  ''';

  static const createTemplatesTable = '''
    CREATE TABLE IF NOT EXISTS Templates (
      TName TEXT PRIMARY KEY,
      Account TEXT,
      section TEXT,
      category TEXT,
      subcategory TEXT,
      item TEXT,
      cd INTEGER NOT NULL,
      tax REAL,
      note TEXT,
      icon TEXT,
      color TEXT NOT NULL DEFAULT '#FF000000'
    )
  ''';
}

class Table {
  static const String alldata = "Alldata";
  static const String accounts = "Accounts";
  static const String appData = "AppData";
  static const String sections = "Sections";
  static const String categories = "Categories";
  static const String subCategories = "SubCategories";
  static const String items = "Items";
  static const String subcategoriesForCategory = "SubcategoriesForCategory";
  static const String itemsForSubcategory = "ItemsForSubcategory";
  static const String templates = "Templates";
}