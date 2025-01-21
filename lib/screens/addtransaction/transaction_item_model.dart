// transaction_item_model.dart
import 'package:flutter/cupertino.dart';

class TransactionItem {
  String? item;
  double units;
  double ppu;
  double tax;
  double amount;
  final TextEditingController unitsController;
  final TextEditingController ppuController;
  final TextEditingController taxController;
  final TextEditingController amountController;

  TransactionItem({
    this.item,
    this.units = 1,
    this.ppu = 0,
    this.tax = 0,
    this.amount = 0,
  })  : unitsController = TextEditingController(text: '1'),
        ppuController = TextEditingController(text: '0'),
        taxController = TextEditingController(text: '0'),
        amountController = TextEditingController(text: '0');

  void dispose() {
    unitsController.dispose();
    ppuController.dispose();
    taxController.dispose();
    amountController.dispose();
  }

  void recalculateAmount() {
    units = double.tryParse(unitsController.text) ?? 0;
    ppu = double.tryParse(ppuController.text) ?? 0;
    double taxPercentage = double.tryParse(taxController.text) ?? 0;

    amount = (units * ppu);
    tax = amount * (taxPercentage / 100);

    amountController.text = amount.toStringAsFixed(2);
  }

  Map<String, dynamic> toMap() {
    return {
      'item': item,
      'units': units,
      'ppu': ppu,
      'tax': tax,
      'amount': amount,
    };
  }
}

// transaction_form_state.dart
class TransactionFormState {
  String? account;
  String? section;
  String? category;
  String? subcategory;
  DateTime date;
  String note;
  bool isCredit;
  List<TransactionItem> items;

  TransactionFormState({
    this.account,
    this.section,
    this.category,
    this.subcategory,
    DateTime? date,
    this.note = '',
    this.isCredit = false,
    List<TransactionItem>? items,
  })  : date = date ?? DateTime.now(),
        items = items ?? [TransactionItem()];

  double get totalAmount => items.fold(0.0, (sum, item) => sum + item.amount);
}
