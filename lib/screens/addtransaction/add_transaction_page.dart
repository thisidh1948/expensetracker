// add_transaction_page2.dart
import 'dart:async';

import 'package:expense_tracker/database/database_tables.dart';
import 'package:expense_tracker/screens/addtransaction/transaction_item_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../core/services/event_bus.dart';
import '../../database/appdata_crud.dart';
import '../../database/models/dbtransaction.dart';
import '../../database/models/mapping_model.dart';
import '../../database/models/struct_model.dart';
import '../../database/structures_crud.dart';
import '../../database/transactions_crud.dart';
import '../../widgets/customIcons.dart';
import '../../widgets/selection_field.dart';
import 'add_transfer_page.dart';

class AddTransactionPage extends StatefulWidget {
  final DbTransaction? transaction;
  final bool isUpdate;

  const AddTransactionPage({
    Key? key,
    this.transaction,
    this.isUpdate = true,
  }) : super(key: key);

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  late final TransactionFormState _formState;
  final _scrollController = ScrollController();
  bool _isProcessing = false;
  final StructuresCRUD _structuresCRUD = StructuresCRUD();

  @override
  void initState() {
    super.initState();
    _formState = _initializeFormState();
  }

  TransactionFormState _initializeFormState() {
    if (!widget.isUpdate || widget.transaction == null) {
      return TransactionFormState();
    }

    final tx = widget.transaction!;
    return TransactionFormState(
      account: tx.account,
      section: tx.section,
      category: tx.category,
      subcategory: tx.subcategory,
      date: tx.date,
      note: tx.note ?? '',
      isCredit: tx.cd == '1',
      items: [
        TransactionItem(
          item: tx.item ?? '',
          units: tx.units ?? 1,
          ppu: tx.ppu ?? 0,
          tax: tx.tax ?? 0,
          amount: tx.amount,
        )
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (var item in _formState.items) {
      item.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(widget.isUpdate ? 'Update Transaction' : 'New Transaction'),
      actions: [
        IconButton(
          icon: const Icon(Icons.swap_horiz),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddTransferPage()),
            );
          },
          tooltip: 'Transfer Money',
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(2),
              children: [
                _buildCommonFields(),
                const SizedBox(height: 8),
                _buildItemsList(),
                const SizedBox(height: 8),
                _buildAddItemAndSaveRow(),
                const SizedBox(height: 8),
                _buildSummary(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommonFields() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _buildAccountField()),
                const SizedBox(width: 12),
                Expanded(child: _buildSectionField()),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildCategoryField()),
                const SizedBox(width: 12),
                Expanded(child: _buildSubcategoryField()),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildDatePicker()),
                const SizedBox(width: 12),
                _buildTransactionTypeSwitch(),
              ],
            ),
            const SizedBox(height: 12),
            _buildNoteField(),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTypeSwitch() {
    return Container(
      height: 56, // Match height with other form fields,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Icon(
              _formState.isCredit ? Icons.arrow_downward : Icons.arrow_upward,
              color: _formState.isCredit ? Colors.green : Colors.red,
            ),
          ),
          Switch(
            value: _formState.isCredit,
            onChanged: (bool value) {
              setState(() {
                _formState.isCredit = value;
              });
            },
            activeColor: Colors.green,
            inactiveTrackColor: Colors.red.withOpacity(0.5),
            thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
              return _formState.isCredit ? Colors.green : Colors.red;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _formState.items.length,
      itemBuilder: (context, index) => _buildItemCard(index),
    );
  }

  Widget _buildItemCard(int index) {
    final item = _formState.items[index];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildItemHeader(index),
            const SizedBox(height: 8),
            _buildItemField(index),
            const SizedBox(height: 8),
            _buildItemCalculations(item),
          ],
        ),
      ),
    );
  }

  Widget _buildItemHeader(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Item ${index + 1}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (_formState.items.length > 1)
          IconButton(
            icon: const Icon(Icons.delete),
            color: Theme.of(context).colorScheme.error,
            onPressed: () => _removeItem(index),
            tooltip: 'Remove Item',
          ),
      ],
    );
  }

  Widget _buildSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Summary',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Items:'),
                Text('${_formState.items.length}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Amount:'),
                Text(
                  '₹${_formState.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addNewItem() {
    setState(() {
      _formState.items.add(TransactionItem());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _removeItem(int index) {
    setState(() {
      final item = _formState.items.removeAt(index);
      item.dispose();
    });
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) {
      _showError('Please fill in all required fields');
      return;
    }

    if (!_validateItems()) {
      return;
    }

    if (!mounted) return;
    setState(() => _isProcessing = true);

    try {
      final transactionCRUD = TransactionCRUD();
      final List<Future> transactions = [];

      for (final item in _formState.items) {
        if (item.amount <= 0) {
          throw ValidationException('Amount must be greater than 0');
        }

        final transaction = DbTransaction(
          id: widget.isUpdate && widget.transaction != null
              ? widget.transaction!.id
              : DateTime.now().millisecondsSinceEpoch,
          account: _formState.account!,
          category: _formState.category!,
          subcategory: _formState.subcategory!,
          cd: _formState.isCredit ? true : false,
          amount: item.amount,
          section: _formState.section,
          item: item.item,
          units: item.units,
          ppu: item.ppu,
          tax: item.tax,
          date: _formState.date,
          note: _formState.note.trim(),
        );

        if (widget.isUpdate && widget.transaction?.id != null) {
          transactions.add(transactionCRUD.update(transaction));
        } else {
          transactions.add(transactionCRUD.insert(transaction));
        }
      }

      await Future.wait(transactions).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Transaction timeout. Please try again.');
        },
      );

      TransactionEventBus().notifyTransactionChanged();

      if (!mounted) return;

      // Show success message first
      if (context.mounted) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.clearSnackBars();

        // Schedule navigation after SnackBar
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            Navigator.of(context).pop(true);
          }
        });

        // Show SnackBar
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              widget.isUpdate
                  ? 'Transaction updated successfully'
                  : 'Transaction added successfully',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(milliseconds: 1500),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  bool _validateItems() {
    if (_formState.items.isEmpty) {
      _showError('Add at least one item');
      return false;
    }

    for (int i = 0; i < _formState.items.length; i++) {
      final item = _formState.items[i];

      // Validate units
      if (item.units <= 0) {
        _showError('Units must be greater than 0 for Item ${i + 1}');
        return false;
      }

      // Validate price per unit
      if (item.ppu < 0) {
        _showError('Price per unit cannot be negative for Item ${i + 1}');
        return false;
      }

      // Validate tax
      if (item.tax < 0) {
        _showError('Tax cannot be negative for Item ${i + 1}');
        return false;
      }

      // Validate final amount
      if (item.amount <= 0) {
        _showError('Amount must be greater than 0 for Item ${i + 1}');
        return false;
      }
    }

    // Validate total amount
    if (_formState.totalAmount <= 0) {
      _showError('Total amount must be greater than 0');
      return false;
    }

    return true;
  }

  void _showError(String message) {
    if (!mounted) return;

    // Check if context is still valid
    if (context.mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {
              if (context.mounted) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              }
            },
          ),
        ),
      );
    }
  }

  Widget _buildAddItemAndSaveRow() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _addNewItem,
            icon: const Icon(Icons.add),
            label: const Text('Add Item'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 48),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isProcessing ? null : _saveTransaction,
            icon: _isProcessing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: Text(_isProcessing ? 'Saving...' : 'Save'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 48),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedFieldDisplay({
    required String label,
    required String value,
    required VoidCallback onTap,
    String? iconName,
    bool isRequired = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 40, // Reduced height for selected state
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            _buildFieldIcon(iconName ?? value),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
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

  Widget _buildFieldIcon(String value) {
    // Try to get custom icon first
    Widget? customIcon = CustomIcons.getIcon(value, size: 24);

    // If custom icon is the default fallback icon, create text-based icon
    if (customIcon == CustomIcons.getIcon('receipt', size: 24)) {
      return Text(
        _getInitials(value),
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    return customIcon;
  }

  String _getInitials(String value) {
    final words = value.trim().split(' ');
    if (words.length > 1) {
      return (words[0][0] + words[1][0]).toUpperCase();
    }
    return words[0].length > 1
        ? words[0].substring(0, 2).toUpperCase()
        : words[0].toUpperCase();
  }

  Widget _buildSelectionField({
    required String label,
    required String? value,
    required Future<List<StructModel>> Function() fetchItems,
    required Function(String?) onSelect,
    bool isRequired = false,
  }) {
    return FutureBuilder<List<StructModel>>(
      future: fetchItems(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error loading $label');
        }

        final items = snapshot.data ?? [];

        if (value != null) {
          // Show compact version when value is selected
          final selectedItem = items.firstWhere(
            (item) => item.name == value,
            orElse: () => StructModel(name: value, icon: null),
          );

          return _buildSelectedFieldDisplay(
            label: label,
            value: value,
            iconName: selectedItem.icon,
            onTap: () async {
              final selected = await _showSelectionDialog(
                context: context,
                title: label,
                items: items,
                selectedValue: value,
              );
              if (selected != null) {
                onSelect(selected);
              }
            },
            isRequired: isRequired,
          );
        }

        // Show full selection field when no value is selected
        return InkWell(
          onTap: () async {
            final selected = await _showSelectionDialog(
              context: context,
              title: label,
              items: items,
              selectedValue: value,
            );
            if (selected != null) {
              onSelect(selected);
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: isRequired ? '$label *' : label,
              border: const OutlineInputBorder(),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
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
      },
    );
  }

  Widget _buildAccountField() {
    return FutureBuilder<List<StructModel>>(
      future: _structuresCRUD.getAllTableData(ATableNames.accounts),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error loading Account');
        }
        return SelectionField(
          label: 'Bank',
          value: _formState.account,
          items: snapshot.data ?? [],
          onSelect: (String? value) {
            setState(() {
              _formState.account = value;
            });
          },
          isRequired: true,
        );
      },
    );
  }

  Widget _buildSectionField() {
    return _buildSelectionField(
      label: 'Section',
      value: _formState.section,
      fetchItems: () => _structuresCRUD.getAllTableData(ATableNames.sections),
      onSelect: (String? value) {
        setState(() {
          _formState.section = value;
        });
      },
      isRequired: true,
    );
  }

  Widget _buildCategoryField() {
    return _buildSelectionField(
      label: 'Category',
      value: _formState.category,
      fetchItems: () => _structuresCRUD.getAllTableData(ATableNames.categories),
      onSelect: (String? value) {
        setState(() {
          _formState.category = value;
          _formState.subcategory = null;
          for (var item in _formState.items) {
            item.item = null;
          }
        });
      },
      isRequired: true,
    );
  }

  Widget _buildSubcategoryField() {
    if (_formState.category == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<List<MappingModel>>(
      future: _structuresCRUD.getSubCategoriesForCategory(_formState.category!),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error loading subcategories');
        }

        // Convert MappingModel to StructModel for consistency
        final items = (snapshot.data ?? [])
            .map((mapping) => StructModel(
                  name: mapping.child,
                  icon: mapping.child, // Use the name as icon identifier
                ))
            .toList();

        final selectedItem = items.firstWhere(
          (item) => item.name == _formState.subcategory,
          orElse: () => StructModel(name: '', icon: null),
        );

        return InkWell(
          onTap: () async {
            final selected = await _showSelectionDialog(
              context: context,
              title: 'Subcategory',
              items: items,
              selectedValue: _formState.subcategory,
            );
            if (selected != null) {
              setState(() {
                _formState.subcategory = selected;
                // Reset items when subcategory changes
                for (var item in _formState.items) {
                  item.item = null;
                }
              });
            }
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Subcategory',
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
            child: Row(
              children: [
                if (_formState.subcategory != null)
                  CustomIcons.getIcon(selectedItem.icon ?? selectedItem.name,
                      size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _formState.subcategory ?? 'Select Subcategory',
                    style: _formState.subcategory == null
                        ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).hintColor,
                            )
                        : null,
                  ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildItemField(int index) {
    if (_formState.subcategory == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<List<MappingModel>>(
      future: _structuresCRUD.getItemsForSubcategory(_formState.subcategory!),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error loading items');
        }

        // Convert MappingModel to StructModel for consistency
        final items = (snapshot.data ?? [])
            .map((mapping) => StructModel(
                  name: mapping.child,
                  icon: mapping.child, // Use the name as icon identifier
                ))
            .toList();

        final selectedItem = items.firstWhere(
          (item) => item.name == _formState.items[index].item,
          orElse: () => StructModel(name: '', icon: null),
        );

        return InkWell(
          onTap: () async {
            final selected = await _showSelectionDialog(
              context: context,
              title: 'Item',
              items: items,
              selectedValue: _formState.items[index].item,
            );
            if (selected != null) {
              setState(() {
                _formState.items[index].item = selected;
              });
            }
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Item',
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
            child: Row(
              children: [
                if (_formState.items[index].item != null)
                  CustomIcons.getIcon(selectedItem.icon ?? selectedItem.name,
                      size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _formState.items[index].item ?? 'Select Item',
                    style: _formState.items[index].item == null
                        ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).hintColor,
                            )
                        : null,
                  ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildItemCalculations(TransactionItem item) {
    return Column(
      children: [
        // Units and Price per unit row
        Row(
          children: [
            Expanded(
              child: _buildNumberField(
                controller: item.unitsController,
                label: 'Units',
                onChanged: (value) {
                  item.recalculateAmount();
                  setState(() {});
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildNumberField(
                controller: item.ppuController,
                label: 'Price per unit',
                onChanged: (value) {
                  item.recalculateAmount();
                  setState(() {});
                },
                prefix: '₹',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Total Amount row
        _buildDisplayField(
          label: 'Total Amount',
          value: '₹${item.amount.toStringAsFixed(2)}',
          isHighlighted: false,
        ),

        // Tax percentage and Tax Amount row
        Row(
          children: [
            Expanded(
              child: _buildNumberField(
                controller: item.taxController,
                label: 'Tax %',
                onChanged: (value) {
                  item.recalculateAmount();
                  setState(() {});
                },
                suffix: '%',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildDisplayField(
                label: 'Tax Component',
                value: '₹${item.tax.toStringAsFixed(2)}',
                subtitle: '(included in total)',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    void Function(String)? onChanged,
    bool enabled = true,
    TextAlign textAlign = TextAlign.left,
    String? prefix,
    String? suffix,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        prefixText: prefix,
        suffixText: suffix,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: textAlign,
      enabled: enabled,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Required';
        }
        final number = double.tryParse(value);
        if (number == null || number < 0) {
          return 'Invalid number';
        }
        return null;
      },
    );
  }

  Widget _buildDisplayField({
    required String label,
    required String value,
    String? subtitle,
    bool isHighlighted = false,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        fillColor: isHighlighted
            ? Theme.of(context).colorScheme.primaryContainer
            : null,
        filled: isHighlighted,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: isHighlighted ? FontWeight.bold : null,
                  color: isHighlighted
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : null,
                ),
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _formState.date,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (picked != null && picked != _formState.date) {
          setState(() {
            _formState.date = picked;
          });
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('dd-MM-yyyy').format(_formState.date),
            ),
            const Icon(Icons.calendar_today, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Note',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
      initialValue: _formState.note,
      maxLines: 2,
      onChanged: (value) {
        _formState.note = value;
      },
    );
  }

  Future<String?> _showSelectionDialog({
    required BuildContext context,
    required String title,
    required List<StructModel> items,
    String? selectedValue,
  }) {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: double.maxFinite,
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search $title',
                      border: const OutlineInputBorder(),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onChanged: (value) {
                      // TODO: Implement search functionality
                    },
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isSelected = item.name == selectedValue;
                      return InkWell(
                        onTap: () => Navigator.of(context).pop(item.name),
                        child: Card(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primaryContainer
                              : null,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildFieldIcon(item.icon ?? item.name),
                              const SizedBox(height: 8),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
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
                    },
                  ),
                ),
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
      },
    );
  }
}

class ValidationException implements Exception {
  final String message;

  ValidationException(this.message);

  @override
  String toString() => message;
}
