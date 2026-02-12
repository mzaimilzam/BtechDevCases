import 'package:buma_wallet/presentation/bloc/wallet/wallet_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransferTabScreen extends StatefulWidget {
  const TransferTabScreen({super.key});

  @override
  State<TransferTabScreen> createState() => _TransferTabScreenState();
}

class _TransferTabScreenState extends State<TransferTabScreen> {
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _handleTransfer() {
    // Validate inputs
    if (_recipientController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipient email is required')),
      );
      return;
    }

    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Amount is required')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a valid amount greater than 0')),
      );
      return;
    }

    context.read<WalletBloc>().add(
          TransferRequested(
            recipientEmail: _recipientController.text.trim(),
            amount: amount,
            note: _noteController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: BlocListener<WalletBloc, WalletState>(
        listener: (context, state) {
          if (state is TransferSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Transfer sent successfully to ${_recipientController.text.trim()}',
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
            // Clear form
            _recipientController.clear();
            _amountController.clear();
            _noteController.clear();
          } else if (state is TransferFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          } else if (state is WalletError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
        child: BlocBuilder<WalletBloc, WalletState>(
          builder: (context, state) {
            final isLoading = state is WalletLoading;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Send Money',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _recipientController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Recipient Email',
                    prefixIcon: Icon(Icons.email),
                    hintText: 'Enter recipient email',
                  ),
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixIcon: Icon(Icons.attach_money),
                    hintText: 'Enter amount',
                  ),
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Note (Optional)',
                    prefixIcon: Icon(Icons.note),
                    hintText: 'Add a note for the transfer',
                    alignLabelWithHint: true,
                  ),
                  enabled: !isLoading,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: isLoading ? null : _handleTransfer,
                  icon: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.send),
                  label: Text(isLoading ? 'Sending...' : 'Send'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
