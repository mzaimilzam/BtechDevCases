import 'package:fpdart/fpdart.dart';

import '../entities/transaction.dart';
import '../entities/wallet.dart';
import '../failures/failure.dart';

/// Abstract repository for wallet and transaction operations.
/// Implements offline-first pattern for poor connectivity scenarios.
abstract interface class WalletRepository {
  /// Get wallet balance for the authenticated user.
  ///
  /// Tries remote first, falls back to local cache if offline.
  /// Updates local cache on successful remote fetch.
  ///
  /// Returns: Either<Failure, Wallet> with balance or failure
  Future<Either<Failure, Wallet>> getWalletBalance();

  /// Transfer funds to another user (offline-first pattern).
  ///
  /// If online:
  ///   - Calls API immediately
  ///   - Updates local DB on success
  ///   - Returns Success status
  ///
  /// If offline:
  ///   - Saves to TransactionQueueTable with pendingSync status
  ///   - Returns OfflineSuccess (UI knows it's queued)
  ///
  /// Parameters:
  ///   - recipientEmail: Recipient's email address
  ///   - amount: Amount to transfer
  ///   - note: Optional transfer notes
  ///
  /// Returns: Either<Failure, Transaction> with transaction details or failure
  Future<Either<Failure, Transaction>> transferFund({
    required String recipientEmail,
    required double amount,
    required String note,
  });

  /// Get transaction history for the authenticated user.
  ///
  /// Includes both synced and pending transactions.
  /// Pending transactions are those queued during offline periods.
  ///
  /// Returns: Either<Failure, List<Transaction>> with history or failure
  Future<Either<Failure, List<Transaction>>> getTransactionHistory();

  /// Sync pending transactions with the server.
  ///
  /// Called when connectivity is restored.
  /// Attempts to sync all pendingSync transactions.
  /// Updates local DB with results.
  ///
  /// Returns: Either<Failure, int> with number of synced transactions
  Future<Either<Failure, int>> syncPendingTransactions();
}
