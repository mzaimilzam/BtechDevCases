import '../../domain/entities/transaction.dart';
import '../models/transaction_dto.dart';

/// Extension for mapping TransactionResponseDto to Transaction domain entity
extension TransactionResponseDtoX on TransactionResponseDto {
  /// Convert TransactionResponseDto to Transaction domain entity
  Transaction toDomain() {
    return Transaction(
      id: id,
      recipientEmail: recipientEmail,
      amount: amount,
      note: note,
      status: _statusFromString(status),
      timestamp: DateTime.parse(timestamp),
    );
  }
}

/// Extension for mapping Transaction domain entity to JSON
extension TransactionX on Transaction {
  /// Convert Transaction to a JSON-serializable map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipient_email': recipientEmail,
      'amount': amount,
      'note': note,
      'status': _statusToString(status),
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// Helper function to convert string to TransactionStatus enum
TransactionStatus _statusFromString(String value) {
  return switch (value.toLowerCase()) {
    'pending' => TransactionStatus.pending,
    'success' => TransactionStatus.success,
    'failed' => TransactionStatus.failed,
    'pending_sync' => TransactionStatus.pendingSync,
    _ => TransactionStatus.failed,
  };
}

/// Helper function to convert TransactionStatus enum to string
String _statusToString(TransactionStatus status) {
  return switch (status) {
    TransactionStatus.pending => 'pending',
    TransactionStatus.success => 'success',
    TransactionStatus.failed => 'failed',
    TransactionStatus.pendingSync => 'pending_sync',
  };
}
