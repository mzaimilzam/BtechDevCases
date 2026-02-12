import '../../domain/entities/wallet.dart';
import '../models/wallet_dto.dart';

/// Extension for mapping WalletResponseDto to Wallet domain entity
extension WalletResponseDtoX on WalletResponseDto {
  /// Convert WalletResponseDto to Wallet domain entity
  Wallet toDomain() {
    return Wallet(
      balance: balance,
      currency: _currencyFromString(currency),
      lastUpdated: DateTime.now(),
    );
  }
}

/// Extension for mapping Wallet domain entity to JSON
extension WalletX on Wallet {
  /// Convert Wallet to a JSON-serializable map
  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
      'currency': _currencyToString(currency),
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
}

/// Helper function to convert string to Currency enum
Currency _currencyFromString(String value) {
  return switch (value.toUpperCase()) {
    'IDR' => Currency.idr,
    'USD' => Currency.usd,
    _ => Currency.idr,
  };
}

/// Helper function to convert Currency enum to string
String _currencyToString(Currency currency) {
  return switch (currency) {
    Currency.idr => 'IDR',
    Currency.usd => 'USD',
  };
}
