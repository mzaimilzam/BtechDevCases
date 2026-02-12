import 'package:dio/dio.dart';

import '../../data/models/auth_request_dto.dart';
import '../../data/models/auth_response_dto.dart';
import '../../data/models/transaction_dto.dart';
import '../../data/models/wallet_dto.dart';

/// API client for backend communication.
/// This is a wrapper around Dio with type-safe endpoints.
abstract class ApiClient {
  factory ApiClient(Dio dio, {String? baseUrl}) =>
      _ApiClientImpl(dio, baseUrl: baseUrl);

  // ============ AUTH ENDPOINTS ============

  /// Register a new user account
  /// POST /auth/register
  /// Returns both user and auth tokens
  Future<AuthResponseDto> register(RegisterRequestDto request);

  /// Login with email and password, returns JWT tokens
  /// POST /auth/login
  Future<AuthResponseDto> login(LoginRequestDto request);

  /// Get current user profile (requires authentication)
  /// GET /auth/me
  Future<UserResponseDto> getCurrentUser();

  /// Refresh access token using refresh token
  /// POST /auth/refresh
  Future<AuthResponseDto> refreshToken(String refreshToken);

  // ============ WALLET ENDPOINTS ============

  /// Get wallet balance (requires authentication)
  /// GET /wallet/balance
  Future<WalletResponseDto> getWalletBalance();

  /// Transfer funds to another user (offline-first capable)
  /// POST /wallet/transfer
  /// Returns transaction details
  Future<TransactionResponseDto> transferFund(TransferRequestDto request);

  /// Get transaction history (requires authentication)
  /// GET /wallet/transactions
  /// Query parameters:
  ///   - limit: number of records (default: 20)
  ///   - offset: pagination offset (default: 0)
  Future<List<TransactionResponseDto>> getTransactionHistory({
    int limit = 20,
    int offset = 0,
  });
}

/// Implementation of ApiClient
class _ApiClientImpl implements ApiClient {
  _ApiClientImpl(
    this._dio, {
    this.baseUrl,
  });

  final Dio _dio;
  final String? baseUrl;

  @override
  Future<AuthResponseDto> register(RegisterRequestDto request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '${baseUrl ?? ''}/auth/register',
        data: request.toJson(),
      );
      return AuthResponseDto.fromJson(response.data!);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AuthResponseDto> login(LoginRequestDto request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '${baseUrl ?? ''}/auth/login',
        data: request.toJson(),
      );
      return AuthResponseDto.fromJson(response.data!);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserResponseDto> getCurrentUser() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '${baseUrl ?? ''}/auth/current-user',
      );
      return UserResponseDto.fromJson(
          response.data!['user'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AuthResponseDto> refreshToken(String refreshTokenStr) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '${baseUrl ?? ''}/auth/refresh',
        data: {'refreshToken': refreshTokenStr},
      );
      return AuthResponseDto.fromJson(response.data!);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<WalletResponseDto> getWalletBalance() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '${baseUrl ?? ''}/wallet/balance',
      );
      // Extract wallet object from response
      return WalletResponseDto.fromJson(
          response.data!['wallet'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<TransactionResponseDto> transferFund(
      TransferRequestDto request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '${baseUrl ?? ''}/wallet/transfer',
        data: request.toJson(),
      );
      return TransactionResponseDto.fromJson(response.data!);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<TransactionResponseDto>> getTransactionHistory({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '${baseUrl ?? ''}/wallet/transactions',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );
      return (response.data ?? [])
          .map(
              (e) => TransactionResponseDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}
