import 'package:expense_tracker/database/database_helper.dart';
import 'package:expense_tracker/database/fieldsmodel.dart';
import 'package:expense_tracker/database/transmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AddTransactionPage extends StatefulWidget {
  final TransModel? transaction;

  const AddTransactionPage({super.key, this.transaction});

  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  late TransModel _transaction;
  List<FieldModel> _accounts = [];
  List<FieldModel> _sections = [];
  List<FieldModel> _categories = [];
  List<FieldModel> _subcategories = [];
  bool _isLoading = false;
  String _errorMessage = '';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initializeTransaction();
    _loadDropdownData();
  }

  void _initializeTransaction() {
    _transaction = widget.transaction ??
        TransModel(
          account: '',
          section: '',
          category: '',
          subCategory: '',
          amount: 0.0,
          cd: '',
          note: '',
          date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        );

    if (widget.transaction != null) {
      _amountController.text = widget.transaction!.amount.toString();
      _descriptionController.text = widget.transaction!.note!;
      _selectedDate = DateFormat('yyyy-MM-dd').parse(widget.transaction!.date);
    }
  }

  Future<void> _loadDropdownData() async {
    setState(() => _isLoading = true);
    try {
      final db = DatabaseHelper();
      _accounts = await db.getFields('accounts');
      _sections = await db.getFields('sections');
      _categories = await db.getFields('categories');
      _subcategories = await db.getFields('subcategories');
    } catch (e) {
      setState(() => _errorMessage = 'Failed to load data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _transaction.date = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    try {
      final db = DatabaseHelper();
      if (widget.transaction == null) {
        await db.insertTransaction(_transaction);
      } else {
        await db.updateTransaction(_transaction);
      }
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save transaction: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transaction == null
            ? 'Add Transaction'
            : 'Edit Transaction'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_errorMessage.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(8),
                        color: Theme.of(context)
                            .colorScheme
                            .error
                            .withOpacity(0.1),
                        child: Text(
                          _errorMessage,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error),
                        ),
                      ),
                    DropdownButtonFormField<String>(
                      value: _transaction.account!.isNotEmpty
                          ? _transaction.account
                          : null,
                      decoration: const InputDecoration(labelText: 'Account'),
                      items: _accounts
                          .map((account) => DropdownMenuItem(
                                value: account.name,
                                child: Text(account.name),
                              ))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _transaction.account = value!),
                      validator: (value) =>
                          value == null ? 'Please select an account' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _transaction.section.isNotEmpty
                          ? _transaction.section
                          : null,
                      decoration: const InputDecoration(labelText: 'Section'),
                      items: _sections
                          .map((section) => DropdownMenuItem(
                                value: section.name,
                                child: Text(section.name),
                              ))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _transaction.section = value!),
                      validator: (value) =>
                          value == null ? 'Please select a section' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _transaction.category!.isNotEmpty
                          ? _transaction.category
                          : null,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: _categories
                          .map((category) => DropdownMenuItem(
                                value: category.name,
                                child: Text(category.name),
                              ))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _transaction.category = value!),
                      validator: (value) =>
                          value == null ? 'Please select a category' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _transaction.subCategory!.isNotEmpty
                          ? _transaction.subCategory
                          : null,
                      decoration:
                          const InputDecoration(labelText: 'Subcategory'),
                      items: _subcategories
                          .map((subcat) => DropdownMenuItem(
                                value: subcat.name,
                                child: Text(subcat.name),
                              ))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _transaction.subCategory = value!),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        prefixText: '₹',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Please enter amount' : null,
                      onSaved: (value) =>
                          _transaction.amount = double.parse(value!),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          ChoiceChip(
                            label: const Text('Credit'),
                            selected: _transaction.cd == 'Credit',
                            onSelected: (selected) =>
                                setState(() => _transaction.cd = 'Credit'),
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Debit'),
                            selected: _transaction.cd == 'Debit',
                            onSelected: (selected) =>
                                setState(() => _transaction.cd = 'Debit'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Transaction Date'),
                      subtitle:
                          Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _selectDate(context),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Description'),
                      maxLines: 3,
                      onSaved: (value) => _transaction.note = value!,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveTransaction,
                      child: Text(widget.transaction == null
                          ? 'Add Transaction'
                          : 'Update Transaction'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
