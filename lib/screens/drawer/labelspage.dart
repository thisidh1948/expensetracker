// labels_page.dart
import 'package:expense_tracker/database/database_tables.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/database/structures_crud.dart';
import 'package:expense_tracker/database/models/struct_model.dart';

import '../structure/common_add_dialog.dart';
import '../structure/common_delete_dialog.dart';

class LabelsPage extends StatefulWidget {
  @override
  _LabelsPageState createState() => _LabelsPageState();
}

class _LabelsPageState extends State<LabelsPage> {
  final StructuresCRUD _structuresCRUD = StructuresCRUD();
  List<StructModel> _labels = [];

  @override
  void initState() {
    super.initState();
    _fetchLabels();
  }

  Future<void> _fetchLabels() async {
    final labels = await _structuresCRUD.getAllTableData(ATableNames.labels);
    setState(() {
      _labels = labels;
    });
  }

  void _showAddOrUpdateDialog([StructModel? label]) {
    CommonAddDialog.showStructureDialog(
      context: context,
      structureType: ATableNames.labels,
      existingData: label,
      title: label == null ? 'Add Label' : 'Update Label',
    ).then((_) => _fetchLabels());
  }

  void _showDeleteDialog(StructModel label) {
    CommonDeleteDialog.showDeleteDialog(
      context: context,
      structureType: ATableNames.labels,
      item: label,
      onDeleteSuccess: _fetchLabels,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Labels'),
      ),
      body: ListView.builder(
        itemCount: _labels.length,
        itemBuilder: (context, index) {
          final label = _labels[index];
          return ListTile(
            title: Text(label.name),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _showAddOrUpdateDialog(label),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _showDeleteDialog(label),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrUpdateDialog(),
        child: Icon(Icons.add),
      ),
    );
  }
}