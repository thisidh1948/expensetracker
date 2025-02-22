import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/services/event_bus.dart';
import '../../database/models/dbtransaction.dart';
import '../../database/models/struct_model.dart';
import '../../database/structures_crud.dart';
import '../../database/transactions_crud.dart';
import '../../widgets/selection_field.dart';

class AddTransferPage extends StatefulWidget {
  const AddTransferPage({Key? key}) : super(key: key);

  @override
  State<AddTransferPage> createState() => _AddTransferPageState();
}

class _AddTransferPageState extends State<AddTransferPage> {
  final _formKey = GlobalKey<FormState>();
  final _structuresCRUD = StructuresCRUD();
  final _transactionsCRUD = TransactionCRUD();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String? _debitAccount;
  String? _creditAccount;
  DateTime _date = DateTime.now();
  bool _isProcessing = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer Money'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildAccountFields(),
            const SizedBox(height: 16),
            _buildAmountField(),
            const SizedBox(height: 16),
            _buildDatePicker(),
            const SizedBox(height: 16),
            _buildNoteField(),
            const SizedBox(height: 24),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountFields() {
    return Column(
      children: [
        _buildSelectionField(
          label: 'From Account',
          value: _debitAccount,
          fetchItems: () => _structuresCRUD.getAllTableData('accounts'),
          onSelect: (value) => setState(() => _debitAccount = value),
          isRequired: true,
        ),
        const SizedBox(height: 16),
        _buildSelectionField(
          label: 'To Account',
          value: _creditAccount,
          fetchItems: () => _structuresCRUD.getAllTableData('accounts'),
          onSelect: (value) => setState(() => _creditAccount = value),
          isRequired: true,
        ),
      ],
    );
  }

  Widget _buildSelectionField({
    required String label,
    required String? value,
    required Future<List<StructModel>> Function() fetchItems,
    required Function(String?) onSelect,
    required bool isRequired,
  }) {
    return FutureBuilder<List<StructModel>>(
      future: fetchItems(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error loading $label');
        }
        return SelectionField(
          label: label,
          value: value,
          items: snapshot.data ?? [],
          onSelect: onSelect,
          isRequired: isRequired,
        );
      },
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      decoration: const InputDecoration(
        labelText: 'Amount *',
        prefixText: '₹',
        border: OutlineInputBorder(),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter amount';
        }
        if (double.tryParse(value) == null || double.parse(value) <= 0) {
          return 'Please enter valid amount';
        }
        return null;
      },
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _date,
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        );
        if (picked != null && picked != _date) {
          setState(() => _date = picked);
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Date',
          border: OutlineInputBorder(),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('dd-MM-yyyy').format(_date)),
            const Icon(Icons.calendar_today, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteField() {
    return TextFormField(
      controller: _noteController,
      decoration: const InputDecoration(
        labelText: 'Note',
        border: OutlineInputBorder(),
      ),
      maxLines: 2,
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton.icon(
      onPressed: _isProcessing ? null : _saveTransfer,
      icon: _isProcessing
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.save),
      label: Text(_isProcessing ? 'Saving...' : 'Save Transfer'),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
      ),
    );
  }

  Future<void> _saveTransfer() async {
    if (!_formKey.currentState!.validate()) return;
    if (_debitAccount == null || _creditAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both accounts')),
      );
      return;
    }
    if (_debitAccount == _creditAccount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot transfer to same account')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final amount = double.parse(_amountController.text);
      final note = _noteController.text.trim();

      // Create debit transaction
      final debitTransaction = DbTransaction(
        account: _debitAccount!,
        section: 'TR',
        category: 'SELF TRANSFER',
        subcategory: 'SELF TRANSFER',
        item: '',
        amount: amount,
        date: _date,
        cd: false,
        // debit
        note: note,
      );

      // Create credit transaction
      final creditTransaction = DbTransaction(
        account: _creditAccount!,
        section: 'TR',
        category: 'SELF TRANSFER',
        subcategory: 'SELF TRANSFER',
        item: '',
        amount: amount,
        date: _date,
        cd: true,
        // credit
        note: note,
      );

      // Save both transactions
      await _transactionsCRUD.insert(debitTransaction);
      await _transactionsCRUD.insert(creditTransaction);
      TransactionEventBus().notifyTransactionChanged();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transfer saved successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving transfer: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}
