import 'package:freezed_annotation/freezed_annotation.dart';

part 'wallet.freezed.dart';

enum Currency { idr, usd }

/// Wallet entity representing user's wallet information.
@freezed
class Wallet with _$Wallet {
  const factory Wallet({
    required double balance,
    required Currency currency,
    required DateTime lastUpdated,
  }) = _Wallet;

  const Wallet._();

  /// Check if wallet has sufficient balance for transfer
  bool hasSufficientBalance(double amount) => balance >= amount;
}
