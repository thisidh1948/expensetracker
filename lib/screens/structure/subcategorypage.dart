import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:expense_tracker/database/models/mapping_model.dart';
import 'package:expense_tracker/database/models/struct_model.dart';
import '../../database/structures_crud.dart';
import 'Itemspage.dart';

class SubcategoryPage extends StatefulWidget {
  final String category;

  const SubcategoryPage({Key? key, required this.category}) : super(key: key);

  @override
  State<SubcategoryPage> createState() => _SubcategoryPageState();
}

class _SubcategoryPageState extends State<SubcategoryPage> {
  late Future<List<MappingModel>> _subcategoriesFuture;

  @override
  void initState() {
    super.initState();
    _refreshSubcategories();
  }

  void _refreshSubcategories() {
    setState(() {
      _subcategoriesFuture = StructuresCRUD().getSubCategoriesForCategory(widget.category);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subcategories: ${widget.category}'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshSubcategories();
        },
        child: FutureBuilder<List<MappingModel>>(
          future: _subcategoriesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            final subcategories = snapshot.data ?? [];

            if (subcategories.isEmpty) {
              return const Center(
                child: Text(
                  'No subcategories found\nAdd using + button',
                  textAlign: TextAlign.center,
                ),
              );
            }

            return ListView.builder(
              itemCount: subcategories.length,
              itemBuilder: (context, index) {
                final subcategory = subcategories[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.subdirectory_arrow_right),
                    title: Text(subcategory.child),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _showDeleteDialog(context, subcategory),
                    ),
                    onTap: () => _navigateToItemsPage(context, subcategory.child),
                  ),
                );
              },
            );
          },
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSubcategoriesDialog(context),
        child: const Icon(Icons.add),
        tooltip: 'Add Subcategory',
      ),
    );
  }

  void _navigateToItemsPage(BuildContext context, String subcategory) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemsPage(subcategory: subcategory),
      ),
    );
  }


  Future<void> _showSubcategoriesDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Subcategory to ${widget.category}'),
        content: SizedBox(
          width: double.maxFinite,
          child: FutureBuilder<List<StructModel>>(
            future: StructuresCRUD().getAllTableData('SubCategories'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final subcategories = snapshot.data ?? [];

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.add_circle),
                    title: const Text('Add New Subcategory'),
                    onTap: () => _showAddSubcategoryDialog(context),
                  ),
                  const Divider(),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: subcategories.length,
                      itemBuilder: (context, index) {
                        final subcategory = subcategories[index];
                        return ListTile(
                          title: Text(subcategory.name),
                          onTap: () async {
                            try {
                              await StructuresCRUD().insertSubcategoryForCategory(
                                widget.category,
                                subcategory.name,
                              );
                              if (context.mounted) {
                                Navigator.pop(context);
                                _refreshSubcategories();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Subcategory added successfully'),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddSubcategoryDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Subcategory'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Subcategory Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a subcategory name';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  final subcategoryName = nameController.text.trim();
                  await StructuresCRUD().insert(
                    'SubCategories',
                    StructModel(name: subcategoryName),
                  );
                  await StructuresCRUD().insertSubcategoryForCategory(
                    widget.category,
                    subcategoryName,
                  );
                  if (context.mounted) {
                    Navigator.pop(context);
                    Navigator.pop(context);
                    _refreshSubcategories();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Subcategory added successfully'),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('ADD'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, MappingModel subcategory) {
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
                  subcategory.parent,
                  subcategory.child,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  _refreshSubcategories();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Subcategory Map deleted successfully'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting subcategory: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

}
