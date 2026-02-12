import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/auth_token.dart';

/// Abstract interface for secure token storage.
/// Implements secure storage of JWT tokens and user information.
abstract interface class SecureTokenStorage {
  /// Save authentication token securely
  Future<void> saveAuthToken(AuthToken token);

  /// Get stored authentication token
  Future<AuthToken?> getAuthToken();

  /// Get access token string
  Future<String?> getAccessToken();

  /// Get current user ID
  Future<String?> getCurrentUserId();

  /// Save current user ID
  Future<void> saveCurrentUserId(String userId);

  /// Clear all authentication data
  Future<void> clearAuthToken();
}

/// Implementation using flutter_secure_storage
@Injectable(as: SecureTokenStorage)
class SecureTokenStorageImpl implements SecureTokenStorage {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _userIdKey = 'user_id';

  final FlutterSecureStorage _secureStorage;

  SecureTokenStorageImpl(this._secureStorage);

  @override
  Future<void> saveAuthToken(AuthToken token) async {
    await Future.wait([
      _secureStorage.write(key: _tokenKey, value: token.accessToken),
      if (token.refreshToken != null)
        _secureStorage.write(
          key: _refreshTokenKey,
          value: token.refreshToken!,
        ),
      _secureStorage.write(
        key: _tokenExpiryKey,
        value: token.expiry.toIso8601String(),
      ),
    ]);
  }

  @override
  Future<AuthToken?> getAuthToken() async {
    final token = await _secureStorage.read(key: _tokenKey);
    if (token == null) return null;

    final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
    final expiryStr = await _secureStorage.read(key: _tokenExpiryKey);

    if (expiryStr == null) return null;

    return AuthToken(
      accessToken: token,
      refreshToken: refreshToken,
      expiry: DateTime.parse(expiryStr),
    );
  }

  @override
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  @override
  Future<String?> getCurrentUserId() async {
    return await _secureStorage.read(key: _userIdKey);
  }

  @override
  Future<void> saveCurrentUserId(String userId) async {
    await _secureStorage.write(key: _userIdKey, value: userId);
  }

  @override
  Future<void> clearAuthToken() async {
    await Future.wait([
      _secureStorage.delete(key: _tokenKey),
      _secureStorage.delete(key: _refreshTokenKey),
      _secureStorage.delete(key: _tokenExpiryKey),
      _secureStorage.delete(key: _userIdKey),
    ]);
  }
}
