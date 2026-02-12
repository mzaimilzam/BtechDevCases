import 'package:bloc/bloc.dart';
import 'package:buma_wallet/core/di/service_locator.dart';
import 'package:buma_wallet/domain/entities/transaction.dart';
import 'package:buma_wallet/domain/repositories/wallet_repository.dart';
import 'package:equatable/equatable.dart';

part 'wallet_event.dart';
part 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository _walletRepository;

  WalletBloc({WalletRepository? walletRepository})
      : _walletRepository = walletRepository ?? getIt<WalletRepository>(),
        super(const WalletInitial()) {
    on<TransferRequested>(_onTransferRequested);
    on<GetBalanceRequested>(_onGetBalanceRequested);
    on<GetTransactionsRequested>(_onGetTransactionsRequested);
  }

  Future<void> _onTransferRequested(
    TransferRequested event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading());

    final result = await _walletRepository.transferFund(
      recipientEmail: event.recipientEmail,
      amount: event.amount,
      note: event.note,
    );

    result.fold(
      (failure) => emit(TransferFailure(failure.message)),
      (transaction) => emit(TransferSuccess(transaction)),
    );
  }

  Future<void> _onGetBalanceRequested(
    GetBalanceRequested event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading());

    final result = await _walletRepository.getWalletBalance();

    result.fold(
      (failure) => emit(WalletError(failure.message)),
      (wallet) => emit(BalanceLoaded(wallet.balance)),
    );
  }

  Future<void> _onGetTransactionsRequested(
    GetTransactionsRequested event,
    Emitter<WalletState> emit,
  ) async {
    emit(const WalletLoading());

    final result = await _walletRepository.getTransactionHistory();

    result.fold(
      (failure) => emit(WalletError(failure.message)),
      (transactions) => emit(TransactionsLoaded(transactions)),
    );
  }
}
