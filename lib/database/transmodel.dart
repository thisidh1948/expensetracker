class TransModel {
  int? id;
  String? account;
  String section;
  String? category;
  String? subCategory;
  double amount;
  String? cd; // Credit or Debit
  String? note;
  String date;
  int? quantity;
  int? price;
  int? tax;

  TransModel({
    this.id,
    required this.account,
    required this.section,
    this.category,
    this.subCategory,
    required this.amount,
    required this.cd,
    this.note,
    required this.date,
    this.quantity,
    this.price,
    this.tax
  });

  // Convert a TransModel object into a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'account': account,
      'section': section,
      'category': category,
      'subCategory': subCategory,
      'amount': amount,
      'cd': cd,
      'note': note,
      'date': date,
      'quantity': quantity,
      'price': price,
      'tax': tax
    };
  }

  // Convert a Map into a TransModel object
  factory TransModel.fromMap(Map<String, dynamic> map) {
    return TransModel(
      id: map['id'],
      account: map['account'],
      section: map['section'],
      category: map['category'],
      subCategory: map['subCategory'],
      amount: map['amount'],
      cd: map['cd'],
      note: map['note'],
      date: map['date'],
      quantity: map['quantity'],
      price: map['price'],
      tax: map['tax']
    );
  }
}
