import 'package:expense_tracker/widgets/customIcons.dart';
import 'package:flutter/material.dart';

import '../../database/models/struct_model.dart';
import '../../database/structures_crud.dart';
import 'common_add_dialog.dart';
import 'common_delete_dialog.dart';

class SectionsPage extends StatefulWidget {
  const SectionsPage({Key? key}) : super(key: key);

  @override
  State<SectionsPage> createState() => _SectionsPageState();
}

class _SectionsPageState extends State<SectionsPage> {
  late Future<List<StructModel>> _sectionsFuture;

  @override
  void initState() {
    super.initState();
    _loadSections();
  }

  void _loadSections() {
    setState(() {
      _sectionsFuture = StructuresCRUD().getAllTableData('Sections');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sections',
          style: TextStyle(
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
                  _loadSections();
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
        future: _sectionsFuture,
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
                    onPressed: _loadSections,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final sections = snapshot.data ?? [];

          if (sections.isEmpty) {
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
                    'No sections found',
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
                        structureType: 'Sections',
                      ).then((_) => _loadSections());
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Section'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _loadSections();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: sections.length,
              itemBuilder: (context, index) {
                final section = sections[index];
                final Color sectionColor = Color(
                  int.parse(
                      section.color?.replaceFirst('#', '0xFF') ?? 'FF000000'),
                );

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  elevation: 2,
                  child: InkWell(
                    onTap: () {
                      // Handle section selection/details view
                    },
                    onLongPress: () {
                      CommonAddDialog.showStructureDialog(
                        context: context,
                        structureType: 'Sections',
                        existingData: section,
                      ).then((_) => _loadSections());
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          // Section Icon
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: sectionColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: CustomIcons.getIcon(section.icon, size: 24),
                          ),
                          const SizedBox(width: 16),

                          // Section Color
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: sectionColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Section Name
                          Expanded(
                            child: Text(
                              section.name,
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
                                    structureType: 'Sections',
                                    existingData: section,
                                  ).then((_) => _loadSections());
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                color: Colors.red,
                                onPressed: () =>
                                    CommonDeleteDialog.showDeleteDialog(
                                  context: context,
                                  structureType: 'Sections',
                                  // or 'Sections', 'Categories', etc.
                                  item: section,
                                  onDeleteSuccess:
                                      _loadSections, // or _loadSections, etc.
                                  // Optional custom messages:
                                  // customTitle: 'Custom Delete Title',
                                  // customMessage: 'Custom delete confirmation message',
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
            structureType: 'Sections',
          ).then((_) => _loadSections());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
