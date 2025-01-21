// add_transaction_page2.dart
import 'dart:async';

import 'package:expense_tracker/screens/addtransaction/transaction_item_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../database/appdata_crud.dart';
import '../../database/models/dbtransaction.dart';
import '../../database/models/mapping_model.dart';
import '../../database/structures_crud.dart';
import '../../database/transactions_crud.dart';

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
          item: tx.item,
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
        if (_isProcessing)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveTransaction,
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
                _buildAddItemButton(),
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
            // Account and Section Row
            Row(
              children: [
                Expanded(
                  child: _buildAccountDropdown(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSectionDropdown(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Category and Subcategory Row
            Row(
              children: [
                Expanded(
                  child: _buildCategoryDropdown(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSubcategoryDropdown(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Date and Transaction Type Row
            Row(
              children: [
                Expanded(
                  child: _buildDatePicker(),
                ),
                const SizedBox(width: 12),
                _buildTransactionTypeSwitch(),
              ],
            ),
            const SizedBox(height: 12),

            // Note Field (full width)
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
            _buildItemDropdown(index),
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
    // Validate form and items
    if (!_formKey.currentState!.validate()) {
      _showError('Please fill in all required fields');
      return;
    }

    if (!_validateItems()) {
      return; // _validateItems already shows error message
    }

    // Show processing state
    setState(() => _isProcessing = true);

    try {
      final transactionCRUD = TransactionCRUD();
      final List<Future> transactions = [];

      // Prepare all transactions
      for (final item in _formState.items) {
        // Validate item amounts
        if (item.amount <= 0) {
          throw ValidationException('Amount must be greater than 0');
        }

        final transaction = DbTransaction(
          // Required fields
          id: widget.isUpdate && widget.transaction != null
              ? widget.transaction!.id
              : DateTime.now().millisecondsSinceEpoch,
          account: _formState.account!,
          category: _formState.category!,
          subcategory: _formState.subcategory!,
          cd: _formState.isCredit ? true : false,
          amount: item.amount,

          // Optional fields
          section: _formState.section,
          item: item.item,
          units: item.units,
          ppu: item.ppu,
          tax: item.tax,
          date: _formState.date,
          note: _formState.note.trim(),
        );

        // Add to transaction batch
        if (widget.isUpdate && widget.transaction?.id != null) {
          transactions.add(transactionCRUD.update(transaction));
        } else {
          transactions.add(transactionCRUD.insert(transaction));
        }
      }

      // Execute all transactions
      await Future.wait(transactions).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Transaction timeout. Please try again.');
        },
      );

      // Show success message and close page
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isUpdate
                ? 'Transaction updated successfully'
                : 'Transaction added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } on ValidationException catch (e) {
      _showError(e.message);
    } on TimeoutException catch (e) {
      _showError(e.message ?? 'Transaction timeout');
    } on DatabaseException catch (e) {
      _showError('Database error: ${e.message}');
    } catch (e) {
      _showError('An unexpected error occurred: ${e.toString()}');
    } finally {
      // Reset processing state if still mounted
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

      // Validate item selection
      if (item.item == null || item.item!.isEmpty) {
        _showError('Please select an item for Item ${i + 1}');
        return false;
      }

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
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Widget _buildAddItemButton() {
    return ElevatedButton.icon(
      onPressed: _addNewItem,
      icon: const Icon(Icons.add),
      label: const Text('Add Item'),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
      ),
    );
  }

  Widget _buildAccountDropdown() {
    return FutureBuilder<List<String>>(
      future: StructuresCRUD().getAllNames('Accounts'),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error loading accounts');
        }

        return DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Account',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          value: _formState.account,
          items: (snapshot.data ?? []).map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Required';
            }
            return null;
          },
          onChanged: (String? newValue) {
            setState(() {
              _formState.account = newValue;
              _formState.section = null;
              _formState.category = null;
              _formState.subcategory = null;
            });
          },
        );
      },
    );
  }

  Widget _buildSectionDropdown() {
    return FutureBuilder<List<String>>(
      future: StructuresCRUD().getAllNames('Sections'),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error loading sections');
        }

        return DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Section',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          value: _formState.section,
          items: (snapshot.data ?? []).map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _formState.section = newValue;
              _formState.category = null;
              _formState.subcategory = null;
            });
          },
        );
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return FutureBuilder<List<String>>(
      future: StructuresCRUD().getAllNames('Categories'),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error loading categories');
        }

        return DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Category',
            border: OutlineInputBorder(),
          ),
          value: _formState.category,
          items: (snapshot.data ?? []).map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a category';
            }
            return null;
          },
          onChanged: (String? newValue) {
            setState(() {
              _formState.category = newValue;
              _formState.subcategory = null;
            });
          },
        );
      },
    );
  }

  Widget _buildSubcategoryDropdown() {
    if (_formState.category == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<List<MappingModel>>(
      future:
          StructuresCRUD().getSubCategoriesForCategory(_formState.category!),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error loading subcategories');
        }

        final subcategories =
            snapshot.data?.map((mapping) => mapping.child).toList() ?? [];

        return DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Subcategory',
            border: OutlineInputBorder(),
          ),
          value: _formState.subcategory,
          items: subcategories.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a subcategory';
            }
            return null;
          },
          onChanged: (String? newValue) {
            setState(() {
              _formState.subcategory = newValue;
              // Reset items when subcategory changes
              for (var item in _formState.items) {
                item.item = null;
              }
            });
          },
        );
      },
    );
  }

  Widget _buildItemDropdown(int index) {
    if (_formState.subcategory == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<List<MappingModel>>(
      future: StructuresCRUD().getItemsForSubcategory(_formState.subcategory!),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error loading items');
        }

        final items =
            snapshot.data?.map((mapping) => mapping.child).toList() ?? [];

        return DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Item',
            border: OutlineInputBorder(),
          ),
          value: _formState.items[index].item,
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select an item';
            }
            return null;
          },
          onChanged: (String? newValue) {
            setState(() {
              _formState.items[index].item = newValue;
            });
          },
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
        const SizedBox(height:12),

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
}

class ValidationException implements Exception {
  final String message;

  ValidationException(this.message);

  @override
  String toString() => message;
}
