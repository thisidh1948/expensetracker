class Summary {
  final double credit;
  final double debit;
  final double balance;
  final double initialBalance;

  const Summary({
    required this.credit,
    required this.debit,
    required this.initialBalance,
    double? balance,
  }) : balance = initialBalance + credit - debit;

  // Create from Map
  factory Summary.fromMap(Map<String, dynamic> map) {
    return Summary(
      credit: (map['credit'] as num?)?.toDouble() ?? 0.0,
      debit: (map['debit'] as num?)?.toDouble() ?? 0.0,
      initialBalance: (map['initialBalance'] as num?)?.toDouble() ?? 0.0,
    );
  }

  // Convert to Map
  Map<String, double> toMap() {
    return {
      'credit': credit,
      'debit': debit,
      'balance': balance,
      'initialBalance': initialBalance,
    };
  }

  // Copy with method
  Summary copyWith({
    double? credit,
    double? debit,
    double? initialBalance,
  }) {
    return Summary(
      credit: credit ?? this.credit,
      debit: debit ?? this.debit,
      initialBalance: initialBalance ?? this.initialBalance,
    );
  }

  // ToString method for debugging
  @override
  String toString() {
    return 'AccountSummary(initialBalance: $initialBalance, credit: $credit, debit: $debit, balance: $balance)';
  }

  // Equality operator
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Summary &&
        other.credit == credit &&
        other.debit == debit &&
        other.initialBalance == initialBalance;
  }

  @override
  int get hashCode => Object.hash(credit, debit, initialBalance);

  // Helper method to format currency
  String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  // Getters for formatted values
  String get formattedCredit => formatCurrency(credit);
  String get formattedDebit => formatCurrency(debit);
  String get formattedBalance => formatCurrency(balance);
  String get formattedInitialBalance => formatCurrency(initialBalance);
}
