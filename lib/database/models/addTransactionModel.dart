class Items {
  final String? item;
  final double? units;
  final double? ppu;
  final double? tax;
  final double? amount;

  Items({this.item, this.units, this.ppu, this.amount, this.tax});
}

class AddTransactions {
  final int? id;
  final String account;
  final String? section;
  final String category;
  final String subcategory;
  final bool cd;
  final DateTime? date;
  final String? note;
  final List<Items>? items;

  AddTransactions(
      {this.id,
      required this.account,
      this.section,
      required this.category,
      required this.subcategory,
      required this.cd,
      this.date,
      this.note,
      this.items});
}
