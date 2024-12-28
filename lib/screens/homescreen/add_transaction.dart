import 'package:expense_tracker/database/database_helper.dart';
import 'package:expense_tracker/database/fieldsmodel.dart';
import 'package:expense_tracker/database/transmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddTransactionPage extends StatefulWidget {
  final TransModel? transaction;

  const AddTransactionPage({super.key, this.transaction});

  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  late TransModel _transaction;
  List<FieldModel> _accounts = [];
  List<FieldModel> _sections = [];
  List<FieldModel> _categories = [];
  List<FieldModel> _subcategories = [];

  @override
  void initState() {
    super.initState();
    _transaction = widget.transaction ?? TransModel(
      account: '',
      section: '',
      category: '',
      subCategory: '',
      amount: 0.0,
      cd: 'Credit',
      note: '',
      date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    _loadFields();
  }

  Future<void> _loadFields() async {
    _accounts = await DatabaseHelper().getFields('Accounts');
    _sections = await DatabaseHelper().getFields('Sections');
    _categories = await DatabaseHelper().getFields('Categories');
    _subcategories = await DatabaseHelper().getFields('Subcategories');
    setState(() {});
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      bool isSuccess = widget.transaction == null
          ? await DatabaseHelper().insertTransaction(_transaction) != null
          : await DatabaseHelper().updateTransaction(_transaction) != null;
      _showTransactionStatus(context, isSuccess);
      if (isSuccess) Navigator.pop(context);
    }
  }

  void _showTransactionStatus(BuildContext context, bool isSuccess) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isSuccess ? 'Transaction saved successfully!' : 'Failed to save transaction.')));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: Text(widget.transaction == null ? 'Add Transaction' : 'Update Transaction')),
        backgroundColor: Theme.of(context).primaryColor,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  _buildDropdownField('Account', Icons.warehouse, _transaction.account, _accounts, (val) => setState(() => _transaction.account = val ?? '')),
                  _buildDropdownField('Section', Icons.account_circle, _transaction.section, _sections, (val) => setState(() => _transaction.section = val ?? '')),
                  _buildDropdownField('Category', Icons.category_outlined, _transaction.category, _categories, (val) => setState(() => _transaction.category = val ?? '')),
                  _buildDropdownField('SubCategory', Icons.subdirectory_arrow_right, _transaction.subCategory, _subcategories, (val) => setState(() => _transaction.subCategory = val ?? '')),
                  _buildStyledTextField('Amount', Icons.attach_money, (val) => _transaction.amount = double.parse(val!), initialValue: _transaction.amount.toString()),
                  _buildChoiceChips(),
                  _buildStyledTextField('Note', Icons.note, (val) => _transaction.note = val),
                  GestureDetector(
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context, initialDate: DateTime.parse(_transaction.date),
                        firstDate: DateTime(2000), lastDate: DateTime(2101),
                      );
                      if (picked != null) setState(() => _transaction.date = DateFormat('yyyy-MM-dd').format(picked));
                    },
                    child: AbsorbPointer(
                      child: _buildStyledTextField('Date', Icons.calendar_today, null, initialValue: _transaction.date),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: Text(widget.transaction == null ? 'Add Transaction' : 'Update Transaction'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStyledTextField(String label, IconData icon, FormFieldSetter<String>? onSaved, {TextInputType keyboardType = TextInputType.text, String? initialValue}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        constraints: BoxConstraints(maxHeight: 50),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [BoxShadow(blurRadius: 1, color: Theme.of(context).brightness == Brightness.dark ? Colors.black12 : Colors.grey.shade200, offset: const Offset(5, 5))],
        ),
        child: Row(
          children: [
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0), child: Icon(icon)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: label,
                      labelStyle: TextStyle(color: Theme.of(context).hintColor),
                      border: InputBorder.none,
                    ),
                    onSaved: onSaved, keyboardType: keyboardType, initialValue: initialValue,
                    style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, IconData icon, String? initialValue, List<FieldModel> items, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        constraints: BoxConstraints(maxHeight: 50),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [BoxShadow(blurRadius: 1, color: Theme.of(context).brightness == Brightness.dark ? Colors.black12 : Colors.grey.shade200, offset: const Offset(5, 5))],
        ),
        child: Row(
          children: [
            Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0), child: Icon(icon)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: initialValue?.isNotEmpty == true ? initialValue : null,
                  hint: Text('Select $label', style: TextStyle(color: Theme.of(context).hintColor)),
                  items: items.map((item) => DropdownMenuItem<String>(value: item.name, child: Row(children: [if (item.icon != null) Icon(item.icon, color: Theme.of(context).iconTheme.color), const SizedBox(width: 8), Text(item.name)]))).toList(),
                  onChanged: onChanged,
                  underline: Container(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('Credit'),
            selected: _transaction.cd == 'Credit',
            onSelected: (selected) => setState(() => _transaction.cd = 'Credit'),
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Debit'),
            selected: _transaction.cd == 'Debit',
            onSelected: (selected) => setState(() => _transaction.cd = 'Debit'),
          ),
        ],
      ),
    );
  }
}
