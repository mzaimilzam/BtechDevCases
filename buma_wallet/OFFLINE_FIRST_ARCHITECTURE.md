# Offline-First Transaction Architecture

## Overview

This document describes the offline-first transaction architecture implemented in the Buma Wallet application. Transactions are now saved to the local database immediately with a "pending" status, allowing users to continue working even when offline. Syncing with the server can happen automatically or be triggered manually.

## Architecture Components

### 1. Transaction Statuses

Transactions now have 4 states:
- **pending**: Transaction created locally, waiting to be synced with server
- **success**: Transaction successfully processed by the server
- **failed**: Transaction failed during sync or server processing
- **cancelled**: User manually cancelled the transaction (preserved in history)

### 2. Data Flow

#### Creating a Transfer (Offline-First Pattern)

```
User creates transfer
    ↓
Save to local DB with "pending" status
    ↓
Display immediately in history
    ↓
Attempt API sync in background
    ├─ Success: Update status to "success"
    ├─ Failure: Preserve "pending" status + error message
    └─ Offline: Keep "pending" until connectivity restored
    ↓
User can manually sync or cancel
```

#### Manual Sync

```
User taps "Sync" button on pending transaction
    ↓
Try to send to server
    ├─ Success: Update status to "success"
    └─ Failure: Update status to "failed" + save error message
    ↓
Refresh transaction list in UI
```

#### Manual Cancel

```
User taps "Cancel" button on pending transaction
    ↓
Validate transaction is still "pending"
    ├─ Yes: Update status to "cancelled"
    └─ No: Show error
    ↓
Refresh transaction list in UI
```

### 3. Database Schema

#### TransactionsTable (Unified)

Consolidates transaction queue and history:

```dart
class TransactionsTable extends Table {
  TextColumn get id => text()();                    // Primary key
  TextColumn get userId => text()();                // Foreign key to user
  TextColumn get recipientEmail => text()();        // Recipient email
  RealColumn get amount => real()();                // Transfer amount
  TextColumn get note => text()();                  // Optional note
  TextColumn get status => text()();                // pending|success|failed|cancelled
  DateTimeColumn get timestamp => dateTime()();     // Transaction time
  DateTimeColumn get createdAt => dateTime()();     // Created timestamp
  DateTimeColumn? get syncedAt => dateTime().nullable()();      // When synced
  TextColumn? get syncErrorMessage => text().nullable()();      // Sync error if any
}
```

**Backward Compatibility**: Legacy `TransactionQueueTable` and `TransactionHistoryTable` remain for migration purposes but are not actively used.

### 4. Data Layer Implementation

#### LocalWalletDataSource

New methods for offline-first pattern:

```dart
// Insert transaction with pending status
Future<void> insertTransaction(Transaction transaction, String userId)

// Get all transactions for user
Future<List<Transaction>> getAllTransactions(String userId)

// Get only pending transactions
Future<List<Transaction>> getPendingTransactions(String userId)

// Update transaction status and sync results
Future<void> updateTransactionStatus(
  String transactionId,
  String newStatus,
  {DateTime? syncedAt, String? errorMessage}
)

// Cancel a pending transaction
Future<void> cancelTransaction(String transactionId)
```

#### RemoteWalletDataSource

The remote datasource should provide sync/cancel methods:

```dart
// Sync pending transaction with server
Future<Transaction> syncTransaction(String transactionId)

// Cancel pending transaction on server
Future<void> cancelTransaction(String transactionId)
```

**Backend API Requirements**:
- `PUT /api/wallet/transaction/:id/sync` - Sync pending transaction
- `POST /api/wallet/transaction/:id/cancel` - Cancel pending transaction

### 5. Repository Pattern

#### WalletRepository Interface

```dart
// Transfer with offline-first pattern
Future<Either<Failure, Transaction>> transferFund({
  required String recipientEmail,
  required double amount,
  required String note,
})

// Manual sync of specific transaction
Future<Either<Failure, Transaction>> syncTransaction(String transactionId)

// Cancel specific transaction
Future<Either<Failure, Transaction>> cancelTransaction(String transactionId)

// Get all transactions (pending + completed)
Future<Either<Failure, List<Transaction>>> getTransactionHistory()
```

#### Transfer Implementation Flow

```dart
Future<Either<Failure, Transaction>> transferFund(...) async {
  try {
    // 1. Create transaction with pending status
    final transaction = Transaction(
      id: generateId(),
      status: TransactionStatus.pending,
      timestamp: DateTime.now(),
      // ... other fields
    );

    // 2. Save to local DB immediately
    await _localDataSource.insertTransaction(transaction, userId);

    // 3. Try to sync with API
    try {
      final remoteTransaction = await _remoteDataSource.transferFund(...);
      
      // Update local status to success
      await _localDataSource.updateTransactionStatus(
        transaction.id,
        'success',
        syncedAt: DateTime.now(),
      );
      
      return Right(remoteTransaction);
    } catch (e) {
      // Save error but preserve local transaction
      await _localDataSource.updateTransactionStatus(
        transaction.id,
        'failed',
        errorMessage: e.toString(),
      );
      
      // Return local transaction with error info
      return Right(transaction);
    }
  } catch (e) {
    return Left(UnknownFailure(e.toString()));
  }
}
```

### 6. BLoC State Management

#### Events

```dart
// Transfer funds
TransferRequested({
  required String recipientEmail,
  required double amount,
  required String note,
})

// Sync specific pending transaction
SyncTransactionRequested({required String transactionId})

// Cancel specific pending transaction
CancelTransactionRequested({required String transactionId})

// Get all transactions
GetTransactionsRequested()
```

#### States

```dart
// After sync attempt
TransactionSyncSuccess(transaction)
TransactionSyncFailure(message)

// After cancel attempt
TransactionCancelSuccess(transaction)
TransactionCancelFailure(message)

// General states
WalletLoading()
TransactionsLoaded(transactions)
WalletError(message)
```

### 7. User Interface

#### HistoryTabScreen

Enhanced to show transaction actions:

1. **Status Badge**: Color-coded indicator
   - Orange: Pending (awaiting sync)
   - Green: Success (synced to server)
   - Red: Failed (sync failed)
   - Gray: Cancelled

2. **Action Buttons** (for pending transactions):
   - **Sync Button**: Retry sending to server
   - **Cancel Button**: Cancel transaction locally

3. **Error Display**: Shows error message if sync failed

```dart
if (transaction.status == TransactionStatus.pending) {
  // Show error message if exists
  if (transaction.syncErrorMessage != null) {
    Container(
      child: Text('Sync failed: ${transaction.syncErrorMessage}')
    );
  }
  
  // Show action buttons
  Row(
    children: [
      OutlinedButton.icon(
        onPressed: () => context.read<WalletBloc>().add(
          CancelTransactionRequested(transactionId: transaction.id),
        ),
        icon: Icon(Icons.close),
        label: Text('Cancel'),
      ),
      ElevatedButton.icon(
        onPressed: () => context.read<WalletBloc>().add(
          SyncTransactionRequested(transactionId: transaction.id),
        ),
        icon: Icon(Icons.sync),
        label: Text('Sync'),
      ),
    ],
  );
}
```

## Key Benefits

1. **Offline Support**: Users can create transactions without internet
2. **Immediate Feedback**: Transaction appears in history immediately
3. **Manual Control**: Users can retry sync or cancel anytime
4. **Error Visibility**: Failed syncs show specific error messages
5. **Data Preservation**: No data loss if API fails
6. **History Preservation**: Cancelled transactions remain in history

## Migration Considerations

### Existing Transactions

The system preserves backward compatibility:
- Old `TransactionQueueTable` and `TransactionHistoryTable` records are not automatically migrated
- New transactions use `TransactionsTable`
- Legacy tables can be cleaned up after data migration if needed

### Status Mapping

Old status enum (removed):
- `pending` → maps to new `pending`
- `success` → maps to new `success`
- `failed` → maps to new `failed`
- `pendingSync` → maps to new `pending` (old sync state)

## API Contract Changes

### New Endpoints Required

**Sync Transaction**
```
PUT /api/wallet/transaction/:id/sync
Request: {} (empty body, auth via header)
Response: { transaction: Transaction }
```

**Cancel Transaction**
```
POST /api/wallet/transaction/:id/cancel
Request: {} (empty body, auth via header)
Response: { transaction: Transaction }
```

### Server Logic

**Sync Endpoint**:
1. Validate transaction exists and belongs to user
2. Validate transaction status is 'pending'
3. Execute the transfer (call provider/payment gateway)
4. Update transaction status based on result
5. Return updated transaction

**Cancel Endpoint**:
1. Validate transaction exists and belongs to user
2. Validate transaction status is 'pending'
3. Update status to 'cancelled'
4. Return updated transaction

## Testing

### Unit Tests
- Transaction status transitions
- Local DB operations
- Status string conversion
- Error message persistence

### Integration Tests
- Full offline transfer flow
- Sync after connectivity restored
- Manual sync button interaction
- Cancel button interaction
- Error message display

### Manual Testing
1. Create transfer while offline
2. Verify appears in history with "Pending" status
3. Go online and verify sync
4. Create transfer, manually click "Sync" button
5. Create transfer, manually click "Cancel" button
6. Verify error messages display for failed syncs

## Future Enhancements

1. **Automatic Retry**: Implement exponential backoff for failed syncs
2. **Background Sync**: Sync all pending transactions when connectivity restored
3. **Notifications**: Notify user when pending transaction syncs
4. **Batch Operations**: Sync multiple pending transactions in one request
5. **Conflict Resolution**: Handle cases where server rejects pending transaction
6. **Queue Management**: Prioritize which pending transactions to sync first
