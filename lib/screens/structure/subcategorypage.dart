import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:expense_tracker/database/models/mapping_model.dart';
import 'package:expense_tracker/database/models/struct_model.dart';
import '../../database/structures_crud.dart';
import 'Itemspage.dart';
import 'addpage_mapping.dart';
import 'common_add_dialog.dart';

class SubcategoryPage extends StatefulWidget {
  final String category;

  const SubcategoryPage({Key? key, required this.category}) : super(key: key);

  @override
  State<SubcategoryPage> createState() => _SubcategoryPageState();
}

class _SubcategoryPageState extends State<SubcategoryPage> {
  late Future<List<MappingModel>> _subcategoriesFuture;
  bool _isRefreshing = false;
  String? selectedSubcategory;

  @override
  void initState() {
    super.initState();
    _loadSubcategories();
  }

  void _loadSubcategories() {
    setState(() {
      _subcategoriesFuture =
          StructuresCRUD().getSubCategoriesForCategory(widget.category);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Subcategories',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                widget.category,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // Implement search functionality
              },
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'sort_name':
                    // Implement sort by name
                    break;
                  case 'sort_date':
                    // Implement sort by date
                    break;
                  case 'refresh':
                    setState(() {});
                    break;
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'sort_name',
                  child: Row(
                    children: [
                      Icon(Icons.sort_by_alpha, size: 20),
                      SizedBox(width: 8),
                      Text('Sort by Name'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'sort_date',
                  child: Row(
                    children: [
                      Icon(Icons.date_range, size: 20),
                      SizedBox(width: 8),
                      Text('Sort by Date'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'refresh',
                  child: Row(
                    children: [
                      Icon(Icons.refresh, size: 20),
                      SizedBox(width: 8),
                      Text('Refresh'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: FutureBuilder<List<MappingModel>>(
          future: _subcategoriesFuture,
          builder: (context, mappingSnapshot) {
            if (mappingSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (mappingSnapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${mappingSnapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => setState(() {
                        _subcategoriesFuture = StructuresCRUD()
                            .getSubCategoriesForCategory(widget.category);
                      }),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            final subcategories = mappingSnapshot.data ?? [];

            if (subcategories.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.subdirectory_arrow_right,
                      size: 60,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No subcategories found',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        BottomSheetUtils.showStructureBottomSheet(
                          context: context,
                          title: 'Select Subcategory',
                          structureType: 'Subcategories',
                          parentType: 'Categories',
                          parentName: widget.category,
                          availableIcons: subcategoryIcons,
                          onRefresh: () {
                            setState(() {
                              _subcategoriesFuture = StructuresCRUD()
                                  .getSubCategoriesForCategory(widget.category);
                            });
                          },
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Subcategory'),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _subcategoriesFuture = StructuresCRUD()
                      .getSubCategoriesForCategory(widget.category);
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Expanded(
                      child: FutureBuilder<List<StructModel>>(
                        future:
                            StructuresCRUD().getAllTableData('Subcategories'),
                        builder: (context, structSnapshot) {
                          if (structSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (structSnapshot.hasError) {
                            return Center(
                              child: Text('Error: ${structSnapshot.error}'),
                            );
                          }

                          final structModels = structSnapshot.data ?? [];
                          final structModelMap = {
                            for (var model in structModels) model.name: model
                          };

                          return ListView.builder(
                            itemCount: subcategories.length,
                            itemBuilder: (context, index) {
                              final subcategory = subcategories[index];
                              final structModel =
                                  structModelMap[subcategory.child];

                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  leading: Icon(
                                    structModel?.icon != null
                                        ? IconData(
                                            int.parse(structModel!.icon!),
                                            fontFamily: 'MaterialIcons',
                                          )
                                        : Icons.subdirectory_arrow_right,
                                    color: structModel?.color != null
                                        ? Color(int.parse(structModel!.color!
                                            .replaceFirst('#', '0xFF')))
                                        : Colors.blue,
                                    size: 28,
                                  ),
                                  title: Text(
                                    subcategory.child,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ItemsPage(
                                          subcategory: subcategory.child,
                                        ),
                                      ),
                                    ).then((_) => setState(() {
                                          _subcategoriesFuture =
                                              StructuresCRUD()
                                                  .getSubCategoriesForCategory(
                                                      widget.category);
                                        }));
                                  },
                                  onLongPress: () {
                                    // Implement edit functionality if needed
                                  },
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        color: Colors.red.shade400,
                                        onPressed: () => _showDeleteDialog(
                                            context, subcategory),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            BottomSheetUtils.showStructureBottomSheet(
              context: context,
              title: 'Select Subcategory',
              structureType: 'Subcategories',
              parentType: 'Categories',
              parentName: widget.category,
              availableIcons: subcategoryIcons,
              onRefresh: () {
                setState(() {
                  _subcategoriesFuture = StructuresCRUD()
                      .getSubCategoriesForCategory(widget.category);
                });
              },
            );
          },
          child: const Icon(Icons.add),
        ));
  }

  final List<Map<String, dynamic>> subcategoryIcons = [
    {'icon': Icons.subdirectory_arrow_right, 'label': 'Subcategory'},
    {'icon': Icons.list, 'label': 'List'},
    {'icon': Icons.folder_open, 'label': 'Folder'},
    {'icon': Icons.label, 'label': 'Label'},
    {'icon': Icons.bookmark, 'label': 'Bookmark'},
    {'icon': Icons.style, 'label': 'Style'},
    // Add more subcategory-specific icons as needed
  ];

  Future<void> _showDeleteDialog(
      BuildContext context, MappingModel subcategory) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subcategory'),
        content: Text('Are you sure you want to delete'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await StructuresCRUD().deleteSubcategoryForCategory(
                  widget.category,
                  subcategory.child,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  setState(() {
                    _subcategoriesFuture = StructuresCRUD()
                        .getSubCategoriesForCategory(widget.category);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Subcategory deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'DELETE',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
