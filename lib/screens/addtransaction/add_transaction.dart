import 'package:expense_tracker/database/models/mapping_model.dart';
import 'package:expense_tracker/screens/home_screen.dart';
import 'package:expense_tracker/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:expense_tracker/database/structures_crud.dart';
import 'package:expense_tracker/database/transactions_crud.dart';
import 'package:expense_tracker/database/models/dbtransaction.dart';

import '../utils/id_generator.dart';

class AddTransactionPage extends StatefulWidget {
  final DbTransaction? transaction;

   AddTransactionPage({
    Key? key,
    this.transaction, // Add this parameter
  }) : super(key: key);

  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _unitsController = TextEditingController();
  final _ppuController = TextEditingController();
  final _taxController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  late DbTransaction _transaction;
  final TransactionCRUD _repository = TransactionCRUD();
  final StructuresCRUD _fieldManager = StructuresCRUD();

  List<String> _banks = [];
  List<String> _sections = [];
  List<String> _categories = [];
  List<String> _subcategories = [];
  List<String> _items = [];

  bool _isLoading = false;
  String _errorMessage = '';
  bool _cd = true; // true for Credit, false for Debit

  @override
  void initState() {
    super.initState();
    _initializeTransaction();
    _loadDropdownData();
  }

  void _initializeTransaction() {
    if (widget.transaction != null) {
      _transaction = widget.transaction!;
      print("id 78967901:");
      print(_transaction.id);
      _amountController.text = _transaction.amount.toString();
      _unitsController.text = _transaction.units?.toString() ?? '';
      _ppuController.text = _transaction.ppu?.toString() ?? '';
      _taxController.text = _transaction.tax?.toString() ?? '';
      _cd = _transaction.cd;
      _notesController.text = _transaction.note ?? '';
      _selectedDate = _transaction.date!;

      _loadExistingTransactionData();
    } else {
      _transaction = DbTransaction(
        account: '',
        section: '',
        category: '',
        subcategory: '',
        item: '',
        cd: true,
        note: '',
        units: 0.0,
        ppu: 0.0,
        tax: 0.0,
        amount: 0.0,
        date: DateTime.now(),
      );
    }
  }

  Future<void> _loadExistingTransactionData() async {
    if (_transaction.category.isNotEmpty) {
      await _loadSubcategories(_transaction.category);
    }
    if (_transaction.subcategory.isNotEmpty) {
      await _loadItems(_transaction.subcategory);
    }
  }

  Future<void> _loadDropdownData() async {
    setState(() => _isLoading = true);
    try {
      // Load your dropdown data from repository or service
      final banks = await _fieldManager.getAllNames('Accounts');
      final sections = await _fieldManager.getAllNames('Sections');
      final categories = await _fieldManager.getAllNames('Categories');

      setState(() {
        _banks = banks;
        _sections = sections;
        _categories = categories;
        if (widget.transaction == null) {
          _subcategories = [];
          _items = [];
        }
      });
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<String> getchild(List<MappingModel> model) {
    return model.map((e) => e.child).toList();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _loadSubcategories(String parentCategory) async {
    List<MappingModel> subcat =
        await StructuresCRUD().getSubCategoriesForCategory(parentCategory);

    setState(() {
      _subcategories = getchild(subcat);

      if (widget.transaction == null) {
        _transaction = _transaction.copyWith(subcategory: '');
      }
    });
  }

  Future<void> _loadItems(String parentSubCategory) async {
    List<MappingModel> items =
        await StructuresCRUD().getItemsForSubcategory(parentSubCategory);
    setState(() {
      _items = getchild(items);

      if (widget.transaction == null) {
        _transaction = _transaction.copyWith(item: '');
      }
    });
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      print('Saving transaction with id: ${widget.transaction?.id}');
      final transaction = DbTransaction(
        id: widget.transaction?.id ?? DateTime.now().millisecondsSinceEpoch,
        account: _transaction.account,
        section: _transaction.section,
        category: _transaction.category,
        subcategory: _transaction.subcategory,
        item: _transaction.item,
        cd: _cd,
        units: double.tryParse(_unitsController.text),
        ppu: double.tryParse(_ppuController.text),
        tax: double.tryParse(_taxController.text),
        amount: double.parse(_amountController.text),
        note: _notesController.text,
        date: _selectedDate,
      );

      if (widget.transaction?.id != null) {
        await _repository.update(transaction);
      } else {
        await _repository.insert(transaction);
      }
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
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
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    DropdownButtonFormField<String>(
                      value: _transaction.account.isEmpty
                          ? null
                          : _transaction.account,
                      decoration: const InputDecoration(labelText: 'Bank *'),
                      items: _banks.map((bank) {
                        return DropdownMenuItem(value: bank, child: Text(bank));
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _transaction =
                            _transaction.copyWith(account: value));
                      },
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _transaction.section!.isEmpty
                          ? null
                          : _transaction.section,
                      decoration: const InputDecoration(labelText: 'Section'),
                      items: _sections.map((section) {
                        return DropdownMenuItem(
                            value: section, child: Text(section));
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _transaction =
                            _transaction.copyWith(section: value));
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _transaction.category.isEmpty
                                ? null
                                : _transaction.category,
                            decoration:
                                const InputDecoration(labelText: 'Category *'),
                            items: _categories.map((category) {
                              return DropdownMenuItem(
                                  value: category, child: Text(category));
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _transaction =
                                  _transaction.copyWith(category: value));
                              _transaction = _transaction.copyWith(
                                  subcategory: '', item: '');
                              _subcategories = [];
                              _items = [];
                              if (value != null) {
                                _loadSubcategories(value);
                              }
                            },
                            validator: (value) => value == null || value.isEmpty
                                ? 'Required'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _transaction.subcategory.isEmpty
                                ? null
                                : _transaction.subcategory,
                            decoration: const InputDecoration(
                                labelText: 'Subcategory *'),
                            items: _subcategories.map((subcategory) {
                              return DropdownMenuItem(
                                  value: subcategory, child: Text(subcategory));
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _transaction =
                                  _transaction.copyWith(subcategory: value));
                              _transaction = _transaction.copyWith(item: '');
                              _items = [];
                              if (value != null) {
                                _loadItems(value);
                              }
                            },
                            validator: (value) => value == null || value.isEmpty
                                ? 'Required'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value:
                          _transaction.item!.isEmpty ? null : _transaction.item,
                      hint: const Text('Item'),
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Item',
                        border: OutlineInputBorder(),
                      ),
                      items: _items.map((item) {
                        return DropdownMenuItem(value: item, child: Text(item));
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _transaction =
                                _transaction.copyWith(item: newValue);
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select an item';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(labelText: 'Notes'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _unitsController,
                            decoration:
                                const InputDecoration(labelText: 'Units'),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d*')),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _ppuController,
                            decoration: const InputDecoration(
                                labelText: 'Price per Unit'),
                            keyboardType: TextInputType.name,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d*')),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _taxController,
                      decoration: const InputDecoration(labelText: 'Tax'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _amountController,
                            decoration:
                                const InputDecoration(labelText: 'Amount *'),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d*')),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Required';
                              if (double.tryParse(value) == null)
                                return 'Invalid number';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        SegmentedButton<bool>(
                          segments: const [
                            ButtonSegment(value: true, label: Text('Credit')),
                            ButtonSegment(value: false, label: Text('Debit')),
                          ],
                          selected: {_cd},
                          onSelectionChanged: (Set<bool> newSelection) {
                            setState(() => _cd = newSelection.first);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 56, // Give it a specific height
                      child: InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Date',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('dd-MM-yyyy').format(_selectedDate),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveTransaction,
                      child:
                          Text(widget.transaction == null ? 'Add' : 'Update'),
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
    _unitsController.dispose();
    _ppuController.dispose();
    _taxController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
