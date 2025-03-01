// template_model.dart
import 'dbtransaction.dart';

class Template {
  final String tName;
  final String? account;
  final String? section;
  final String? category;
  final String? subcategory;
  final String? item;
  final bool cd;
  final double? tax;
  final String? note;
  final String? icon;
  final String color;

  Template({
    required this.tName,
    this.account,
    this.section,
    this.category,
    this.subcategory,
    this.item,
    required this.cd,
    this.tax,
    this.note,
    this.icon,
    this.color = '#FF000000',
  });

  Map<String, dynamic> toMap() {
    return {
      'TName': tName,
      'account': account,
      'section': section,
      'category': category,
      'subcategory': subcategory,
      'item': item,
      'cd': cd ? 1 : 0,
      'tax': tax,
      'note': note,
      'icon': icon,
      'color': color,
    };
  }

  Template copyWith({
    String? tName,
    String? account,
    String? section,
    String? category,
    String? subcategory,
    String? item,
    bool? cd,
    double? tax,
    String? note,
    String? icon,
    String? color,
  }) {
    return Template(
      tName: tName ?? this.tName,
      account: account ?? this.account,
      section: section ?? this.section,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      item: item ?? this.item,
      cd: cd ?? this.cd,
      tax: tax ?? this.tax,
      note: note ?? this.note,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }

  factory Template.fromMap(Map<String, dynamic> map) {
    return Template(
      tName: map['TName'] ?? '',
      account: map['account'],
      section: map['section'],
      category: map['category'],
      subcategory: map['subcategory'],
      item: map['item'],
      cd: map['cd'] == 1,
      tax: map['tax']?.toDouble(),
      note: map['note'],
      icon: map['icon'],
      color: map['color'] ?? '#FF000000', // Default color if not provided
    );
  }

  DbTransaction toDbTransaction() {
    return DbTransaction(
      account: account ?? '',
      section: section ?? '',
      category: category ?? '',
      subcategory: subcategory ?? '',
      item: item ?? '',
      cd: cd,
      tax: tax,
      note: note,
      date: DateTime.now(),
      amount: 0.0, // Default amount
    );
  }
}
