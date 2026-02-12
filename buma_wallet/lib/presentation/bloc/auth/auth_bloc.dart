import 'package:bloc/bloc.dart';
import 'package:buma_wallet/core/di/service_locator.dart';
import 'package:buma_wallet/domain/entities/user.dart';
import 'package:buma_wallet/domain/repositories/auth_repository.dart';
import 'package:equatable/equatable.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({AuthRepository? authRepository})
      : _authRepository = authRepository ?? getIt<AuthRepository>(),
        super(const AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onAuthCheckRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _authRepository.login(
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _authRepository.register(
      email: event.email,
      password: event.password,
      confirmPassword: event.confirmPassword,
    );

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) {
        // Registration successful, show success state
        // User will need to login with their credentials
        emit(const AuthSuccess(User(id: '', email: '', name: '')));
      },
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    emit(const AuthLoggedOut());
    emit(const AuthUnauthenticated());
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final isAuthenticated = await _authRepository.isAuthenticated();
    if (isAuthenticated) {
      final result = await _authRepository.getCurrentUser();
      result.fold(
        (failure) => emit(const AuthUnauthenticated()),
        (user) {
          if (user != null) {
            emit(AuthSuccess(user));
          } else {
            emit(const AuthUnauthenticated());
          }
        },
      );
    } else {
      emit(const AuthUnauthenticated());
    }
  }
}
