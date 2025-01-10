// base_entity.dart
class AccountModel {
  final String name;
  final String? icon;
  final double balance;

  AccountModel({required this.name, this.icon, required this.balance});

  Map<String, dynamic> toMap() {
    return {'name': name, 'icon': icon, 'balance': balance};
  }

  factory AccountModel.fromMap(Map<String, dynamic> map) {
    return AccountModel(
        name: map['name'] ?? '',
        icon: map['icon'],
        balance: map['balance'] ?? 0.0);
  }

  String get formattedBalance {
    // Format with Indian Rupee symbol and 2 decimal places
    return '₹${balance.toStringAsFixed(2)}';
  }
}
