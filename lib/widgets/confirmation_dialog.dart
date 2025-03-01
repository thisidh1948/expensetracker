import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;

  const ConfirmationDialog({
    Key? key,
    required this.title,
    required this.content,
    required this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
      content: Text(
        content,
        style: TextStyle(
          fontSize: 16,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey, textStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            color: Colors.red,
            ),
          ),
          child: const Text('Cancel', style: TextStyle(
            color: Colors.redAccent,
          ),),
        ),
        ElevatedButton(
          onPressed: () {
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            textStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: const Text('OK', style: TextStyle(
            color: Colors.greenAccent,
          ),),
        ),
      ],
    );
  }
}