import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../core/storage/secure_token_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/failures/failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local_auth_datasource.dart';
import '../datasources/remote_auth_datasource.dart';

/// Implementation of AuthRepository with offline-first pattern.
/// Orchestrates authentication flow between remote and local data sources.
@Injectable(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final RemoteAuthDataSource _remoteDataSource;
  final LocalAuthDataSource _localDataSource;
  final SecureTokenStorage _tokenStorage;

  AuthRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._tokenStorage,
  );

  @override
  Future<Either<Failure, Unit>> register({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      // Validation
      if (email.isEmpty || !email.contains('@')) {
        return const Left(ValidationFailure('Invalid email format'));
      }
      if (password.isEmpty || password.length < 6) {
        return const Left(
            ValidationFailure('Password must be at least 6 characters'));
      }
      if (password != confirmPassword) {
        return const Left(ValidationFailure('Passwords do not match'));
      }

      // Call remote register
      await _remoteDataSource.register(
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );

      return const Right(unit);
    } on NetworkFailure catch (e) {
      return Left(e);
    } on ServerFailure catch (e) {
      return Left(e);
    } on AuthFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Validation
      if (email.isEmpty || !email.contains('@')) {
        return const Left(ValidationFailure('Invalid email format'));
      }
      if (password.isEmpty) {
        return const Left(ValidationFailure('Password required'));
      }

      // Call remote login
      final (user, token) = await _remoteDataSource.login(
        email: email,
        password: password,
      );

      // Cache user locally
      await _localDataSource.cacheUser(user);

      // Save token to secure storage
      await _tokenStorage.saveAuthToken(token);

      // Save user ID to secure storage
      await _tokenStorage.saveCurrentUserId(user.id);

      return Right(user);
    } on NetworkFailure catch (e) {
      return Left(e);
    } on ServerFailure catch (e) {
      return Left(e);
    } on AuthFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      // Clear local cache
      await _localDataSource.clearUser();

      // Clear token
      await _tokenStorage.clearAuthToken();

      return const Right(unit);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      // Try remote first
      try {
        final user = await _remoteDataSource.getCurrentUser();
        // Cache locally if remote succeeds
        await _localDataSource.cacheUser(user);
        return Right(user);
      } on NetworkFailure {
        // If network fails, try local cache
        final cachedUser = await _localDataSource.getUserById('current_user');
        if (cachedUser != null) {
          return Right(cachedUser);
        }
        rethrow;
      }
    } on NetworkFailure catch (e) {
      return Left(e);
    } on ServerFailure catch (e) {
      return Left(e);
    } on AuthFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final token = await _tokenStorage.getAuthToken();
      return token != null && token.isValid;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Either<Failure, Unit>> refreshToken() async {
    try {
      final currentToken = await _tokenStorage.getAuthToken();
      if (currentToken?.refreshToken == null) {
        return const Left(AuthFailure('No refresh token available'));
      }

      final newToken = await _remoteDataSource.refreshToken(
        currentToken!.refreshToken!,
      );
      await _tokenStorage.saveAuthToken(newToken);
      return const Right(unit);
    } on NetworkFailure catch (e) {
      return Left(e);
    } on ServerFailure catch (e) {
      return Left(e);
    } on AuthFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
