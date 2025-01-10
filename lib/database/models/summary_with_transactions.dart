import 'dbtransaction.dart';

class SummaryWithTransactions {
  final double credit;
  final double debit;
  final double balance;
  final List<DbTransaction> transactions;

  const SummaryWithTransactions({
    required this.credit,
    required this.debit,
    required this.transactions,
  }) : balance = credit - debit;

  // Create from Map and transactions list
  factory SummaryWithTransactions.fromMap(
      Map<String, dynamic> map, List<DbTransaction> transactions) {
    return SummaryWithTransactions(
      credit: (map['credit'] as num?)?.toDouble() ?? 0.0,
      debit: (map['debit'] as num?)?.toDouble() ?? 0.0,
      transactions: transactions,
    );
  }

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'credit': credit,
      'debit': debit,
      'balance': balance,
      'transactions': transactions.map((t) => t.toMap()).toList(),
    };
  }

  // Copy with method
  SummaryWithTransactions copyWith({
    double? credit,
    double? debit,
    List<DbTransaction>? transactions,
  }) {
    return SummaryWithTransactions(
      credit: credit ?? this.credit,
      debit: debit ?? this.debit,
      transactions: transactions ?? this.transactions,
    );
  }

  // Equality operator
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SummaryWithTransactions &&
        other.credit == credit &&
        other.debit == debit &&
        other.transactions.length == transactions.length;
  }

  @override
  int get hashCode => Object.hash(credit, debit, transactions);

  // Helper method to format currency
  String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  // Getters for formatted values
  String get formattedCredit => formatCurrency(credit);

  String get formattedDebit => formatCurrency(debit);

  String get formattedBalance => formatCurrency(balance);
}
