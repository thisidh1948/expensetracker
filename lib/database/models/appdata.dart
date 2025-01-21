class AppData {
  final String category;
  final String key;
  final String value;

  AppData({
    required this.category,
    required this.key,
    required this.value,
  });

  // Convert AppData instance to a Map
  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'key': key,
      'value': value,
    };
  }

  // Create AppData instance from a Map
  factory AppData.fromMap(Map<String, dynamic> map) {
    return AppData(
      category: map['category'],
      key: map['key'],
      value: map['value'],
    );
  }
}