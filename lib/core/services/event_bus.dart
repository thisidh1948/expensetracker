import 'dart:async';

class TransactionEventBus {
  static final TransactionEventBus _instance = TransactionEventBus._internal();
  factory TransactionEventBus() => _instance;
  TransactionEventBus._internal();

  final _controller = StreamController<void>.broadcast();
  Stream<void> get onTransactionChanged => _controller.stream;

  void notifyTransactionChanged() {
    _controller.add(null);
  }

  void dispose() {
    _controller.close();
  }
} 