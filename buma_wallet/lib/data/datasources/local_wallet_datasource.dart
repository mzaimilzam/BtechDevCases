import 'package:injectable/injectable.dart';

import '../../core/database/app_database.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/wallet.dart';

/// Local data source for wallet-related cached data.
/// Implements offline-first pattern with transaction queuing.
abstract interface class LocalWalletDataSource {
  /// Cache wallet balance locally
  Future<void> cacheWallet(Wallet wallet, String userId);

  /// Retrieve cached wallet by user ID
  Future<Wallet?> getWalletCacheByUserId(String userId);

  /// Queue a transaction for later synchronization (offline case)
  Future<void> queueTransaction(Transaction transaction, String userId);

  /// Get all pending transactions waiting to sync
  Future<List<Transaction>> getPendingSyncTransactions(String userId);

  /// Update transaction status and sync details
  Future<void> updateTransactionStatus(
    String transactionId,
    String status, {
    String? errorMessage,
    DateTime? syncedAt,
  });

  /// Get transaction history (both pending and completed)
  Future<List<Transaction>> getTransactionHistory(String userId);

  /// Clear wallet and transaction caches
  Future<void> clearWalletData();
}

/// Implementation of LocalWalletDataSource using Drift
@Injectable(as: LocalWalletDataSource)
class LocalWalletDataSourceImpl implements LocalWalletDataSource {
  final AppDatabase _database;

  LocalWalletDataSourceImpl(this._database);

  @override
  Future<void> cacheWallet(Wallet wallet, String userId) async {
    await _database.cacheWallet(
      WalletCacheData(
        userId: userId,
        balance: wallet.balance,
        currency: _currencyToString(wallet.currency),
        lastUpdated: wallet.lastUpdated,
        cachedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<Wallet?> getWalletCacheByUserId(String userId) async {
    final cached = await _database.getWalletCacheByUserId(userId);
    if (cached != null) {
      return Wallet(
        balance: cached.balance,
        currency: _currencyFromString(cached.currency),
        lastUpdated: cached.lastUpdated,
      );
    }
    return null;
  }

  @override
  Future<void> queueTransaction(Transaction transaction, String userId) async {
    await _database.queueTransaction(
      TransactionQueueData(
        id: transaction.id,
        userId: userId,
        recipientEmail: transaction.recipientEmail,
        amount: transaction.amount,
        note: transaction.note,
        status: 'pending_sync',
        timestamp: transaction.timestamp,
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<List<Transaction>> getPendingSyncTransactions(String userId) async {
    final pendingTransactions =
        await _database.getPendingSyncTransactions(userId);
    return pendingTransactions
        .map((data) => Transaction(
              id: data.id,
              recipientEmail: data.recipientEmail,
              amount: data.amount,
              note: data.note,
              status: _statusFromString(data.status),
              timestamp: data.timestamp,
            ))
        .toList();
  }

  @override
  Future<void> updateTransactionStatus(
    String transactionId,
    String status, {
    String? errorMessage,
    DateTime? syncedAt,
  }) async {
    await _database.updateTransactionStatus(
      transactionId,
      status,
      errorMessage: errorMessage,
      syncedAt: syncedAt,
    );
  }

  @override
  Future<List<Transaction>> getTransactionHistory(String userId) async {
    // Get pending transactions
    final pendingData = await _database.getPendingSyncTransactions(userId);
    final pending = pendingData
        .map((data) => Transaction(
              id: data.id,
              recipientEmail: data.recipientEmail,
              amount: data.amount,
              note: data.note,
              status: _statusFromString(data.status),
              timestamp: data.timestamp,
            ))
        .toList();

    // Get completed transactions
    final completedData = await _database.getTransactionHistoryByUserId(userId);
    final completed = completedData
        .map((data) => Transaction(
              id: data.id,
              recipientEmail: data.recipientEmail,
              amount: data.amount,
              note: data.note,
              status: _statusFromString(data.status),
              timestamp: data.timestamp,
            ))
        .toList();

    // Combine and sort by timestamp
    final all = [...pending, ...completed];
    all.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return all;
  }

  @override
  Future<void> clearWalletData() async {
    await _database.clearWalletCache();
    await _database.clearTransactionQueue();
    await _database.clearTransactionHistory();
  }
}

// Helper functions
String _currencyToString(Currency currency) {
  return switch (currency) {
    Currency.idr => 'IDR',
    Currency.usd => 'USD',
  };
}

Currency _currencyFromString(String value) {
  return switch (value.toUpperCase()) {
    'IDR' => Currency.idr,
    'USD' => Currency.usd,
    _ => Currency.idr,
  };
}

TransactionStatus _statusFromString(String value) {
  return switch (value.toLowerCase()) {
    'pending' => TransactionStatus.pending,
    'success' => TransactionStatus.success,
    'failed' => TransactionStatus.failed,
    'pending_sync' => TransactionStatus.pendingSync,
    _ => TransactionStatus.failed,
  };
}
