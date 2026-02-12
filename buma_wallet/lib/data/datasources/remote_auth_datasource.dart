import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../core/network/api_client.dart';
import '../../core/storage/secure_token_storage.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/entities/user.dart';
import '../../domain/failures/failure.dart';
import '../mappers/auth_mapper.dart';
import '../models/auth_request_dto.dart';

/// Remote data source for authentication via API.
/// Handles all authentication-related network calls.
abstract interface class RemoteAuthDataSource {
  /// Register a new user
  Future<User> register({
    required String email,
    required String password,
    required String confirmPassword,
  });

  /// Login user and get JWT token
  Future<(User, AuthToken)> login({
    required String email,
    required String password,
  });

  /// Get current authenticated user profile
  Future<User> getCurrentUser();

  /// Refresh access token using refresh token
  Future<AuthToken> refreshToken(String refreshToken);
}

/// Implementation using Retrofit API client
@Injectable(as: RemoteAuthDataSource)
class RemoteAuthDataSourceImpl implements RemoteAuthDataSource {
  final ApiClient _apiClient;
  final SecureTokenStorage _tokenStorage;

  RemoteAuthDataSourceImpl(
    this._apiClient,
    this._tokenStorage,
  );

  @override
  Future<User> register({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final request = RegisterRequestDto(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );
      final response = await _apiClient.register(request);

      // Save token securely (registration also returns tokens)
      final token = response.toDomain();
      await _tokenStorage.saveAuthToken(token);

      // Return a User object with the registered email
      return User(
        id: '', // ID will be fetched on next getCurrentUser call
        email: email,
        name: '',
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<(User, AuthToken)> login({
    required String email,
    required String password,
  }) async {
    try {
      final request = LoginRequestDto(email: email, password: password);
      final authResponse = await _apiClient.login(request);

      // Save token securely
      await _tokenStorage.saveAuthToken(authResponse.toDomain());

      // Get user profile
      final userResponse = await _apiClient.getCurrentUser();
      final user = userResponse.toDomain();
      final token = authResponse.toDomain();

      return (user, token);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<User> getCurrentUser() async {
    try {
      final response = await _apiClient.getCurrentUser();
      return response.toDomain();
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<AuthToken> refreshToken(String refreshTokenStr) async {
    try {
      final response = await _apiClient.refreshToken(refreshTokenStr);
      // Save new token securely
      final token = response.toDomain();
      await _tokenStorage.saveAuthToken(token);
      return token;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Convert Dio exceptions to domain-level failures
  Exception _handleDioException(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      throw NetworkFailure(error.message ?? 'Network timeout');
    }

    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        throw const AuthFailure('Invalid credentials or unauthorized access');
      }
      if (statusCode! >= 400 && statusCode < 500) {
        throw ServerFailure(
          error.response!.data?['message'] ?? 'Client error',
          statusCode,
        );
      }
      if (statusCode >= 500) {
        throw ServerFailure(
          error.response!.data?['message'] ?? 'Server error',
          statusCode,
        );
      }
    }

    throw NetworkFailure(error.message ?? 'Unknown network error');
  }
}
