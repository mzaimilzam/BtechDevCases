import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

import '../../core/storage/secure_token_storage.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/wallet.dart';
import '../../domain/failures/failure.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/local_wallet_datasource.dart';
import '../datasources/remote_wallet_datasource.dart';

/// Implementation of WalletRepository with offline-first pattern.
///
/// Core offline-first logic:
/// - Read operations: Try remote → fallback to local cache
/// - Write operations: Queue locally if offline → sync when online
/// - Transaction queue: Stores pending transfers for later synchronization
@Injectable(as: WalletRepository)
class WalletRepositoryImpl implements WalletRepository {
  final RemoteWalletDataSource _remoteDataSource;
  final LocalWalletDataSource _localDataSource;
  final SecureTokenStorage _tokenStorage;

  WalletRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._tokenStorage,
  );

  @override
  Future<Either<Failure, Wallet>> getWalletBalance() async {
    try {
      // Try to fetch from remote
      try {
        final wallet = await _remoteDataSource.getWalletBalance();
        // Cache locally on success
        final userId = await _tokenStorage.getCurrentUserId();
        if (userId != null) {
          await _localDataSource.cacheWallet(wallet, userId);
        }
        return Right(wallet);
      } on NetworkFailure catch (_) {
        // Network error: try local cache
        final userId = await _tokenStorage.getCurrentUserId();
        if (userId != null) {
          final cachedWallet =
              await _localDataSource.getWalletCacheByUserId(userId);
          if (cachedWallet != null) {
            return Right(cachedWallet);
          }
        }
        rethrow; // No cache available, propagate error
      }
    } on NetworkFailure catch (e) {
      return Left(e);
    } on ServerFailure catch (e) {
      return Left(e);
    } on CacheFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Transaction>> transferFund({
    required String recipientEmail,
    required double amount,
    required String note,
  }) async {
    try {
      // Validation
      if (recipientEmail.isEmpty || !recipientEmail.contains('@')) {
        return const Left(ValidationFailure('Invalid recipient email'));
      }
      if (amount <= 0) {
        return const Left(ValidationFailure('Amount must be greater than 0'));
      }

      final userId = await _tokenStorage.getCurrentUserId();
      if (userId == null) {
        return const Left(AuthFailure('User not authenticated'));
      }

      // Create transaction ID
      const uuid = Uuid();
      final transactionId = uuid.v4();
      final now = DateTime.now();

      final transaction = Transaction(
        id: transactionId,
        recipientEmail: recipientEmail,
        amount: amount,
        note: note,
        status: TransactionStatus.pending,
        timestamp: now,
      );

      // OFFLINE-FIRST: Save to local database immediately
      await _localDataSource.insertTransaction(transaction, userId);

      // Try to sync to API
      if (await _isOnline()) {
        try {
          final remoteTransaction = await _remoteDataSource.transferFund(
            recipientEmail: recipientEmail,
            amount: amount,
            note: note,
          );

          // Update local transaction status to success
          await _localDataSource.updateTransactionStatus(
            transactionId,
            'success',
            syncedAt: DateTime.now(),
          );

          return Right(remoteTransaction);
        } catch (e) {
          // API call failed but transaction is saved locally as pending
          // User can retry sync later
          return Right(transaction); // Return pending transaction
        }
      } else {
        // Offline: Transaction saved locally as pending
        return Right(transaction);
      }
    } on ValidationFailure catch (e) {
      return Left(e);
    } on AuthFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getTransactionHistory() async {
    try {
      final userId = await _tokenStorage.getCurrentUserId();
      if (userId == null) {
        return const Left(AuthFailure('User not authenticated'));
      }

      // Try to fetch from remote
      try {
        final remoteTransactions =
            await _remoteDataSource.getTransactionHistory();

        // Update local cache with remote data
        for (final transaction in remoteTransactions) {
          if (transaction.status == TransactionStatus.success ||
              transaction.status == TransactionStatus.failed) {
            // TODO: Add to transaction history table
          }
        }

        // Combine with pending transactions
        final pendingTransactions =
            await _localDataSource.getPendingSyncTransactions(userId);

        final allTransactions = [...remoteTransactions, ...pendingTransactions];
        allTransactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        return Right(allTransactions);
      } on NetworkFailure catch (_) {
        // Network error: return only local transactions
        final localTransactions =
            await _localDataSource.getTransactionHistory(userId);
        return Right(localTransactions);
      }
    } on AuthFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
  @override
  Future<Either<Failure, Transaction>> syncTransaction(
    String transactionId,
  ) async {
    try {
      final userId = await _tokenStorage.getCurrentUserId();
      if (userId == null) {
        return const Left(AuthFailure('User not authenticated'));
      }

      // Get transaction from local DB
      // NOTE: Need to add getTransaction method to LocalWalletDataSource
      // For now, using the queue method
      final pendingTransactions =
          await _localDataSource.getPendingTransactions(userId);
      final transaction = pendingTransactions.firstWhere(
        (t) => t.id == transactionId,
        orElse: () => throw Exception('Transaction not found'),
      );

      // Try to sync to API
      try {
        final remoteTransaction = await _remoteDataSource.transferFund(
          recipientEmail: transaction.recipientEmail,
          amount: transaction.amount,
          note: transaction.note,
        );

        // Update local transaction status to success
        await _localDataSource.updateTransactionStatus(
          transactionId,
          'success',
          syncedAt: DateTime.now(),
        );

        return Right(remoteTransaction);
      } catch (e) {
        // Update with error status
        await _localDataSource.updateTransactionStatus(
          transactionId,
          'failed',
          errorMessage: e.toString(),
        );

        return Left(ServerFailure(
          'Failed to sync transaction: ${e.toString()}',
          null,
        ));
      }
    } on AuthFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Transaction>> cancelTransaction(
    String transactionId,
  ) async {
    try {
      final userId = await _tokenStorage.getCurrentUserId();
      if (userId == null) {
        return const Left(AuthFailure('User not authenticated'));
      }

      // Get transaction from local DB
      final allTransactions =
          await _localDataSource.getAllTransactions(userId);
      final transaction = allTransactions.firstWhere(
        (t) => t.id == transactionId,
        orElse: () => throw Exception('Transaction not found'),
      );

      // Can only cancel pending transactions
      if (transaction.status != TransactionStatus.pending) {
        return Left(
          ValidationFailure(
            'Cannot cancel ${transaction.status.toString()} transaction',
          ),
        );
      }

      // Update local transaction status to cancelled
      await _localDataSource.cancelTransaction(transactionId);

      // Return cancelled transaction
      final cancelledTransaction = transaction.copyWith(
        status: TransactionStatus.cancelled,
      );

      return Right(cancelledTransaction);
    } on AuthFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Simple connectivity check
  /// In production, use connectivity_plus or similar package
  Future<bool> _isOnline() async {
    // TODO: Implement actual connectivity check using connectivity_plus
    return true; // Placeholder
  }
}
