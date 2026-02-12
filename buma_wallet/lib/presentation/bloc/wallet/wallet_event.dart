part of 'wallet_bloc.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class TransferRequested extends WalletEvent {
  final String recipientEmail;
  final double amount;
  final String note;

  const TransferRequested({
    required this.recipientEmail,
    required this.amount,
    required this.note,
  });

  @override
  List<Object?> get props => [recipientEmail, amount, note];
}

class GetBalanceRequested extends WalletEvent {
  const GetBalanceRequested();
}

class GetTransactionsRequested extends WalletEvent {
  const GetTransactionsRequested();
}
class SyncTransactionRequested extends WalletEvent {
  final String transactionId;

  const SyncTransactionRequested({required this.transactionId});

  @override
  List<Object?> get props => [transactionId];
}

class CancelTransactionRequested extends WalletEvent {
  final String transactionId;

  const CancelTransactionRequested({required this.transactionId});

  @override
  List<Object?> get props => [transactionId];
}