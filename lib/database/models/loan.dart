import 'dart:math';
class Loan {
  final int? id;
  final DateTime loanDate;
  final double amount;
  final double interestRate;
  final String status;
  final String? entityName;
  final String role;
  final String? purpose;
  final String? remarks;

  Loan({
    this.id,
    required this.loanDate,
    required this.amount,
    required this.interestRate,
    required this.status,
    this.entityName,
    required this.role,
    this.purpose,
    this.remarks,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'loan_date': loanDate.toIso8601String(),
      'amount': amount,
      'interest_rate': interestRate,
      'status': status,
      'entityName': entityName,
      'role': role,
      'purpose': purpose,
      'remarks': remarks,
    };
  }

  static Loan fromMap(Map<String, dynamic> map) {
    return Loan(
      id: map['id'],
      loanDate: DateTime.parse(map['loan_date']),
      amount: map['amount'],
      interestRate: map['interest_rate'],
      status: map['status'],
      entityName: map['entityName'],
      role: map['role'],
      purpose: map['purpose'],
      remarks: map['remarks'],
    );
  }

  Loan copyWith({
    int? id,
    DateTime? loanDate,
    double? amount,
    double? interestRate,
    String? status,
    String? entityName,
    String? role,
    String? purpose,
    String? remarks,
  }) {
    return Loan(
      id: id ?? this.id,
      loanDate: loanDate ?? this.loanDate,
      amount: amount ?? this.amount,
      interestRate: interestRate ?? this.interestRate,
      status: status ?? this.status,
      entityName: entityName ?? this.entityName,
      role: role ?? this.role,
      purpose: purpose ?? this.purpose,
      remarks: remarks ?? this.remarks,
    );
  }

  double calculateCompoundInterest() {
    final double principal = amount;
    final double rate = interestRate / 100;
    final int n = 1; // Compounded annually
    final DateTime now = DateTime.now();
    final double t = now.difference(loanDate).inDays / 365.0;

    return principal * pow((1 + rate / n), n * t) - principal;
  }
 //write a method to calculate the total amount
  double calculateTotalAmount() {
    return amount + calculateCompoundInterest();
  }
} 