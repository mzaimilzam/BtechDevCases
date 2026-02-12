# Implementation Examples & Patterns

This document provides concrete code examples for extending the application.

---

## Example 1: Extending with a New Feature (Transaction Filtering)

### 1. Add Entity Filter Logic

**`lib/domain/entities/transaction_filter.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_filter.freezed.dart';

@freezed
class TransactionFilter with _$TransactionFilter {
  const factory TransactionFilter({
    @Default('') String searchEmail,
    @Default(null) double? minAmount,
    @Default(null) double? maxAmount,
    @Default(null) DateTime? startDate,
    @Default(null) DateTime? endDate,
  }) = _TransactionFilter;
}
```

### 2. Update Repository Interface

**`lib/domain/repositories/wallet_repository.dart`** (update existing method)

```dart
/// Get filtered transaction history
Future<Either<Failure, List<Transaction>>> getTransactionHistory({
  TransactionFilter? filter,
});
```

### 3. Implement in Data Layer

**`lib/data/repositories/wallet_repository_impl.dart`**

```dart
@override
Future<Either<Failure, List<Transaction>>> getTransactionHistory({
  TransactionFilter? filter,
}) async {
  try {
    // ... existing logic ...
    final allTransactions = [...remote, ...local];
    
    // Apply filter
    if (filter != null) {
      return Right(
        allTransactions.where((tx) {
          bool matches = true;
          
          if (filter.searchEmail.isNotEmpty) {
            matches &= tx.recipientEmail.contains(filter.searchEmail);
          }
          
          if (filter.minAmount != null) {
            matches &= tx.amount >= filter.minAmount!;
          }
          
          if (filter.maxAmount != null) {
            matches &= tx.amount <= filter.maxAmount!;
          }
          
          if (filter.startDate != null) {
            matches &= tx.timestamp.isAfter(filter.startDate!);
          }
          
          if (filter.endDate != null) {
            matches &= tx.timestamp.isBefore(filter.endDate!);
          }
          
          return matches;
        }).toList(),
      );
    }
    
    return Right(allTransactions);
  } catch (e) {
    return Left(UnknownFailure(e.toString()));
  }
}
```

### 4. Use in Presentation Layer

```dart
// In BLoC or state management
final result = await walletRepository.getTransactionHistory(
  filter: TransactionFilter(
    searchEmail: 'john@example.com',
    minAmount: 10000,
    startDate: DateTime(2024, 1, 1),
  ),
);

result.fold(
  (failure) => emit(TransactionHistoryError(failure.message)),
  (transactions) => emit(TransactionHistoryLoaded(transactions)),
);
```

---

## Example 2: Implementing Token Refresh

### Add Refresh Token Logic to AuthToken

**`lib/domain/entities/auth_token.dart`** (update)

```dart
@freezed
class AuthToken with _$AuthToken {
  const factory AuthToken({
    required String accessToken,
    String? refreshToken,
    required DateTime expiry,
  }) = _AuthToken;

  // ... existing methods ...

  /// Check if should refresh token (within 5 minutes of expiry)
  bool get shouldRefresh {
    final refreshThreshold = DateTime.now().add(Duration(minutes: 5));
    return expiry.isBefore(refreshThreshold);
  }
}
```

### Add Refresh Endpoint to API Client

**`lib/core/network/api_client.dart`**

```dart
@RestApi()
abstract class ApiClient {
  // ... existing methods ...

  @POST('/auth/refresh')
  Future<AuthResponseDto> refreshToken(
    @Body() RefreshTokenRequestDto request,
  );
}
```

### Update Auth Interceptor

**`lib/core/network/dio_interceptors.dart`**

```dart
class AuthInterceptor extends Interceptor {
  final SecureTokenStorage _tokenStorage;
  final ApiClient _apiClient;

  AuthInterceptor(this._tokenStorage, this._apiClient);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Get current token
    final token = await _tokenStorage.getAuthToken();

    if (token != null) {
      // Check if should refresh
      if (token.shouldRefresh && token.refreshToken != null) {
        try {
          // Refresh token
          final response = await _apiClient.refreshToken(
            RefreshTokenRequestDto(refreshToken: token.refreshToken!),
          );
          final newToken = response.toDomain();
          
          // Save new token
          await _tokenStorage.saveAuthToken(newToken);
          
          // Use new token for this request
          options.headers['Authorization'] = 'Bearer ${newToken.accessToken}';
        } catch (e) {
          // Refresh failed, clear and logout
          await _tokenStorage.clearAuthToken();
          // TODO: Navigate to login
        }
      } else if (token.isValid) {
        // Token still valid, use it
        options.headers['Authorization'] = 'Bearer ${token.accessToken}';
      }
    }

    return handler.next(options);
  }
}
```

---

## Example 3: Adding Connectivity Monitoring

### Create Connectivity Service

**`lib/core/network/connectivity_service.dart`**

```dart
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';

abstract interface class ConnectivityService {
  Stream<bool> get isOnline;
  Future<bool> checkConnectivity();
}

@Injectable(as: ConnectivityService)
class ConnectivityServiceImpl implements ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  @override
  Stream<bool> get isOnline => _connectivity.onConnectivityChanged
      .map((result) => result != ConnectivityResult.none);

  @override
  Future<bool> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
}
```

### Update Wallet Repository

**`lib/data/repositories/wallet_repository_impl.dart`**

```dart
class WalletRepositoryImpl implements WalletRepository {
  final ConnectivityService _connectivity;
  
  // ... existing code ...

  @override
  Future<Either<Failure, Transaction>> transferFund({...}) async {
    // ... validation code ...

    final isOnline = await _connectivity.checkConnectivity();

    if (isOnline) {
      // Send to server
      try {
        final remoteTransaction = await _remoteDataSource.transferFund(...);
        // ... cache and return ...
      } catch (e) {
        // Queue for later
        await _localDataSource.queueTransaction(transaction, userId);
        return Right(transaction.copyWith(status: TransactionStatus.pendingSync));
      }
    } else {
      // Offline: queue immediately
      await _localDataSource.queueTransaction(transaction, userId);
      return Right(transaction.copyWith(status: TransactionStatus.pendingSync));
    }
  }
}
```

### Listen to Connectivity in Presentation

```dart
// In your BLoC/state management
final connectivityService = getIt<ConnectivityService>();

connectivityService.isOnline.listen((isOnline) {
  if (isOnline) {
    // Trigger sync of pending transactions
    _walletRepository.syncPendingTransactions();
  }
});
```

---

## Example 4: Adding Request/Response Logging

### Create Logging Interceptor

**`lib/core/network/logging_interceptor.dart`**

```dart
import 'package:dio/dio.dart';
import 'dart:developer' as developer;

class DetailedLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    developer.log(
      '📤 [REQUEST] ${options.method} ${options.path}',
      name: 'HTTP',
      error: {
        'headers': options.headers,
        'params': options.queryParameters,
        'body': options.data,
      },
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    developer.log(
      '📥 [RESPONSE] ${response.statusCode} ${response.requestOptions.path}',
      name: 'HTTP',
      error: response.data,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    developer.log(
      '❌ [ERROR] ${err.type} ${err.requestOptions.path}',
      name: 'HTTP',
      error: {
        'message': err.message,
        'statusCode': err.response?.statusCode,
        'response': err.response?.data,
      },
    );
    handler.next(err);
  }
}
```

---

## Example 5: Batch Sync Operations

### Add Batch Sync Method

**`lib/domain/repositories/wallet_repository.dart`**

```dart
abstract interface class WalletRepository {
  // ... existing methods ...

  /// Sync multiple pending transactions in batch
  /// More efficient than syncing one-by-one
  Future<Either<Failure, BatchSyncResult>> batchSyncPending();
}
```

### Implement Batch Sync

**`lib/data/repositories/wallet_repository_impl.dart`**

```dart
@override
Future<Either<Failure, BatchSyncResult>> batchSyncPending() async {
  try {
    final userId = await _tokenStorage.getCurrentUserId();
    if (userId == null) {
      return Left(AuthFailure('User not authenticated'));
    }

    final pending = await _localDataSource.getPendingSyncTransactions(userId);
    if (pending.isEmpty) {
      return Right(BatchSyncResult(synced: 0, failed: 0));
    }

    int synced = 0;
    int failed = 0;

    // Batch requests to avoid rate limiting
    final batchSize = 5;
    for (int i = 0; i < pending.length; i += batchSize) {
      final batch = pending.sublist(
        i,
        i + batchSize > pending.length ? pending.length : i + batchSize,
      );

      // Wait for all in batch to complete
      await Future.wait(
        batch.map((tx) async {
          try {
            await _remoteDataSource.transferFund(
              recipientEmail: tx.recipientEmail,
              amount: tx.amount,
              note: tx.note,
            );
            await _localDataSource.updateTransactionStatus(
              tx.id,
              'success',
              syncedAt: DateTime.now(),
            );
            synced++;
          } catch (e) {
            await _localDataSource.updateTransactionStatus(
              tx.id,
              'failed',
              errorMessage: e.toString(),
            );
            failed++;
          }
        }),
      );

      // Small delay between batches
      await Future.delayed(Duration(milliseconds: 500));
    }

    return Right(BatchSyncResult(synced: synced, failed: failed));
  } catch (e) {
    return Left(UnknownFailure(e.toString()));
  }
}
```

---

## Example 6: Unit Testing a Repository

**`test/data/repositories/auth_repository_impl_test.dart`**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';

import 'package:buma_wallet/domain/entities/user.dart';
import 'package:buma_wallet/domain/failures/failure.dart';
import 'package:buma_wallet/data/repositories/auth_repository_impl.dart';
import 'package:buma_wallet/data/datasources/remote_auth_datasource.dart';
import 'package:buma_wallet/data/datasources/local_auth_datasource.dart';
import 'package:buma_wallet/core/storage/secure_token_storage.dart';

class MockRemoteAuthDataSource extends Mock
    implements RemoteAuthDataSource {}

class MockLocalAuthDataSource extends Mock
    implements LocalAuthDataSource {}

class MockSecureTokenStorage extends Mock
    implements SecureTokenStorage {}

void main() {
  group('AuthRepositoryImpl', () {
    late MockRemoteAuthDataSource mockRemote;
    late MockLocalAuthDataSource mockLocal;
    late MockSecureTokenStorage mockStorage;
    late AuthRepositoryImpl repository;

    setUp(() {
      mockRemote = MockRemoteAuthDataSource();
      mockLocal = MockLocalAuthDataSource();
      mockStorage = MockSecureTokenStorage();
      repository = AuthRepositoryImpl(mockRemote, mockLocal, mockStorage);
    });

    test('register validates email format', () async {
      // Act
      final result = await repository.register(
        email: 'invalid-email',
        password: 'password123',
        confirmPassword: 'password123',
      );

      // Assert
      expect(result.isLeft(), true);
      expect(
        result.fold((l) => l, (r) => null),
        isA<ValidationFailure>(),
      );
    });

    test('register calls remote data source on valid input', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';
      const confirmPassword = 'password123';

      when(
        () => mockRemote.register(
          email: email,
          password: password,
          confirmPassword: confirmPassword,
        ),
      ).thenAnswer((_) async => User(
        id: '123',
        email: email,
        name: 'Test User',
      ));

      // Act
      final result = await repository.register(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );

      // Assert
      expect(result.isRight(), true);
      verify(
        () => mockRemote.register(
          email: email,
          password: password,
          confirmPassword: confirmPassword,
        ),
      ).called(1);
    });

    test('register returns NetworkFailure when remote throws', () async {
      // Arrange
      when(
        () => mockRemote.register(
          email: any(named: 'email'),
          password: any(named: 'password'),
          confirmPassword: any(named: 'confirmPassword'),
        ),
      ).thenThrow(NetworkFailure('No internet'));

      // Act
      final result = await repository.register(
        email: 'test@example.com',
        password: 'password123',
        confirmPassword: 'password123',
      );

      // Assert
      expect(result.isLeft(), true);
      expect(
        result.fold((l) => l, (r) => null),
        isA<NetworkFailure>(),
      );
    });
  });
}
```

---

## Summary

These patterns demonstrate:
- ✅ Adding new entities and filters
- ✅ Implementing JWT refresh tokens
- ✅ Monitoring connectivity
- ✅ Enhanced logging
- ✅ Batch operations
- ✅ Comprehensive unit testing

All follow Clean Architecture principles and are easily testable!
