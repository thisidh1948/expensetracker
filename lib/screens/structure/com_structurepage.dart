import 'package:expense_tracker/widgets/customIcons.dart';
import 'package:flutter/material.dart';
import '../../database/models/struct_model.dart';
import '../../database/structures_crud.dart';
import 'common_add_dialog.dart';
import 'common_delete_dialog.dart';

class ComStructurePage extends StatefulWidget {
  final String structureType;

  const ComStructurePage({Key? key, required this.structureType}) : super(key: key);

  @override
  State<ComStructurePage> createState() => _ComStructurePageState();
}

class _ComStructurePageState extends State<ComStructurePage> {
  late Future<List<StructModel>> _structuresFuture;

  @override
  void initState() {
    super.initState();
    _loadStructures();
  }

  void _loadStructures() {
    setState(() {
      _structuresFuture = StructuresCRUD().getAllTableData(widget.structureType);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.structureType,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
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
                  _loadStructures();
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
      body: FutureBuilder<List<StructModel>>(
        future: _structuresFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
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
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadStructures,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final structures = snapshot.data ?? [];

          if (structures.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.category_outlined,
                    size: 60,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No data found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      CommonAddDialog.showStructureDialog(
                        context: context,
                        structureType: widget.structureType,
                      ).then((_) => _loadStructures());
                    },
                    icon: const Icon(Icons.add),
                    label: Text('Add ${widget.structureType}'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _loadStructures();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: structures.length,
              itemBuilder: (context, index) {
                final structure = structures[index];
                final Color structureColor = Color(
                  int.parse(
                      structure.color?.replaceFirst('#', '0xFF') ?? 'FF000000'),
                );

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  elevation: 2,
                  child: InkWell(
                    onTap: () {
                      // Handle structure selection/details view
                    },
                    onLongPress: () {
                      CommonAddDialog.showStructureDialog(
                        context: context,
                        structureType: widget.structureType,
                        existingData: structure,
                      ).then((_) => _loadStructures());
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          // Structure Icon
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: structureColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: CustomIcons.getIcon(structure.icon, size: 24),
                          ),
                          const SizedBox(width: 16),

                          // Structure Color
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: structureColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Structure Name
                          Expanded(
                            child: Text(
                              structure.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),

                          // Action Buttons
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                color: Colors.blue,
                                onPressed: () {
                                  CommonAddDialog.showStructureDialog(
                                    context: context,
                                    structureType: widget.structureType,
                                    existingData: structure,
                                  ).then((_) => _loadStructures());
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                color: Colors.red,
                                onPressed: () =>
                                    CommonDeleteDialog.showDeleteDialog(
                                      context: context,
                                      structureType: widget.structureType,
                                      item: structure,
                                      onDeleteSuccess: _loadStructures,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          CommonAddDialog.showStructureDialog(
            context: context,
            structureType: widget.structureType,
          ).then((_) => _loadStructures());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
