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

  /// Insert new transaction locally (offline-first)
  Future<void> insertTransaction(Transaction transaction, String userId);

  /// Get all transactions for user (pending + completed)
  Future<List<Transaction>> getAllTransactions(String userId);

  /// Get pending transactions only
  Future<List<Transaction>> getPendingTransactions(String userId);

  /// Update transaction status (success, failed, cancelled, etc.)
  Future<void> updateTransactionStatus(
    String transactionId,
    String status, {
    String? errorMessage,
    DateTime? syncedAt,
  });

  /// Cancel a transaction
  Future<void> cancelTransaction(String transactionId);

  /// Get transaction history (alias for getAllTransactions)
  Future<List<Transaction>> getTransactionHistory(String userId);

  /// Clear wallet and transaction caches
  Future<void> clearWalletData();

  /// Queue a transaction for later synchronization (offline case) - LEGACY
  Future<void> queueTransaction(Transaction transaction, String userId);

  /// Get all pending transactions waiting to sync - LEGACY
  Future<List<Transaction>> getPendingSyncTransactions(String userId);
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
  Future<void> insertTransaction(Transaction transaction, String userId) async {
    await _database.insertTransaction(
      TransactionData(
        id: transaction.id,
        userId: userId,
        recipientEmail: transaction.recipientEmail,
        amount: transaction.amount,
        note: transaction.note,
        status: _statusToString(transaction.status),
        timestamp: transaction.timestamp,
        createdAt: DateTime.now(),
        syncedAt: null,
        syncErrorMessage: null,
      ),
    );
  }

  @override
  Future<List<Transaction>> getAllTransactions(String userId) async {
    final transactions = await _database.getAllTransactionsByUserId(userId);
    return transactions
        .map((data) => Transaction(
              id: data.id,
              recipientEmail: data.recipientEmail,
              amount: data.amount,
              note: data.note,
              status: _statusFromString(data.status),
              timestamp: data.timestamp,
              syncErrorMessage: data.syncErrorMessage,
            ))
        .toList();
  }

  @override
  Future<List<Transaction>> getPendingTransactions(String userId) async {
    final transactions = await _database.getPendingTransactionsByUserId(userId);
    return transactions
        .map((data) => Transaction(
              id: data.id,
              recipientEmail: data.recipientEmail,
              amount: data.amount,
              note: data.note,
              status: _statusFromString(data.status),
              timestamp: data.timestamp,
              syncErrorMessage: data.syncErrorMessage,
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
  Future<void> cancelTransaction(String transactionId) async {
    await _database.cancelTransaction(transactionId);
  }

  @override
  Future<List<Transaction>> getTransactionHistory(String userId) async {
    return getAllTransactions(userId);
  }

  @override
  Future<void> clearWalletData() async {
    await _database.clearWalletCache();
    await _database.clearAllTransactions();
    await _database.clearTransactionQueue();
    await _database.clearTransactionHistory();
  }

  // ============ LEGACY METHODS FOR BACKWARDS COMPATIBILITY ============

  @override
  Future<void> queueTransaction(Transaction transaction, String userId) async {
    // Use new unified method
    await insertTransaction(transaction, userId);
  }

  @override
  Future<List<Transaction>> getPendingSyncTransactions(String userId) async {
    // Use new unified method
    return getPendingTransactions(userId);
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

String _statusToString(TransactionStatus status) {
  return switch (status) {
    TransactionStatus.pending => 'pending',
    TransactionStatus.success => 'success',
    TransactionStatus.failed => 'failed',
    TransactionStatus.cancelled => 'cancelled',
  };
}

TransactionStatus _statusFromString(String value) {
  return switch (value.toLowerCase()) {
    'pending' => TransactionStatus.pending,
    'success' => TransactionStatus.success,
    'failed' => TransactionStatus.failed,
    'cancelled' => TransactionStatus.cancelled,
    _ => TransactionStatus.pending,
  };
}
