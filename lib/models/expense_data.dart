class ExpenseData {
  final int? id;
  final String account;
  final String section;
  final String category;
  final String subCategory;
  final double amount;
  final String cd;
  final String note;
  final String date;
  final String quantity;
  final String price;
  final String tax;

  ExpenseData({
    this.id,
    required this.account,
    required this.section,
    required this.category,
    required this.subCategory,
    required this.amount,
    required this.cd,
    required this.note,
    required this.date,
    required this.quantity,
    required this.price,
    required this.tax,
  });

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
      'tax': tax,
    };
  }

  factory ExpenseData.fromMap(Map<String, dynamic> map) {
    return ExpenseData(
      id: map['id'],
      account: map['account'] ?? '',
      section: map['section'] ?? '',
      category: map['category'] ?? '',
      subCategory: map['subCategory'] ?? '',
      amount: double.tryParse(map['amount'].toString()) ?? 0.0,
      cd: map['cd'] ?? '',
      note: map['note'] ?? '',
      date: map['date'] ?? '',
      quantity: map['quantity']?.toString() ?? '',
      price: map['price']?.toString() ?? '',
      tax: map['tax']?.toString() ?? '',
    );
  }
}
