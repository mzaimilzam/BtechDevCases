import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_dto.freezed.dart';

/// DTO for transfer fund request
@freezed
class TransferRequestDto with _$TransferRequestDto {
  const TransferRequestDto._();

  const factory TransferRequestDto({
    required String recipientEmail,
    required double amount,
    required String note,
  }) = _TransferRequestDto;

  factory TransferRequestDto.fromJson(Map<String, dynamic> json) {
    return TransferRequestDto(
      recipientEmail: json['recipient_email'] as String,
      amount: (json['amount'] as num).toDouble(),
      note: json['note'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'recipient_email': recipientEmail,
        'amount': amount,
        'note': note,
      };
}

/// DTO for transaction response
@freezed
class TransactionResponseDto with _$TransactionResponseDto {
  const TransactionResponseDto._();

  const factory TransactionResponseDto({
    required String id,
    required String recipientEmail,
    required double amount,
    required String note,
    required String status,
    required String timestamp, // ISO 8601
  }) = _TransactionResponseDto;

  factory TransactionResponseDto.fromJson(Map<String, dynamic> json) {
    return TransactionResponseDto(
      id: json['id'] as String,
      recipientEmail: json['recipient_email'] as String,
      amount: (json['amount'] as num).toDouble(),
      note: json['note'] as String,
      status: json['status'] as String,
      timestamp: json['timestamp'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'recipient_email': recipientEmail,
        'amount': amount,
        'note': note,
        'status': status,
        'timestamp': timestamp,
      };
}
