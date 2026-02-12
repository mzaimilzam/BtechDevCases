part of 'wallet_bloc.dart';

abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {
  const WalletInitial();
}

class WalletLoading extends WalletState {
  const WalletLoading();
}

class TransferSuccess extends WalletState {
  final Transaction transaction;

  const TransferSuccess(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class TransferFailure extends WalletState {
  final String message;

  const TransferFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class BalanceLoaded extends WalletState {
  final double balance;

  const BalanceLoaded(this.balance);

  @override
  List<Object?> get props => [balance];
}

class TransactionsLoaded extends WalletState {
  final List<Transaction> transactions;

  const TransactionsLoaded(this.transactions);

  @override
  List<Object?> get props => [transactions];
}

class WalletError extends WalletState {
  final String message;

  const WalletError(this.message);

  @override
  List<Object?> get props => [message];
}
