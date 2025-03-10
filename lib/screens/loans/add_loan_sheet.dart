import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../database/loans_crud.dart';
import '../../database/models/loan.dart';

class AddLoanSheet extends StatefulWidget {
  final String personRole;
  final Loan? loan;

  const AddLoanSheet({
    Key? key,
    required this.personRole,
    this.loan,
  }) : super(key: key);

  @override
  State<AddLoanSheet> createState() => _AddLoanSheetState();
}

class _AddLoanSheetState extends State<AddLoanSheet> {
  final _formKey = GlobalKey<FormState>();
  final _loansCRUD = LoansCRUD();

  late DateTime _selectedDate;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _interestRateController = TextEditingController();
  final TextEditingController _entityNameController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  final TextEditingController _remarksController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.loan != null) {
      _selectedDate = widget.loan!.loanDate;
      _amountController.text = widget.loan!.amount.toString();
      _interestRateController.text = widget.loan!.interestRate.toString();
      _entityNameController.text = widget.loan!.entityName ?? '';
      _purposeController.text = widget.loan!.purpose ?? '';
      _remarksController.text = widget.loan!.remarks ?? '';
    } else {
      _selectedDate = DateTime.now();
      _interestRateController.text = '0.0'; // Default interest rate
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveLoan() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final loan = Loan(
        id: widget.loan?.id,
        loanDate: _selectedDate,
        amount: double.parse(_amountController.text),
        interestRate: double.parse(_interestRateController.text),
        status: widget.loan?.status ?? 'unpaid',
        entityName: _entityNameController.text,
        role: widget.personRole,
        purpose: _purposeController.text,
        remarks: _remarksController.text.isEmpty ? null : _remarksController.text,
      );

      if (widget.loan == null) {
        await _loansCRUD.insert(loan);
      } else {
        await _loansCRUD.update(loan);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving loan: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.loan == null
                    ? 'Add ${widget.personRole == 'taker' ? 'Debt' : 'Loan'}'
                    : 'Edit ${widget.personRole == 'taker' ? 'Debt' : 'Loan'}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  'Date: ${_selectedDate.toLocal().toString().split(' ')[0]}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDate,
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '₹',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _interestRateController,
                decoration: const InputDecoration(
                  labelText: 'Interest Rate (% p.a.)',
                  suffixText: '%',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an interest rate';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid interest rate';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _entityNameController,
                decoration: const InputDecoration(
                  labelText: 'Entity Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an entity name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _purposeController,
                decoration: const InputDecoration(
                  labelText: 'Purpose',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a purpose';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _remarksController,
                decoration: const InputDecoration(
                  labelText: 'Remarks (Optional)',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveLoan,
                child: const Text('Save'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _interestRateController.dispose();
    _entityNameController.dispose();
    _purposeController.dispose();
    _remarksController.dispose();
    super.dispose();
  }
}
