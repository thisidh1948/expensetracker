import 'package:flutter/material.dart';
import '../../database/models/mapping_model.dart';
import '../../database/models/struct_model.dart';
import '../../database/structures_crud.dart';
import '../../widgets/customIcons.dart';
import 'addpage_mapping.dart';

class ItemsPage extends StatefulWidget {
  final String subcategory;

  const ItemsPage({Key? key, required this.subcategory}) : super(key: key);

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
      body: RefreshIndicator(
        onRefresh: () async => _refreshItems(),
        child: FutureBuilder<List<MappingModel>>(
          future: _itemsFuture,
          builder: (context, mappingSnapshot) {
            if (mappingSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final mappings = mappingSnapshot.data ?? [];

            return FutureBuilder<List<StructModel>>(
              future: StructuresCRUD().getAllTableData('Items'),
              builder: (context, itemsSnapshot) {
                if (itemsSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final itemStructures = itemsSnapshot.data ?? [];
                final filteredItems = itemStructures
                    .where((item) => mappings.any((m) => m.child == item.name))
                    .toList();

                if (filteredItems.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.inventory,
                            size: 60, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'No items found for this subcategory',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _showAddItemSheet(),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Item'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: CustomIcons.getIcon(item.icon, size: 24),
                        title: Text(item.name),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () => _confirmDelete(item.name),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemSheet,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _confirmDelete(String itemName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to remove $itemName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await StructuresCRUD()
          .deleteItemForSubcategory(widget.subcategory, itemName);
      _refreshItems();
    }
  }

  void _showAddItemSheet() {
    BottomSheetUtils.showStructureBottomSheet(
      context: context,
      title: 'Select Item',
      structureType: 'Items',
      parentType: 'Subcategories',
      parentName: widget.subcategory,
      availableIcons: const [],
      onRefresh: _refreshItems,
    );
  }
}
