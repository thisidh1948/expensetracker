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
      note TEXT,
      location TEXT
    );
    CREATE INDEX IF NOT EXISTS idx_alldata_date ON Alldata(date DESC);
  ''';

  static const createAccountsTable = '''
    CREATE TABLE IF NOT EXISTS Accounts (
      name TEXT PRIMARY KEY,
      icon TEXT,
      color TEXT NOT NULL DEFAULT '#FF000000',
      balance REAL
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
      color TEXT NOT NULL DEFAULT '#FF000000',
      label TEXT
    )
  ''';

  static const createSubCategoriesTable = '''
    CREATE TABLE IF NOT EXISTS SubCategories (
      name TEXT PRIMARY KEY,
      icon TEXT,
      color TEXT NOT NULL DEFAULT '#FF000000',
      label TEXT
    )
  ''';

  static const createItemsTable = '''
    CREATE TABLE IF NOT EXISTS Items (
      name TEXT PRIMARY KEY,
      icon TEXT,
      color TEXT NOT NULL DEFAULT '#FF000000',
      label TEXT
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
    CREATE INDEX IF NOT EXISTS idx_loans_status ON Loans(status);
    CREATE INDEX IF NOT EXISTS idx_loans_role ON Loans(role);
  ''';

  static const createLabelsTable = '''
    CREATE TABLE IF NOT EXISTS Labels (
      name TEXT PRIMARY KEY,
      icon TEXT,
      color TEXT NOT NULL DEFAULT '#FF000000',
      label TEXT
    )
  ''';

  static const insertDefaultAccounts = '''
    INSERT OR IGNORE INTO Accounts (name, icon, color, balance) VALUES 
    ('axis', 'axis', '#f3218b', 618708.24),
    ('sbi', 'sbi', '#2196F3', 486023.30),
    ('boi', 'boi', '#F44336', 1285.31),
    ('upilite', 'googlepay', '#9C27B0', 1677.00),
    ('union', 'union', '#607D8B', 21446.65),
    ('cggbdad', 'cggb', '#607D8B', 181837.9),
    ('cggbmom', 'cggb', '#607D8B', 300000.00),
    ('union', 'union', '#607D8B', 21446.65),
    ('cash', 'cash', '#4CAF50', 21700.00)
  ''';

  static const insertDefaultSections = '''
    INSERT OR IGNORE INTO Sections (name, icon, color) VALUES 
    ('home', 'home', '#f3218b'),
    ('self', 'man3', '#2196F3'),
    ('bro', 'man', '#F44336')
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
    ('misc', 'tag', '#FF757575'),
    ('xpulse', 'bike', '#FF81C784'),     
    ('241d', 'tractor', '#FF42A5F5'),       
    ('hfdelux', 'hf', '#FFAB47BC'),        
    ('debt', 'loan', '#FFAB47BC'),        
    ('lent', 'lent', '#FFAB47BC'),        
    ('accomidation', 'accomidation', '#FFAB47BC'),        
    ('charity', 'charity', '#FFAB47BC')     
  ''';

  static const insertDefaultSubCategories = '''
  INSERT OR IGNORE INTO SubCategories (name, icon, color) VALUES
  ('akkukottu', 'leaves', '#FFFF80AB'),
  ('alcohol', 'beer', '#FFEC407A'),
  ('appointments', 'bill', '#FFFF80AB'),
  ('appliances', 'appliances', '#FFFF80AB'),
  ('baran', 'worker', '#FF4DD0E1'),
  ('bill', 'bill', '#FFFF80AB'),
  ('bus', 'bus', '#FF7986CB'),
  ('close', 'closed', '#FF7986CB'),
  ('clothing', 'clothing', '#2196f3'),
  ('cab', 'cab', '#FF4DD0E1'),
  ('collections', 'essentials', '#FF42A5F5'),
  ('construction', 'construction', '#FFAB47BC'),
  ('curiosities', 'essentials', '#FFE57373'),
  ('cutting', 'cutting', '#FF81C784'),
  ('drinks', 'beverage', '#FF7986CB'),
  ('drip', 'tools', '#FF7986CB'),
  ('electronics', 'electronics', '#FF64B5F6'),
  ('electrical', 'lightbulb', '#FFE57373'),
  ('engine oil', 'oiler', '#FF42A5F5'),
  ('essentials', 'essentials', '#FF81C784'),
  ('fastfood', 'fries', '#FFB39DDB'),
  ('fertilizers', 'fertilizer', '#FFBA68C8'),
  ('fire', 'fire', '#FFB39DDB'),
  ('fine', 'fine', '#FFB39DDB'),
  ('fixeddeposit', 'deposit', '#FF81C784'),
  ('flight', 'flight', '#FF7986CB'),
  ('footwear', 'shoes', '#FF7986CB'),
  ('furniture', 'furniture', '#FFFF80AB'),
  ('fuel', 'petrol', '#FFE57373'),
  ('gas', 'cylinder', '#FFE57373'),
  ('gold', 'gold', '#FFFFD700'),
  ('groceries', 'groceries', '#FF4DD0E1'),
  ('hobbies', 'essentials', '#FFE57373'),
  ('income', 'cash', '#FF81C784'),
  ('insurance', 'insurance', '#FFFF80AB'),
  ('installment', 'installment', '#FFFF80AB'),
  ('land lease', 'land', '#FF8D6E63'),
  ('land', 'land', '#FFEC407A'),
  ('maintenance', 'tools', '#FF42A5F5'),
  ('medicines', 'tablets', '#FF64B5F6'),
  ('movies', 'film', '#FF42A5F5'),
  ('mutualfunds', 'stocks', '#FFE57373'),
  ('open', 'loanopen', '#FFE57373'),
  ('pending', 'loanopen', '#FFE57373'),
  ('pesticides', 'chemicals', '#FFFFB74D'),
  ('phone', 'bill', '#FF4DD0E1'),
  ('productivity', 'idea', '#FF64B5F6'),
  ('pulla', 'wood', '#FF64B5F6'),
  ('purchase', 'wood', '#FF64B5F6'),
  ('rash', 'leaves', '#FF7986CB'),
  ('rent', 'rent', '#FF7986CB'),
  ('rentalhouse', 'rent', '#FF7986CB'),
  ('restaurant', 'dinning', '#FFEC407A'),
  ('seedlings', 'sprout', '#FFB39DDB'),
  ('service', 'tools', '#FF4DD0E1'),
  ('silver', 'silver', '#FFC0C0C0'),
  ('spares', 'spares', '#FF81C784'),
  ('sports', 'sports', '#FF7986CB'),
  ('stocks', 'stocks', '#FFAB47BC'),
  ('subscriptions', 'pin', '#FF81C784'),
  ('tax', 'tax', '#FF7986CB'),
  ('tools', 'tools', '#FFAB47BC'),
  ('train', 'train', '#FFEC407A'),
  ('transport', 'transport', '#FFEC407A'),
  ('trips', 'airticket', '#FFAB47BC'),
  ('unknown', 'unknown', '#FF9E9E9E'),
  ('utilities', 'utilities', '#FFB39DDB'),
  ('useless', 'help', '#FFB39DDB'),
  ('wifi', 'wifi', '#FFFF80AB'),
  ('workers', 'workers', '#FFE57373')
''';

  static const insertDefaultSubcategoriesForCategory = '''
    INSERT OR IGNORE INTO SubcategoriesForCategory (parent, child) VALUES 
    -- X_INCOME subcategories
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
    ('tobacco', 'drip'),

    -- PAMOIL subcategories
    ('pamoil', 'cutting'),
    ('pamoil', 'fertilizers'),
    ('pamoil', 'maintenance'),
    ('pamoil', 'workers'),
    ('pamoil', 'transport'),
    ('pamoil', 'income'),
    ('pamoil', 'drip'),
    

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
    ('xpulse', 'spares'),
    ('xpulse', 'fuel'),
    ('xpulse', 'maintenance'),
    ('xpulse', 'parking'),
    ('xpulse', 'insurance'),
    ('xpulse', 'service'),
    ('xpulse', 'engine oil'),
    ('xpulse', 'parking'),
    ('xpulse', 'tax'),
    ('xpulse', 'fine'),
    ('xpulse', 'purchase'),
    ('hfdelux', 'spares'),
    ('hfdelux', 'fuel'),
    ('hfdelux', 'maintenance'),
    ('hfdelux', 'parking'),
    ('hfdelux', 'insurance'),
    ('hfdelux', 'service'),
    ('hfdelux', 'engine oil'),
    ('hfdelux', 'parking'),
    ('hfdelux', 'tax'),
    ('hfdelux', 'fine'),
    ('241d', 'spares'),
    ('241d', 'fuel'),
    ('241d', 'maintenance'),
    ('241d', 'parking'),
    ('241d', 'insurance'),
    ('241d', 'service'),
    ('241d', 'engine oil'),
    ('241d', 'parking'),
    ('241d', 'tax'),
    ('241d', 'fine'),

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
    ('medical', 'bill'),

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
    ('shopping', 'appliances'),
    ('shopping', 'footwear'),
    ('shopping', 'collections'),
    ('shopping', 'transport'),

    -- BILLS subcategories
    ('bills', 'wifi'),
    ('bills', 'phone'),
    ('bills', 'tax'),
    ('bills', 'electricity'),
    ('bills', 'gas'),

    -- INVESTMENTS subcategories
    ('investments', 'land'),
    ('investments', 'fixeddeposit'),
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
    ('misc', 'unknown'),
    
    ('lent', 'open'),
    ('lent', 'close'),
    ('lent', 'installment'),
   
    ('debt', 'open'),
    ('debt', 'installment'),
    ('debt', 'close'),
    
    ('accomidation', 'hotel'),
    ('accomidation', 'rent'),
    ('charity', 'useless')
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

  static const insertDefaultLabels = '''
    INSERT OR IGNORE INTO Labels (name, icon, color) VALUES 
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
    ('others', 'others', '#FF000000')
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
  static const String labels = "Labels";
}
