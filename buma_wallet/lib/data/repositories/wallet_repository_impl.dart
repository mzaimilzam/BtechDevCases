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

      // Check connectivity and act accordingly
      if (await _isOnline()) {
        // ONLINE: Try to execute immediately
        try {
          final remoteTransaction = await _remoteDataSource.transferFund(
            recipientEmail: recipientEmail,
            amount: amount,
            note: note,
          );

          // If successful, cache the completed transaction
          await _localDataSource.queueTransaction(
            remoteTransaction,
            userId,
          );

          return Right(remoteTransaction);
        } on Exception {
          // If remote fails but we're online, queue for retry
          final queuedTransaction = transaction.copyWith(
            status: TransactionStatus.pendingSync,
          );
          await _localDataSource.queueTransaction(queuedTransaction, userId);

          // Return pending status so UI knows it's queued
          return Right(queuedTransaction);
        }
      } else {
        // OFFLINE: Queue transaction for later sync
        final queuedTransaction = transaction.copyWith(
          status: TransactionStatus.pendingSync,
        );
        await _localDataSource.queueTransaction(queuedTransaction, userId);

        // Return pending status - UI knows transaction is queued
        return Right(queuedTransaction);
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
  Future<Either<Failure, int>> syncPendingTransactions() async {
    try {
      final userId = await _tokenStorage.getCurrentUserId();
      if (userId == null) {
        return const Left(AuthFailure('User not authenticated'));
      }

      // Get all pending transactions
      final pendingTransactions =
          await _localDataSource.getPendingSyncTransactions(userId);

      int syncedCount = 0;

      // Try to sync each pending transaction
      for (final transaction in pendingTransactions) {
        try {
          final remoteTransaction = await _remoteDataSource.transferFund(
            recipientEmail: transaction.recipientEmail,
            amount: transaction.amount,
            note: transaction.note,
          );

          // Update status to match remote result
          await _localDataSource.updateTransactionStatus(
            transaction.id,
            _statusToString(remoteTransaction.status),
            syncedAt: DateTime.now(),
          );

          syncedCount++;
        } catch (e) {
          // Update with error status
          await _localDataSource.updateTransactionStatus(
            transaction.id,
            'failed',
            errorMessage: e.toString(),
          );
        }
      }

      return Right(syncedCount);
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

  String _statusToString(TransactionStatus status) {
    return switch (status) {
      TransactionStatus.pending => 'pending',
      TransactionStatus.success => 'success',
      TransactionStatus.failed => 'failed',
      TransactionStatus.pendingSync => 'pending_sync',
    };
  }
}

/// Extension for convenient copyWith on Transaction
extension TransactionCopyWith on Transaction {
  Transaction copyWith({
    String? id,
    String? recipientEmail,
    double? amount,
    String? note,
    TransactionStatus? status,
    DateTime? timestamp,
  }) {
    return Transaction(
      id: id ?? this.id,
      recipientEmail: recipientEmail ?? this.recipientEmail,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
