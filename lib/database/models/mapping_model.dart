class   MappingModel {
  final String parent;
  final String child;

  MappingModel({
    required this.parent,
    required this.child,
  });

  factory MappingModel.fromMap(Map<String, dynamic> map) {
    return MappingModel(
      parent: map['parent']?.toString() ?? '',  // Handle null values
      child: map['child']?.toString() ?? '',    // Handle null values
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'parent': parent,
      'child': child,
    };
  }
}