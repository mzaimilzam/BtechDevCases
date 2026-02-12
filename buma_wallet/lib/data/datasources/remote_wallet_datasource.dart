import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../core/network/api_client.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/failures/failure.dart';
import '../mappers/transaction_mapper.dart';
import '../mappers/wallet_mapper.dart';
import '../models/transaction_dto.dart';

/// Remote data source for wallet operations via API.
/// Handles all wallet and transaction-related network calls.
abstract interface class RemoteWalletDataSource {
  /// Fetch wallet balance from server
  Future<Wallet> getWalletBalance();

  /// Transfer funds to another user
  Future<Transaction> transferFund({
    required String recipientEmail,
    required double amount,
    required String note,
  });

  /// Fetch transaction history from server
  Future<List<Transaction>> getTransactionHistory({
    int limit = 20,
    int offset = 0,
  });
}

/// Implementation using Retrofit API client
@Injectable(as: RemoteWalletDataSource)
class RemoteWalletDataSourceImpl implements RemoteWalletDataSource {
  final ApiClient _apiClient;

  RemoteWalletDataSourceImpl(this._apiClient);

  @override
  Future<Wallet> getWalletBalance() async {
    try {
      final response = await _apiClient.getWalletBalance();
      return response.toDomain();
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<Transaction> transferFund({
    required String recipientEmail,
    required double amount,
    required String note,
  }) async {
    try {
      final request = TransferRequestDto(
        recipientEmail: recipientEmail,
        amount: amount,
        note: note,
      );
      final response = await _apiClient.transferFund(request);
      return response.toDomain();
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<List<Transaction>> getTransactionHistory({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final responses = await _apiClient.getTransactionHistory(
        limit: limit,
        offset: offset,
      );
      return responses.map((dto) => dto.toDomain()).toList();
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
