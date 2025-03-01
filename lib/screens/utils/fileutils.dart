import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class FileUtils {
  static Future<void> saveCSVFile(BuildContext context, String csvContent, String fileName) async {
    try {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No directory selected'), backgroundColor: Colors.red),
        );
        return;
      }

      final timestamp = DateTime.now().toString().replaceAll(RegExp(r'[^0-9]'), '');
      final filePath = '$selectedDirectory/$fileName\_$timestamp.csv';

      final file = File(filePath);
      await file.writeAsString(csvContent);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CSV file saved to: $filePath'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save file: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }
}