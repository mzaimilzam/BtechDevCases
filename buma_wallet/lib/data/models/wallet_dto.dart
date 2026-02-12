import 'package:freezed_annotation/freezed_annotation.dart';

part 'wallet_dto.freezed.dart';

/// DTO for wallet balance response
@freezed
class WalletResponseDto with _$WalletResponseDto {
  const WalletResponseDto._();

  const factory WalletResponseDto({
    required double balance,
    required String currency,
  }) = _WalletResponseDto;

  factory WalletResponseDto.fromJson(Map<String, dynamic> json) {
    return WalletResponseDto(
      balance: (json['balance'] as num).toDouble(),
      currency: json['currency'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'balance': balance,
        'currency': currency,
      };
}
