import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../database/models/mapping_model.dart';
import '../../database/models/struct_model.dart';
import '../../database/structures_crud.dart';
import 'addpage_mapping.dart';

class ItemsPage extends StatefulWidget {
  final String subcategory;

  const ItemsPage({
    Key? key,
    required this.subcategory,
  }) : super(key: key);

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  late Future<List<MappingModel>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _refreshItems();
  }

  void _refreshItems() {
    setState(() {
      _itemsFuture =
          StructuresCRUD().getItemsForSubcategory(widget.subcategory);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Items - ${widget.subcategory}'),
      ),
      body: FutureBuilder<List<MappingModel>>(
        future: _itemsFuture,
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
                    onPressed: _refreshItems,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final items = mappingSnapshot.data ?? [];

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.inventory,
                    size: 60,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No items found',
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
                        title: 'Select Item',
                        structureType: 'Items',
                        parentType: 'Subcategories',
                        parentName: widget.subcategory,
                        availableIcons: itemIcons,
                        onRefresh: _refreshItems,
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Item'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _refreshItems();
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: FutureBuilder<List<StructModel>>(
                      future: StructuresCRUD().getAllTableData('Items'),
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
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final structModel = structModelMap[item.child];

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
                                      : Icons.inventory,
                                  color: structModel?.color != null
                                      ? Color(int.parse(structModel!.color!
                                          .replaceFirst('#', '0xFF')))
                                      : Colors.blue,
                                  size: 28,
                                ),
                                title: Text(
                                  item.child,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                          Icons.delete_outline_rounded),
                                      color: Colors.red,
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Delete Item'),
                                            content: Text(
                                                'Are you sure you want to delete "${item.child}"?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text('CANCEL'),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  try {
                                                    await StructuresCRUD()
                                                        .deleteItemForSubcategory(
                                                      widget.subcategory,
                                                      item.child,
                                                    );
                                                    if (context.mounted) {
                                                      Navigator.pop(context);
                                                      _refreshItems();
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                              'Item deleted successfully'),
                                                          backgroundColor:
                                                              Colors.green,
                                                        ),
                                                      );
                                                    }
                                                  } catch (e) {
                                                    if (context.mounted) {
                                                      Navigator.pop(context);
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                              'Error: ${e.toString()}'),
                                                          backgroundColor:
                                                              Colors.red,
                                                        ),
                                                      );
                                                    }
                                                  }
                                                },
                                                child: const Text(
                                                  'DELETE',
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
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
            title: 'Select Item',
            structureType: 'Items',
            parentType: 'Subcategories',
            parentName: widget.subcategory,
            availableIcons: itemIcons,
            onRefresh: _refreshItems,
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Define your item icons
final List<Map<String, dynamic>> itemIcons = [
  {'icon': Icons.inventory, 'label': 'Inventory'},
  {'icon': Icons.shopping_bag, 'label': 'Shopping'},
  {'icon': Icons.category, 'label': 'Category'},
  {'icon': Icons.local_offer, 'label': 'Offer'},
  {'icon': Icons.shopping_cart, 'label': 'Cart'},
  {'icon': Icons.store, 'label': 'Store'},
];
