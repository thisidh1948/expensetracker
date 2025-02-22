// database_tables.dart
class DatabaseTables {
  static const createTransactionTable = '''
    CREATE TABLE IF NOT EXISTS Alldata (
      id INTEGER PRIMARY KEY,
      account TEXT NOT NULL,
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
    );
    CREATE INDEX IF NOT EXISTS idx_alldata_date ON Alldata(date DESC);
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
    );
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
      account TEXT,
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

  static const createLoansTable = '''
    CREATE TABLE IF NOT EXISTS Loans (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      loan_date TEXT NOT NULL,
      amount REAL NOT NULL,
      interest_rate REAL NOT NULL,
      status TEXT CHECK(status IN ('paid', 'unpaid')) NOT NULL,
      entityName TEXT,
      role TEXT CHECK(role IN ('giver', 'taker')) NOT NULL,
      purpose TEXT,
      remarks TEXT,
      CONSTRAINT entity_name_required CHECK (
        (role = 'taker' AND entityName IS NOT NULL) OR 
        (role = 'giver')
      )
    );
    CREATE INDEX IF NOT EXISTS idx_loans_date ON Loans(loan_date DESC);
    CREATE INDEX IF NOT EXISTS idx_loans_status ON Loans(status);
    CREATE INDEX IF NOT EXISTS idx_loans_role ON Loans(role);
  ''';

  static const insertDefaultAccounts = '''
    INSERT OR IGNORE INTO Accounts (name, icon, color) VALUES 
    ('AXIS', 'axis', '#f3218b'),
    ('SBI', 'sbi', '#2196F3'),
    ('BOI', 'boi', '#F44336'),
    ('UPILITE', 'googlepay', '#9C27B0'),
    ('UNION', 'union', '#607D8B')
  ''';
  static const insertDefaultSections = '''
    INSERT OR IGNORE INTO Sections (name, icon, color) VALUES 
    ('HOME', 'home', '#f3218b'),
    ('SELF', 'pay', '#2196F3'),
    ('BRO', 'idfc', '#F44336')
  ''';

  static const insertDefaultItems = '''
    INSERT OR IGNORE INTO Items (name, icon, color) VALUES ('anz', 'anz', '#2196f3'), ('upilite', 'googlepay', '#2196f3'),
    ('petrol', 'petrol', '#2196f3'),
    ('diesel', 'fuel', '#2196f3'),
    ('fire', 'fire', '#2196f3'),
    ('formals', 'clothing', '#2196f3'),
    ('biryani', 'curryrice', '#2196f3'),
    ('bus', 'bus', '#2196f3'),
    ('tomato', 'tomato', '#2196f3'),
    ('strawberry', 'strawberry', '#2196f3'),
    ('sandwich', 'sandwich', '#2196f3'),
    ('potatoes', 'potatoes', '#2196f3'),
    ('pizza', 'pizza', '#2196f3'),
    ('beer', 'beer', '#2196f3'),
    ('coke', 'coke', '#2196f3')
  ''';

  static const insertDefaultCategories = '''
    INSERT OR IGNORE INTO Categories (name, icon, color) VALUES 
    ('x_income', 'cash', '#FF4CAF50'),         
    ('tobacco', 'tobbaco', '#FF795548'),        
    ('pamoil', 'palmtree', '#FFFFA726'),     
    ('housing', 'home', '#FF9C27B0'),          
    ('food', 'dinning', '#FFF44336'),       
    ('vehicle', 'transport', '#FF2196F3'),           
    ('entertainment', 'film', '#FFFF4081'),    
    ('medical', 'tablets', '#FF00BCD4'),       
    ('travel', 'airticket', '#FF3F51B5'),         
    ('shopping', 'shoppingbag', '#FF9575CD'), 
    ('bills', 'bill', '#FFE91E63'),         
    ('investments', 'gold', '#FF66BB6A'), 
    ('itjob', 'computer', '#FF0288D1'),        
    ('misc', 'tag', '#FF757575')        
  ''';

  static const insertDefaultSubCategories = '''
    INSERT OR IGNORE INTO SubCategories (name, icon, color) VALUES 
    ('income', 'cash', '#FF81C784'),           
    ('land lease', 'land', '#FF8D6E63'),   
    ('pesticides', 'chemicals', '#FFFFB74D'), 
    ('fertilizers', 'fertilizer', '#FFBA68C8'),      
    ('workers', 'workers', '#FFE57373'),          
    ('pulla', 'leaves', '#FF64B5F6'),      
    ('akkukottu', 'tools', '#FFFF80AB'), 
    ('baran', 'worker', '#FF4DD0E1'),      
    ('rash', 'tree', '#FF7986CB'),           
    ('seedlings', 'tree', '#FFB39DDB'),       
    ('transport', 'transport', '#FFEC407A'), 
    ('cutting', 'cutting', '#FF81C784'),    
    ('maintenance', 'tools', '#FF42A5F5'),      
    ('construction', 'construction', '#FFAB47BC'), 
    ('electrical', 'lightbulb', '#FFE57373'), 
    ('electronics', 'electronics', '#FF64B5F6'),    
    ('furniture', 'home', '#FFFF80AB'),        
    ('groceries', 'groceries', '#FF4DD0E1'), 
    ('drinks', 'beverage', '#FF7986CB'),       
    ('fastfood', 'fries', '#FFB39DDB'),      
    ('restaurant', 'dinning', '#FFEC407A'),   
    ('xpulse', 'bike', '#FF81C784'),     
    ('241d', 'bike', '#FF42A5F5'),       
    ('hfdelux', 'bike', '#FFAB47BC'),    
    ('fuel', 'petrol', '#FFE57373'), 
    ('parking', 'car', '#FF64B5F6'),  
    ('insurance', 'bill', '#FFFF80AB'),     
    ('service', 'tools', '#FF4DD0E1'),          
    ('sports', 'essentials', '#FF7986CB'),          
    ('fire', 'fire', '#FFB39DDB'), 
    ('alcohol', 'beer', '#FFEC407A'),         
    ('subscriptions', 'bill', '#FF81C784'), 
    ('movies', 'film', '#FF42A5F5'),           
    ('trips', 'airticket', '#FFAB47BC'),      
    ('hobbies', 'essentials', '#FFE57373'),      
    ('medicines', 'tablets', '#FF64B5F6'),    
    ('appointments', 'bill', '#FFFF80AB'),      
    ('cab', 'cab', '#FF4DD0E1'),         
    ('bus', 'bus', '#FF7986CB'),      
    ('flight', 'airticket', '#FFB39DDB'),          
    ('train', 'train', '#FFEC407A'),            
    ('essentials', 'essentials', '#FF81C784'), 
    ('clothing', 'clothing', '#FF42A5F5'),     
    ('tools', 'tools', '#FFAB47BC'),         
    ('curiosities', 'essentials', '#FFE57373'),  
    ('homegoods', 'home', '#FF64B5F6'),         
    ('wifi', 'wifi', '#FFFF80AB'),              
    ('phone', 'bill', '#FF4DD0E1'),            
    ('tax', 'tax', '#FF7986CB'),       
    ('electricity', 'electricitybill', '#FFB39DDB'), 
    ('land', 'land', '#FFEC407A'),         
    ('fixeddeposits(fd)', 'cash', '#FF81C784'), 
    ('collections', 'essentials', '#FF42A5F5'), 
    ('stocks', 'transactions', '#FFAB47BC'),      
    ('mutualfunds', 'transactions', '#FFE57373'), 
    ('gold', 'gold', '#FFFFD700'),           
    ('silver', 'gold', '#FFC0C0C0'),         
    ('productivity', 'computer', '#FF64B5F6'), 
    ('unknown', 'tag', '#FF9E9E9E')            
  ''';

  static const insertDefaultSubcategoriesForCategory = '''
    INSERT OR IGNORE INTO SubcategoriesForCategory (parent, child) VALUES 
    -- X_INCOME subcategories
    ('x_income', 'income'),
    ('x_income', 'transport'),
    ('x_income', 'income'),

    -- TOBACCO subcategories
    ('tobacco', 'land lease'),
    ('tobacco', 'pesticides'),
    ('tobacco', 'fertilizers'),
    ('tobacco', 'workers'),
    ('tobacco', 'pulla'),
    ('tobacco', 'akkukottu'),
    ('tobacco', 'baran'),
    ('tobacco', 'rash'),
    ('tobacco', 'seedlings'),
    ('tobacco', 'transport'),
    ('tobacco', 'income'),

    -- PAMOIL subcategories
    ('pamoil', 'cutting'),
    ('pamoil', 'fertilizers'),
    ('pamoil', 'maintenance'),
    ('pamoil', 'workers'),
    ('pamoil', 'transport'),
    ('pamoil', 'income'),

    -- HOUSING subcategories
    ('housing', 'construction'),
    ('housing', 'electrical'),
    ('housing', 'workers'),
    ('housing', 'utilities'),
    ('housing', 'maintenance'),
    ('housing', 'transport'),
    ('housing', 'electronics'),
    ('housing', 'furniture'),

    -- FOOD subcategories
    ('food', 'groceries'),
    ('food', 'drinks'),
    ('food', 'fastfood'),
    ('food', 'restaurant'),
    ('food', 'transport'),

    -- VEHICLE subcategories
    ('vehicle', 'xpulse'),
    ('vehicle', '241d'),
    ('vehicle', 'hfdelux'),
    ('vehicle', 'fuel'),
    ('vehicle', 'maintenance'),
    ('vehicle', 'parking'),
    ('vehicle', 'insurance'),
    ('vehicle', 'service'),

    -- ENTERTAINMENT subcategories
    ('entertainment', 'sports'),
    ('entertainment', 'fire'),
    ('entertainment', 'alcohol'),
    ('entertainment', 'subscriptions'),
    ('entertainment', 'movies'),
    ('entertainment', 'trips'),
    ('entertainment', 'hobbies'),

    -- MEDICAL subcategories
    ('medical', 'medicines'),
    ('medical', 'appointments'),

    -- TRAVEL subcategories
    ('travel', 'cab'),
    ('travel', 'bus'),
    ('travel', 'flight'),
    ('travel', 'train'),

    -- SHOPPING subcategories
    ('shopping', 'essentials'),
    ('shopping', 'clothing'),
    ('shopping', 'tools'),
    ('shopping', 'electronics'),
    ('shopping', 'curiosities'),
    ('shopping', 'homegoods'),
    ('shopping', 'transport'),

    -- BILLS subcategories
    ('bills', 'wifi'),
    ('bills', 'phone'),
    ('bills', 'tax'),
    ('bills', 'electricity'),

    -- INVESTMENTS subcategories
    ('investments', 'land'),
    ('investments', 'fixeddeposits(fd)'),
    ('investments', 'collections'),
    ('investments', 'stocks'),
    ('investments', 'mutualfunds'),
    ('investments', 'gold'),
    ('investments', 'silver'),
    ('investments', 'income'),

    -- ITJOB subcategories
    ('itjob', 'income'),
    ('itjob', 'productivity'),
    ('itjob', 'tools'),
    ('itjob', 'wifi'),
    ('itjob', 'electronics'),

    -- MISC subcategories
    ('misc', 'unknown')
  ''';
}

class ATableNames {
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
  static const String loans = "Loans";
}