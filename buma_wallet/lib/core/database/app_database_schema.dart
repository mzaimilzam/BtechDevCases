import 'package:drift/drift.dart';

/// Table for caching user profile information
@DataClassName('UserCacheData')
class UserCacheTable extends Table {
  TextColumn get id => text()();
  TextColumn get email => text()();
  TextColumn get name => text()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Table for storing wallet balance cache
@DataClassName('WalletCacheData')
class WalletCacheTable extends Table {
  TextColumn get userId => text()();
  RealColumn get balance => real()();
  TextColumn get currency => text()(); // 'IDR' or 'USD'
  DateTimeColumn get lastUpdated => dateTime()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {userId};
}

/// Table for storing all transactions (local queue + history)
/// Offline-first pattern: insert immediately with 'pending' status,
/// update status to 'success'/'failed'/'cancelled' after sync/action
@DataClassName('TransactionData')
class TransactionsTable extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get recipientEmail => text()();
  RealColumn get amount => real()();
  TextColumn get note => text()();
  // Status: 'pending', 'success', 'failed', 'cancelled'
  TextColumn get status => text()();
  DateTimeColumn get timestamp => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn? get syncedAt => dateTime().nullable()();
  TextColumn? get syncErrorMessage => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {userId, id}
      ];
}

/// Table for storing transactions pending synchronization
/// These are transactions that were created while offline
@DataClassName('TransactionQueueData')
class TransactionQueueTable extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get recipientEmail => text()();
  RealColumn get amount => real()();
  TextColumn get note => text()();
  TextColumn get status => text()(); // 'pending_sync', 'success', 'failed'
  DateTimeColumn get timestamp => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn? get syncedAt => dateTime().nullable()();
  TextColumn? get syncErrorMessage => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {userId, id}
      ];
}

/// Table for storing completed transactions (synced history)
@DataClassName('TransactionHistoryData')
class TransactionHistoryTable extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get recipientEmail => text()();
  RealColumn get amount => real()();
  TextColumn get note => text()();
  TextColumn get status => text()(); // 'success', 'failed'
  DateTimeColumn get timestamp => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {userId, id}
      ];
}
