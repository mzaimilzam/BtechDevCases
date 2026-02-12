import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_token.freezed.dart';

/// AuthToken entity representing JWT tokens.
@freezed
class AuthToken with _$AuthToken {
  const factory AuthToken({
    required String accessToken,
    String? refreshToken,
    required DateTime expiry,
  }) = _AuthToken;

  const AuthToken._();

  /// Check if token is expired
  bool get isExpired => DateTime.now().isAfter(expiry);

  /// Check if token is valid (not expired)
  bool get isValid => !isExpired;

  /// Check if token will expire soon (within 5 minutes)
  bool get isExpiringSoon {
    final expiringThreshold = DateTime.now().add(const Duration(minutes: 5));
    return expiry.isBefore(expiringThreshold);
  }
}
