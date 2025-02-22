import 'package:flutter/material.dart';
import '../database/models/struct_model.dart';
import 'field_icon.dart';
import 'selection_dialog.dart';

class SelectionField extends StatelessWidget {
  final String label;
  final String? value;
  final List<StructModel> items;
  final Function(String?) onSelect;
  final bool isRequired;

  const SelectionField({
    Key? key,
    required this.label,
    required this.value,
    required this.items,
    required this.onSelect,
    this.isRequired = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (value != null) {
      return _buildSelectedDisplay(context);
    }
    return _buildSelectionField(context);
  }

  Widget _buildSelectedDisplay(BuildContext context) {
    final selectedItem = items.firstWhere(
      (item) => item.name == value,
      orElse: () => StructModel(name: value!, icon: null),
    );

    return InkWell(
      onTap: () => _showSelectionDialog(context),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            FieldIcon(iconName: selectedItem.icon ?? selectedItem.name),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value!,
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isRequired) 
              const Text('*', style: TextStyle(color: Colors.red)),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionField(BuildContext context) {
    return InkWell(
      onTap: () => _showSelectionDialog(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Select $label',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
              ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Future<void> _showSelectionDialog(BuildContext context) async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) => SelectionDialog(
        title: label,
        items: items,
        selectedValue: value,
        onSearch: (value) {
          // TODO: Implement search functionality
        },
      ),
    );
    if (selected != null) {
      onSelect(selected);
    }
  }
} 