// base_entity.dart
import '../database_tables.dart';

class StructModel {
  final String name;
  final String? icon;
  final String? color;
  final double? balance;
  final String? label;

  StructModel({
    required this.name,
    this.icon,
    this.color,
    this.balance,
    this.label,
  });

  Map<String, dynamic> toMap([String? tableType]) {
    switch (tableType) {
      case ATableNames.accounts:
        return {
          'name': name,
          'icon': icon,
          'color': color,
          'balance': balance ?? 0.0,
        };
      case ATableNames.sections:
        return {
          'name': name,
          'icon': icon,
          'color': color,
        };
      default:
        return {
          'name': name,
          'icon': icon,
          'color': color,
          'label': label,
        };
    }
  }

  factory StructModel.fromMap(Map<String, dynamic> map) {
    return StructModel(
      name: map['name'] ?? '',
      icon: map['icon'],
      color: map['color'],
      balance: map['balance'],
      label: map['label'],
    );
  }
}
