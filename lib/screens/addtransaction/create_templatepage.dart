import 'package:flutter/material.dart';

import '../../database/models/template_model.dart';
import '../../database/structures_crud.dart';
import '../../database/templates_crud.dart';
import '../../widgets/color_picker_widget.dart';
import '../../widgets/iconpicker_widget.dart';

class CreateTemplatePage extends StatefulWidget {
  @override
  State<CreateTemplatePage> createState() => _CreateTemplatePageState();
}

class _CreateTemplatePageState extends State<CreateTemplatePage> {
  final _formKey = GlobalKey<FormState>();
  final _tNameController = TextEditingController();
  final _iconController = TextEditingController();
  final _colorController = TextEditingController();

  // Add StructuresCRUD instance
  final StructuresCRUD _structuresCrud = StructuresCRUD();
  final Templates_crud _templatesCrud = Templates_crud();

  // Lists to store dropdown items
  List<String> _accounts = [];
  List<String> _sections = [];
  List<String> _categories = [];
  List<String> _subcategories = [];
  List<String> _items = [];

  // Selected values
  String? selectedAccount;
  String? selectedSection;
  String? selectedCategory;
  String? selectedSubcategory;
  String? selectedItem;

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    try {
      // Load initial data
      final accounts = await _structuresCrud.getAllNames('Accounts');
      final sections = await _structuresCrud.getAllNames('Sections');
      final categories = await _structuresCrud.getAllNames('Categories');

      setState(() {
        _accounts = accounts;
        _sections = sections;
        _categories = categories;
      });
    } catch (e) {
      print('Error loading dropdown data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  Future<void> _loadSubcategories(String category) async {
    try {
      final subcategoriesX = await _structuresCrud.getSubCategoriesForCategory(category);
      final subcategories = subcategoriesX.map((e) => e.child as String).toList();
      setState(() {
        _subcategories = subcategories;
        selectedSubcategory = null; // Reset selection
        _items = []; // Clear items
        selectedItem = null;
      });
    } catch (e) {
      print('Error loading subcategories: $e');
    }
  }

  Future<void> _loadItems(String subcategory) async {
    try {
      final itemsX = await _structuresCrud.getItemsForSubcategory(subcategory);
      final items = itemsX.map((e) => e.child as String).toList();
      setState(() {
        _items = items;
        selectedItem = null; // Reset selection
      });
    } catch (e) {
      print('Error loading items: $e');
    }
  }

  void _showSelectionDialog(String title, List<String> items, String? currentValue, Function(String) onSelect) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  title: Text(item),
                  selected: item == currentValue,
                  onTap: () {
                    onSelect(item);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Template'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _tNameController,
                decoration: InputDecoration(
                  labelText: 'Template Name',
                  hintText: 'Enter template name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter template name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Account Selection
              ListTile(
                title: Text('Account'),
                subtitle: Text(selectedAccount ?? 'Select Account'),
                trailing: Icon(Icons.arrow_drop_down),
                onTap: () => _showSelectionDialog(
                  'Select Account',
                  _accounts,
                  selectedAccount,
                      (value) => setState(() => selectedAccount = value),
                ),
              ),
              Divider(),

              // Section Selection
              ListTile(
                title: Text('Section'),
                subtitle: Text(selectedSection ?? 'Select Section'),
                trailing: Icon(Icons.arrow_drop_down),
                onTap: () => _showSelectionDialog(
                  'Select Section',
                  _sections,
                  selectedSection,
                      (value) => setState(() => selectedSection = value),
                ),
              ),
              Divider(),

              // Category Selection
              ListTile(
                title: Text('Category'),
                subtitle: Text(selectedCategory ?? 'Select Category'),
                trailing: Icon(Icons.arrow_drop_down),
                onTap: () => _showSelectionDialog(
                  'Select Category',
                  _categories,
                  selectedCategory,
                      (value) {
                    setState(() {
                      selectedCategory = value;
                      selectedSubcategory = null;
                      selectedItem = null;
                    });
                    _loadSubcategories(value);
                  },
                ),
              ),
              Divider(),

              // Subcategory Selection
              if (_subcategories.isNotEmpty)
                ListTile(
                  title: Text('Subcategory'),
                  subtitle: Text(selectedSubcategory ?? 'Select Subcategory'),
                  trailing: Icon(Icons.arrow_drop_down),
                  onTap: () => _showSelectionDialog(
                    'Select Subcategory',
                    _subcategories,
                    selectedSubcategory,
                        (value) {
                      setState(() => selectedSubcategory = value);
                      _loadItems(value);
                    },
                  ),
                ),
              if (_subcategories.isNotEmpty) Divider(),

              // Item Selection
              if (_items.isNotEmpty)
                ListTile(
                  title: Text('Item'),
                  subtitle: Text(selectedItem ?? 'Select Item'),
                  trailing: Icon(Icons.arrow_drop_down),
                  onTap: () => _showSelectionDialog(
                    'Select Item',
                    _items,
                    selectedItem,
                        (value) => setState(() => selectedItem = value),
                  ),
                ),
              if (_items.isNotEmpty) Divider(),

              // Icon Picker
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Icon:',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  IconPickerWidget(
                    currentLabel: _iconController.text,
                    onIconSelected: (String label) {
                      setState(() {
                        _iconController.text = label; // Store the label in DB
                      });
                    },
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Color Picker
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Color:',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  ColorPickerWidget(
                    currentColor: _parseColor(_colorController.text),
                    onColorChanged: (Color color) {
                      setState(() {
                        _colorController.text =
                        '#${color.value.toRadixString(16).toUpperCase()}';
                      });
                    },
                  ),
                ],
              ),

              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveTemplate,
                child: Text('Save Template'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      if (colorString.startsWith('#')) {
        colorString = colorString.replaceFirst('#', '0xFF');
      }
      return Color(int.parse(colorString));
    } catch (e) {
      // Default to black if the color string is invalid
      return Colors.black;
    }
  }

  Future<void> _saveTemplate() async {
    if (_formKey.currentState!.validate()) {
      try {
        final template = Template(
          tName: _tNameController.text,
          account: selectedAccount,
          section: selectedSection,
          category: selectedCategory,
          subcategory: selectedSubcategory,
          item: selectedItem,
          icon: _iconController.text,
          color: _colorController.text,
          cd: false,
        );

        await _templatesCrud.insertTemplate(template);
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving template: $e')),
        );
      }
    }
  }
}
