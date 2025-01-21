import 'package:expense_tracker/database/appdata_crud.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../database/models/appdata.dart';
import '../../database/models/struct_model.dart';
import '../../database/structures_crud.dart';
import '../../widgets/color_picker_widget.dart';

class CommonAddDialog {
  static Future<void> showStructureDialog({
    required BuildContext context,
    required String structureType,
    required List<Map<String, dynamic>> availableIcons,
    StructModel? existingData,
    String? title,
    String? labelText,
    String? hintText,
  }) async {
    final bool isUpdate = existingData != null;
    final nameController = TextEditingController(text: existingData?.name ?? '');
    final balanceController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    // Initialize color and icon based on existing data or defaults
    Color selectedColor = isUpdate
        ? Color(int.parse(existingData.color!.replaceFirst('#', '0xFF')))
        : Theme.of(context).primaryColor;

    // Convert string icon to IconData for existing data, or use default
    IconData selectedIcon = isUpdate
        ? IconData(int.parse(existingData.icon!), fontFamily: 'MaterialIcons')
        : availableIcons[0]['icon'];

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
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
                      title ?? '${isUpdate ? 'Update' : 'Add'} ${structureType}',
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
                        hintText: hintText ?? 'Enter ${structureType.toLowerCase()} name',
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

                    // Balance Input (if structureType is 'Accounts')
                    if (structureType == 'Accounts')
                      TextFormField(
                        controller: balanceController,
                        decoration: InputDecoration(
                          labelText: 'Balance',
                          hintText: 'Enter balance amount',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.account_balance),
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

                    // Color Picker
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
                    const SizedBox(height: 16),

                    // Icon Selection
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Select Icon:',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 8),

                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: GridView.builder(
                          padding: const EdgeInsets.all(8),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: availableIcons.length,
                          itemBuilder: (context, index) {
                            final icon = availableIcons[index]['icon'] as IconData;
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  selectedIcon = icon;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: selectedIcon.codePoint == icon.codePoint
                                      ? selectedColor.withOpacity(0.2)
                                      : null,
                                  border: Border.all(
                                    color: selectedIcon.codePoint == icon.codePoint
                                        ? selectedColor
                                        : Colors.grey,
                                    width: selectedIcon.codePoint == icon.codePoint ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  icon,
                                  color: selectedIcon.codePoint == icon.codePoint
                                      ? selectedColor
                                      : Colors.grey,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
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
                                final StructModel structModel = StructModel(
                                  name: nameController.text.trim(),
                                  icon: selectedIcon.codePoint.toString(), // Store icon as string
                                  color: '#${selectedColor.value.toRadixString(16).substring(2)}',
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

                                  // If structureType is 'Accounts', insert balance into AppData
                                  if (structureType == 'Accounts') {
                                    final AppData appData = AppData(
                                      category: 'IB',
                                      key: structModel.name,
                                      value: balanceController.text.trim(),
                                    );
                                    await AppDataCrud().insert(appData);
                                  }
                                }

                                Navigator.pop(context);

                                // Show success message
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
    );
  }
}
