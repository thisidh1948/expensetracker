import 'package:flutter/material.dart';
import '../database/models/struct_model.dart';
import 'field_icon.dart';

class SelectionDialog extends StatelessWidget {
  final String title;
  final List<StructModel> items;
  final String? selectedValue;
  final Function(String?) onSearch;

  const SelectionDialog({
    Key? key,
    required this.title,
    required this.items,
    this.selectedValue,
    required this.onSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            _buildSearchField(),
            Expanded(child: _buildGrid(context)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: 'Search $title',
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onChanged: onSearch,
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.85,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = item.name == selectedValue;
        return _buildGridItem(context, item, isSelected);
      },
    );
  }

  Widget _buildGridItem(BuildContext context, StructModel item, bool isSelected) {
    return InkWell(
      onTap: () => Navigator.of(context).pop(item.name),
      child: Card(
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FieldIcon(iconName: item.icon ?? item.name),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                item.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : null,
                  fontWeight: isSelected 
                      ? FontWeight.bold 
                      : FontWeight.normal,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 