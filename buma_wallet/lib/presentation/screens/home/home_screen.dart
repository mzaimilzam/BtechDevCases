import 'package:buma_wallet/presentation/bloc/auth/auth_bloc.dart';
import 'package:buma_wallet/presentation/bloc/wallet/wallet_bloc.dart';
import 'package:buma_wallet/presentation/screens/home/history_tab_screen.dart';
import 'package:buma_wallet/presentation/screens/home/transfer_tab_screen.dart';
import 'package:buma_wallet/presentation/screens/home/wallet_tab_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WalletBloc(),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/login',
              (route) => false,
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('BUMA Wallet'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  context.read<AuthBloc>().add(const LogoutRequested());
                },
              ),
            ],
          ),
          body: _buildBody(),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.account_balance_wallet),
                label: 'Wallet',
              ),
              BottomNavigationBarItem(
                  icon: Icon(Icons.history), label: 'History'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.send), label: 'Transfer'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const WalletTabScreen();
      case 1:
        return const HistoryTabScreen();
      case 2:
        return const TransferTabScreen();
      default:
        return const WalletTabScreen();
    }
  }
}
