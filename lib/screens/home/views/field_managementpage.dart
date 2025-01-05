import 'package:expense_tracker/database/database_helper.dart';
import 'package:expense_tracker/database/fieldsmodel.dart';
import 'package:expense_tracker/icons/bank_icons.dart';
import 'package:flutter/material.dart';

class FieldManagementPage extends StatefulWidget {
  final String fieldType;

  const FieldManagementPage({super.key, required this.fieldType});

  @override
  _FieldManagementPageState createState() => _FieldManagementPageState();
}

class _FieldManagementPageState extends State<FieldManagementPage> {
  final _formKey = GlobalKey<FormState>();
  String _newField = '';
  IconData _selectedIcon = Icons.label;
  List<FieldModel> _fields = [];

  @override
  void initState() {
    super.initState();
    _loadFields();
  }

  Future<void> _loadFields() async {
    List<FieldModel> fields = await DatabaseHelper().getFields(widget.fieldType);
    setState(() {
      _fields = fields;
    });
  }

  Future<void> _addField() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      FieldModel newField = FieldModel(name: _newField, icon: _selectedIcon);
      await DatabaseHelper().insertField(widget.fieldType, newField.toMap());
      _loadFields(); // Refresh the list after adding a new field
    }
  }

  Future<void> _deleteDb() async {
    await DatabaseHelper().deleteDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage ${widget.fieldType}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Form(
              key: _formKey,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Add ${widget.fieldType}',
                      ),
                      onSaved: (val) => _newField = val!,
                      validator: (val) => val!.isEmpty ? 'Please enter a field' : null,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: <Widget>[
                const Text("Select Icon: "),
                IconButton(
                  icon: Icon(_selectedIcon),
                  onPressed: () async {
                    IconData? selectedIcon = await showDialog<IconData>(
                      context: context,
                      builder: (context) => IconPickerDialog(),
                    );
                    if (selectedIcon != null) {
                      setState(() {
                        _selectedIcon = selectedIcon;
                      });
                    }
                  },
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _fields.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(_fields[index].icon),
                    title: Text(_fields[index].name),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        await DatabaseHelper().deleteField(
                          widget.fieldType,
                          _fields[index].name,
                        );
                        _loadFields();
                      },
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _deleteDb,
              child: const Text('Delete DBs'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _addField,
          child: const Text('Add Field'),
        ),
      ),
    );
  }
}

class IconPickerDialog extends StatelessWidget {
  IconPickerDialog({super.key});

  final List<IconData> icons = [
    Icons.label,
    Icons.account_balance_wallet,
    Icons.credit_card,
    Icons.shopping_cart,
    Icons.home,
    Icons.attach_money,
    Icons.fastfood,
    Icons.local_hospital,
    Icons.directions_car,
    Icons.school,
    Icons.local_movies,
    Icons.flight,
    Icons.sports,
    Icons.pets,
    Icons.shopping_bag,
    Icons.restaurant,
    BankIcons.axis_bank,
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: icons.length,
          itemBuilder: (context, index) {
            return IconButton(
              icon: Icon(icons[index]),
              onPressed: () {
                Navigator.of(context).pop(icons[index]);
              },
            );
          },
        ),
      ),
    );
  }
}
