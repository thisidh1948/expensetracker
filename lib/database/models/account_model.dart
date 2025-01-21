// base_entity.dart
class AccountModel {
  final String name;
  final String? icon;
  final double balance;
  final String? color;

  AccountModel(
      {required this.name, this.icon, required this.balance, this.color});

  Map<String, dynamic> toMap() {
    return {'name': name, 'icon': icon, 'balance': balance, 'color': color};
  }

  factory AccountModel.fromMap(Map<String, dynamic> map) {
    return AccountModel(
        name: map['name'] ?? '',
        icon: map['icon'],
        balance: map['balance'] ?? 0.0,
        color: map['color']);
  }

  String get formattedBalance {
    // Format with Indian Rupee symbol and 2 decimal places
    return '₹${balance.toStringAsFixed(2)}';
  }
}
