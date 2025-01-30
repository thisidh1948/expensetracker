// lib/utils/bottom_sheet_utils.dart

import 'package:flutter/material.dart';
import '../../database/models/struct_model.dart';
import '../../database/structures_crud.dart';
import '../../widgets/customIcons.dart';
import 'common_add_dialog.dart';

class BottomSheetUtils {
  static void showStructureBottomSheet({
    required BuildContext context,
    required String title,
    required String structureType,
    required String parentType,
    required String parentName,
    required List<Map<String, dynamic>> availableIcons,
    required Function() onRefresh,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return FutureBuilder<List<StructModel>>(
              future: StructuresCRUD().getAllTableData(structureType),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text('Error: ${snapshot.error}'),
                    ),
                  );
                }

                final structures = snapshot.data ?? [];

                return DraggableScrollableSheet(
                  initialChildSize: 0.6,
                  minChildSize: 0.3,
                  maxChildSize: 0.9,
                  expand: false,
                  builder: (context, scrollController) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            controller: scrollController,
                            children: [
                              // Add New Option
                              ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  child: Icon(Icons.add, color: Colors.white),
                                ),
                                title: Text(
                                  'Add New ${structureType.substring(0, structureType.length - 1)}',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onTap: () async {
                                  await CommonAddDialog.showStructureDialog(
                                    context: context,
                                    structureType: structureType,
                                  );

                                  if (context.mounted) {
                                    setSheetState(() {});
                                    onRefresh();
                                  }
                                },
                              ),
                              const Divider(),
                              // Existing Items
                              ...structures.map((structure) {
                                final Color structureColor =
                                    structure.color != null
                                        ? Color(int.parse(structure.color!
                                            .replaceFirst('#', '0xFF')))
                                        : Theme.of(context).primaryColor;

                                return ListTile(
                                  leading: CustomIcons.getIcon(
                                    structure.icon,
                                    size: 24,
                                  ),
                                  title: Text(structure.name),
                                  onTap: () async {
                                    try {
                                      if (structureType == 'Subcategories') {
                                        await StructuresCRUD()
                                            .insertSubcategoryForCategory(
                                          parentName,
                                          structure.name,
                                        );
                                      } else if (structureType == 'Items') {
                                        await StructuresCRUD()
                                            .insertItemForSubcategory(
                                          parentName,
                                          structure.name,
                                        );
                                      }

                                      if (context.mounted) {
                                        Navigator.pop(context);
                                        onRefresh();
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                '${structureType.substring(0, structureType.length - 1)} linked successfully'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content:
                                                Text('Error: ${e.toString()}'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    }
                                  },
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
