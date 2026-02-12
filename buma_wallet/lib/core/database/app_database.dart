import 'package:drift/drift.dart';

import 'app_database_schema.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  UserCacheTable,
  WalletCacheTable,
  TransactionQueueTable,
  TransactionHistoryTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  // ============ USER CACHE OPERATIONS ============

  /// Cache user profile information
  Future<void> cacheUser(UserCacheData user) async {
    await into(userCacheTable).insertOnConflictUpdate(user);
  }

  /// Retrieve cached user by ID
  Future<UserCacheData?> getUserById(String userId) {
    return (select(userCacheTable)..where((tbl) => tbl.id.equals(userId)))
        .getSingleOrNull();
  }

  /// Clear user cache
  Future<int> clearUserCache() {
    return delete(userCacheTable).go();
  }

  // ============ WALLET CACHE OPERATIONS ============

  /// Cache wallet balance
  Future<void> cacheWallet(WalletCacheData wallet) async {
    await into(walletCacheTable).insertOnConflictUpdate(wallet);
  }

  /// Retrieve cached wallet by user ID
  Future<WalletCacheData?> getWalletCacheByUserId(String userId) {
    return (select(walletCacheTable)..where((tbl) => tbl.userId.equals(userId)))
        .getSingleOrNull();
  }

  /// Clear wallet cache
  Future<int> clearWalletCache() {
    return delete(walletCacheTable).go();
  }

  // ============ TRANSACTION QUEUE OPERATIONS ============

  /// Add transaction to queue (for offline scenarios)
  Future<void> queueTransaction(TransactionQueueData transaction) async {
    await into(transactionQueueTable).insertOnConflictUpdate(transaction);
  }

  /// Get all pending transactions waiting to sync
  Future<List<TransactionQueueData>> getPendingSyncTransactions(
    String userId,
  ) {
    return (select(transactionQueueTable)
          ..where((tbl) =>
              tbl.userId.equals(userId) & tbl.status.equals('pending_sync')))
        .get();
  }

  /// Update transaction status
  Future<bool> updateTransactionStatus(
    String transactionId,
    String status, {
    String? errorMessage,
    DateTime? syncedAt,
  }) async {
    final rowsUpdated = await (update(transactionQueueTable)
          ..where((tbl) => tbl.id.equals(transactionId)))
        .write(
      TransactionQueueTableCompanion(
        status: Value(status),
        syncErrorMessage: Value(errorMessage),
        syncedAt: Value(syncedAt),
      ),
    );
    return rowsUpdated > 0;
  }

  /// Get transaction from queue by ID
  Future<TransactionQueueData?> getQueuedTransaction(String transactionId) {
    return (select(transactionQueueTable)
          ..where((tbl) => tbl.id.equals(transactionId)))
        .getSingleOrNull();
  }

  /// Clear transaction queue
  Future<int> clearTransactionQueue() {
    return delete(transactionQueueTable).go();
  }

  // ============ TRANSACTION HISTORY OPERATIONS ============

  /// Add completed transaction to history
  Future<void> addTransactionHistory(
    TransactionHistoryData transaction,
  ) async {
    await into(transactionHistoryTable).insertOnConflictUpdate(transaction);
  }

  /// Get transaction history for user
  Future<List<TransactionHistoryData>> getTransactionHistoryByUserId(
    String userId, {
    int? limit,
    int? offset,
  }) {
    var query = select(transactionHistoryTable)
      ..where((tbl) => tbl.userId.equals(userId))
      ..orderBy([
        (tbl) =>
            OrderingTerm(expression: tbl.timestamp, mode: OrderingMode.desc)
      ]);

    if (limit != null) query = query..limit(limit, offset: offset);

    return query.get();
  }

  /// Clear transaction history
  Future<int> clearTransactionHistory() {
    return delete(transactionHistoryTable).go();
  }

  /// Clear all data (logout)
  Future<void> clearAllData() async {
    await clearUserCache();
    await clearWalletCache();
    await clearTransactionQueue();
    await clearTransactionHistory();
  }
}
