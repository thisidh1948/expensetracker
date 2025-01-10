class Summary {
  final double credit;
  final double debit;
  final double balance;

  const Summary({
    required this.credit,
    required this.debit,
  }) : balance = credit - debit;

  // Create from Map
  factory Summary.fromMap(Map<String, dynamic> map) {
    return Summary(
      credit: (map['credit'] as num?)?.toDouble() ?? 0.0,
      debit: (map['debit'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Convert to Map
  Map<String, double> toMap() {
    return {
      'credit': credit,
      'debit': debit,
      'balance': balance,
    };
  }

  // Copy with method
  Summary copyWith({
    double? credit,
    double? debit,
  }) {
    return Summary(
      credit: credit ?? this.credit,
      debit: debit ?? this.debit,
    );
  }

  // ToString method for debugging
  @override
  String toString() {
    return 'AccountSummary(credit: $credit, debit: $debit, balance: $balance)';
  }

  // Equality operator
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Summary &&
        other.credit == credit &&
        other.debit == debit;
  }

  @override
  int get hashCode => Object.hash(credit, debit);

  // Helper method to format currency
  String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  // Getters for formatted values
  String get formattedCredit => formatCurrency(credit);
  String get formattedDebit => formatCurrency(debit);
  String get formattedBalance => formatCurrency(balance);
}