import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction.freezed.dart';

enum TransactionStatus { pending, success, failed, cancelled }

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
    String? syncErrorMessage,
  }) = _Transaction;

  const Transaction._();

  /// Check if transaction is in a terminal state
  bool get isTerminal =>
      status == TransactionStatus.success ||
      status == TransactionStatus.failed ||
      status == TransactionStatus.cancelled;

  /// Check if transaction can be synced
  bool get canSync => status == TransactionStatus.pending;

  /// Check if transaction can be cancelled
  bool get canCancel => status == TransactionStatus.pending;
}
