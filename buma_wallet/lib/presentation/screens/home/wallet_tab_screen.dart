import 'package:buma_wallet/core/di/service_locator.dart';
import 'package:buma_wallet/domain/repositories/auth_repository.dart';
import 'package:buma_wallet/presentation/bloc/wallet/wallet_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WalletTabScreen extends StatefulWidget {
  const WalletTabScreen({super.key});

  @override
  State<WalletTabScreen> createState() => _WalletTabScreenState();
}

class _WalletTabScreenState extends State<WalletTabScreen> {
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
    // Load balance on init
    context.read<WalletBloc>().add(const GetBalanceRequested());
  }

  Future<void> _loadUserEmail() async {
    try {
      final authRepo = getIt<AuthRepository>();
      final result = await authRepo.getCurrentUser();
      result.fold(
        (failure) {
          // Handle error silently
        },
        (user) {
          if (user != null && mounted) {
            setState(() {
              _userEmail = user.email;
            });
          }
        },
      );
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: BlocListener<WalletBloc, WalletState>(
        listener: (context, state) {
          if (state is WalletError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<WalletBloc, WalletState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Greeting section
                if (_userEmail.isNotEmpty) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello $_userEmail,',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Welcome back',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ],
                // Wallet balance card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          'Wallet Balance',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        if (state is WalletLoading)
                          const SizedBox(
                            height: 40,
                            child: CircularProgressIndicator(),
                          )
                        else if (state is WalletError)
                          Column(
                            children: [
                              Text(
                                'Error loading balance',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Colors.red,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                state.message,
                                style: Theme.of(context).textTheme.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )
                        else if (state is BalanceLoaded)
                          Column(
                            children: [
                              Text(
                                '\$${state.balance.toStringAsFixed(2)}',
                                style:
                                    Theme.of(context).textTheme.displayMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'USD',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          )
                        else
                          Text(
                            '\$0.00',
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: state is WalletLoading
                      ? null
                      : () {
                          context
                              .read<WalletBloc>()
                              .add(const GetBalanceRequested());
                        },
                  icon: state is WalletLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.refresh),
                  label: const Text('Refresh Balance'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
