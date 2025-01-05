class Transaction {
  final int? id;
  final String bank;
  final String? section;
  final String category;
  final String subcategory;
  final String? item;
  final bool cd;  // true for Credit, false for Debit
  final double? units;
  final double? ppu;  // price per unit
  final double? tax;
  final double amount;
  final DateTime? createdAt;

  Transaction({
    this.id,
    required this.bank,
    this.section,
    required this.category,
    required this.subcategory,
    this.item,
    required this.cd,
    this.units,
    this.ppu,
    this.tax,
    required this.amount,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bank': bank,
      'section': section,
      'category': category,
      'subcategory': subcategory,
      'item': item,
      'cd': cd ? 1 : 0,  // Convert boolean to integer for SQLite
      'units': units,
      'ppu': ppu,
      'tax': tax,
      'amount': amount,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      bank: map['bank'],
      section: map['section'],
      category: map['category'],
      subcategory: map['subcategory'],
      item: map['item'],
      cd: map['cd'] == 1,  // Convert integer to boolean
      units: map['units']?.toDouble(),
      ppu: map['ppu']?.toDouble(),
      tax: map['tax']?.toDouble(),
      amount: map['amount']?.toDouble() ?? 0.0,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
    );
  }

  Transaction copyWith({
    int? id,
    String? bank,
    String? section,
    String? category,
    String? subcategory,
    String? item,
    bool? cd,
    double? units,
    double? ppu,
    double? tax,
    double? amount,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      bank: bank ?? this.bank,
      section: section ?? this.section,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      item: item ?? this.item,
      cd: cd ?? this.cd,
      units: units ?? this.units,
      ppu: ppu ?? this.ppu,
      tax: tax ?? this.tax,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
