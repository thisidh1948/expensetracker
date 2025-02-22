import 'package:flutter/material.dart';
import '../widgets/customIcons.dart';

class FieldIcon extends StatelessWidget {
  final String iconName;
  final double size;

  const FieldIcon({
    Key? key,
    required this.iconName,
    this.size = 24,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget? customIcon = CustomIcons.getIcon(iconName, size: size);
    
    if (customIcon == CustomIcons.getIcon('receipt', size: size)) {
      return Text(
        _getInitials(iconName),
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    
    return customIcon;
  }

  String _getInitials(String value) {
    final words = value.trim().split(' ');
    if (words.length > 1) {
      return (words[0][0] + words[1][0]).toUpperCase();
    }
    return words[0].length > 1 
        ? words[0].substring(0, 2).toUpperCase() 
        : words[0].toUpperCase();
  }
} 