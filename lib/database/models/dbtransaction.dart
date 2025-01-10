class DbTransaction {
  final int? id;
  final String account;
  final String? section;
  final String category;
  final String subcategory;
  final String? item;
  final bool cd; // true for Credit, false for Debit
  final double? units;
  final double? ppu; // price per unit
  final double? tax;
  final double amount;
  final DateTime? date;
  final String? note;

  DbTransaction({
    this.id,
    required this.account,
    this.section,
    required this.category,
    required this.subcategory,
    this.item,
    required this.cd,
    this.units,
    this.ppu,
    this.tax,
    required this.amount,
    this.date,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'account': account,
      'section': section,
      'category': category,
      'subcategory': subcategory,
      'item': item,
      'cd': cd ? 1 : 0, // Convert boolean to integer for SQLite
      'units': units,
      'ppu': ppu,
      'tax': tax,
      'amount': amount,
      'date': date?.toIso8601String(),
      'note': note,
    };
  }

  factory DbTransaction.fromMap(Map<String, dynamic> map) {
    return DbTransaction(
      id: map['id'],
      account: map['Account'],
      section: map['section'],
      category: map['category'],
      subcategory: map['subcategory'],
      item: map['item'],
      cd: map['cd'] == 1,
      // Convert integer to boolean
      units: map['units']?.toDouble(),
      ppu: map['ppu']?.toDouble(),
      tax: map['tax']?.toDouble(),
      amount: map['amount']?.toDouble() ?? 0.0,
      date: map['date'] != null ? DateTime.parse(map['date']) : null,
      note: map['note'],
    );
  }

  DbTransaction copyWith({
    int? id,
    String? account,
    String? section,
    String? category,
    String? subcategory,
    String? item,
    bool? cd,
    double? units,
    double? ppu,
    double? tax,
    double? amount,
    DateTime? date,
    String? note,
  }) {
    return DbTransaction(
        id: id ?? this.id,
        account: account ?? this.account,
        section: section ?? this.section,
        category: category ?? this.category,
        subcategory: subcategory ?? this.subcategory,
        item: item ?? this.item,
        cd: cd ?? this.cd,
        units: units ?? this.units,
        ppu: ppu ?? this.ppu,
        tax: tax ?? this.tax,
        amount: amount ?? this.amount,
        date: date ?? this.date,
        note: note ?? this.note);
  }
}
