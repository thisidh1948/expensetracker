import 'package:expense_tracker/database/models/appdata.dart';
import 'package:flutter/material.dart';

import '../../database/appdata_crud.dart';
import '../../database/database_tables.dart';
import '../../database/models/struct_model.dart';
import '../../database/structures_crud.dart';
import '../../widgets/color_picker_widget.dart';
import '../../widgets/iconpicker_widget.dart';

class CommonAddDialog {
  static Future<void> showStructureDialog({
    required BuildContext context,
    required String structureType,
    StructModel? existingData,
    String? title,
    String? labelText,
    String? hintText,
  }) async {
    final bool isUpdate = existingData != null;
    final nameController =
        TextEditingController(text: existingData?.name ?? '');
    final balanceController =
        TextEditingController(text: existingData?.balance?.toString() ?? '');
    final labelController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    // Initialize color
    Color selectedColor = isUpdate
        ? Color(int.parse(existingData.color!.replaceFirst('#', '0xFF')))
        : Theme.of(context).primaryColor;

    // Initialize selected icon label
    String selectedIconLabel =
        isUpdate ? existingData!.icon ?? 'wallet' : 'wallet';

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          child: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
                maxWidth: 400,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        title ??
                            '${isUpdate ? 'Update' : 'Add'} ${structureType}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Name Input
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: labelText ?? '${structureType} Name',
                          hintText: hintText ??
                              'Enter ${structureType.toLowerCase()} name',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.edit),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a ${structureType.toLowerCase()} name';
                          }
                          return null;
                        },
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 16),

                      // Balance Input for Accounts
                      if (structureType == ATableNames.accounts)
                        Column(
                          children: [
                            TextFormField(
                              controller: balanceController,
                              decoration: const InputDecoration(
                                labelText: 'Balance',
                                hintText: 'Enter balance amount',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.account_balance),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the balance amount';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      // Clor Picker
                        Column(
                          children: [
                            TextFormField(
                              controller: labelController,
                              decoration: const InputDecoration(
                                labelText: 'Label',
                                hintText: 'Enter label (optional)',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.label),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),

                      Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                '${structureType} Color: ',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const Spacer(),
                              ColorPickerWidget(
                                currentColor: selectedColor,
                                onColorChanged: (Color color) {
                                  setState(() {
                                    selectedColor = color;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Icon Selection
                      Row(
                        children: [
                          const Text(
                            'Select Icon:',
                            style: TextStyle(fontSize: 16),
                          ),
                          const Spacer(),
                          IconPickerWidget(
                            currentLabel: selectedIconLabel,
                            onIconSelected: (String label) {
                              setState(() {
                                selectedIconLabel = label;
                              });
                            },
                            size: 40,
                          ),
                        ],
                      ),

                      // Action Buttons
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('CANCEL'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                try {
                                  switch (structureType) {
                                    case ATableNames.accounts:
                                      final StructModel structModel =
                                          StructModel(
                                        name: nameController.text.trim(),
                                        icon: selectedIconLabel,
                                        color:
                                            '#${selectedColor.value.toRadixString(16).substring(2)}',
                                        balance: double.tryParse(
                                                balanceController.text) ??
                                            0.0,
                                      );
                                      if (isUpdate) {
                                        await StructuresCRUD().update(
                                          structureType,
                                          structModel,
                                        );
                                      } else {
                                        await StructuresCRUD().insert(
                                          structureType,
                                          structModel,
                                        );
                                      }
                                      break;
                                    default:
                                      final StructModel structModel =
                                          StructModel(
                                        name: nameController.text.trim(),
                                        icon: selectedIconLabel,
                                        color:
                                            '#${selectedColor.value.toRadixString(16).substring(2)}',
                                        label: labelController.text.trim(),
                                      );
                                      if (isUpdate) {
                                        await StructuresCRUD().update(
                                          structureType,
                                          structModel,
                                        );
                                      } else {
                                        await StructuresCRUD().insert(
                                          structureType,
                                          structModel,
                                        );
                                      }
                                      break;
                                  }

                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${structureType} ${isUpdate ? 'updated' : 'added'} successfully',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: ${e.toString()}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            child: Text(isUpdate ? 'UPDATE' : 'SAVE'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
