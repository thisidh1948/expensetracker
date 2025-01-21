// base_entity.dart
class StructModel {
  final String name;
  final String? icon;
  final String? color;

  StructModel({
    required this.name,
    this.icon,
    this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
      'color': color,
    };
  }

  factory StructModel.fromMap(Map<String, dynamic> map) {
    return StructModel(
      name: map['name'] ?? '',
      icon: map['icon'],
      color: map['color'],
    );
  }
}
