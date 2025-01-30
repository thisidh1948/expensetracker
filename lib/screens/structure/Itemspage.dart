import 'package:flutter/material.dart';
import '../../database/models/mapping_model.dart';
import '../../database/models/struct_model.dart';
import '../../database/structures_crud.dart';
import '../../widgets/customIcons.dart';
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
      _itemsFuture = StructuresCRUD().getItemsForSubcategory(widget.subcategory);
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
                        availableIcons: const [],
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
                      builder: (context, itemsSnapshot) {
                        if (itemsSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final itemStructures = itemsSnapshot.data ?? [];

                        return ListView.builder(
                          itemCount: itemStructures.length,
                          itemBuilder: (context, index) {
                            final item = itemStructures[index];
                            final Color itemColor = item.color != null
                                ? Color(int.parse(
                                    item.color!.replaceFirst('#', '0xFF')))
                                : Theme.of(context).primaryColor;

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                leading: CustomIcons.getIcon(
                                  item.icon,
                                  size: 24,
                                ),
                                title: Text(item.name),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  color: Colors.red,
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Confirm Deletion'),
                                        content: Text(
                                            'Are you sure you want to remove ${item.name}?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      await StructuresCRUD()
                                          .deleteItemForSubcategory(
                                        widget.subcategory,
                                        item.name,
                                      );
                                      _refreshItems();
                                    }
                                  },
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
            availableIcons: const [],
            onRefresh: _refreshItems,
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
