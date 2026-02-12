import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';

enum TransactionStatus { pending, success, failed, pendingSync }

/// Transaction entity representing a fund transfer.
@freezed
class Transaction with _$Transaction {
  const factory Transaction({
    required String id,
    required String recipientEmail,
    required double amount,
    required String note,
    required TransactionStatus status,
    required DateTime timestamp,
  }) = _Transaction;

  const Transaction._();

  /// Check if transaction is in a terminal state
  bool get isTerminal =>
      status == TransactionStatus.success || status == TransactionStatus.failed;

  /// Check if transaction is awaiting synchronization
  bool get isPendingSync => status == TransactionStatus.pendingSync;
}
