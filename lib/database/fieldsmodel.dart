import 'package:flutter/material.dart';

class FieldModel {
  final String name;
  final IconData? icon;

  FieldModel({required this.name, this.icon});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon?.codePoint,
    };
  }

  factory FieldModel.fromMap(Map<String, dynamic> map) {
    return FieldModel(
      name: map['name'],
      icon: map['icon'] != null ? IconData(map['icon'], fontFamily: 'MaterialIcons') : null,
    );
  }
}
