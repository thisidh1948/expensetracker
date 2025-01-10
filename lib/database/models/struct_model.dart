// base_entity.dart
class StructModel {
  final String name;
  final String? icon;

  StructModel({
    required this.name,
    this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
    };
  }

  factory StructModel.fromMap(Map<String, dynamic> map) {
    return StructModel(
    name: map['name'] ?? '',
    icon: map['icon'],
    );
  }
}
