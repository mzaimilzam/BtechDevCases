import 'package:buma_wallet/core/di/service_locator.dart';
import 'package:buma_wallet/domain/repositories/auth_repository.dart';
import 'package:buma_wallet/presentation/bloc/auth/auth_bloc.dart';
import 'package:buma_wallet/presentation/screens/auth/login/login_screen.dart';
import 'package:buma_wallet/presentation/screens/auth/register/register_screen.dart';
import 'package:buma_wallet/presentation/screens/home/home_screen.dart';
import 'package:buma_wallet/presentation/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await configureDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: MaterialApp(
        title: 'BUMA Wallet',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const AuthWrapper(),
        routes: {
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/home': (_) => const HomeScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late Future<bool> _authCheckFuture;

  @override
  void initState() {
    super.initState();
    // Check if user is already authenticated
    _authCheckFuture = _checkAuthentication();
  }

  Future<bool> _checkAuthentication() async {
    try {
      final authRepo = GetIt.I<AuthRepository>();
      return await authRepo.isAuthenticated();
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _authCheckFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isAuthenticated = snapshot.data ?? false;
        return isAuthenticated ? const HomeScreen() : const LoginScreen();
      },
    );
  }
}
