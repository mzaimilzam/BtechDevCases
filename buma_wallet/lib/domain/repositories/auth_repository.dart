import 'package:fpdart/fpdart.dart';

import '../entities/user.dart';
import '../failures/failure.dart';

/// Abstract repository for authentication operations.
/// Defines contracts for login, registration, and token management.
abstract interface class AuthRepository {
  /// Register a new user account.
  ///
  /// Parameters:
  ///   - email: User's email address
  ///   - password: User's password
  ///   - confirmPassword: Password confirmation
  ///
  /// Returns: Either<Failure, Unit> indicating success or failure
  Future<Either<Failure, Unit>> register({
    required String email,
    required String password,
    required String confirmPassword,
  });

  /// Login user with email and password.
  ///
  /// Stores JWT token securely upon success.
  /// Returns the authenticated user.
  ///
  /// Returns: Either<Failure, User> with authenticated user or failure
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  /// Logout the current user.
  /// Clears stored tokens and authentication state.
  ///
  /// Returns: Either<Failure, Unit> indicating success or failure
  Future<Either<Failure, Unit>> logout();

  /// Get the currently authenticated user.
  ///
  /// Checks local storage first (offline support).
  /// If local data is stale, tries to fetch from server.
  ///
  /// Returns: Either<Failure, User?> with user or null if not authenticated
  Future<Either<Failure, User?>> getCurrentUser();

  /// Verify if user has a valid authentication token.
  ///
  /// Returns: true if user is authenticated, false otherwise
  Future<bool> isAuthenticated();

  /// Refresh the access token using the refresh token.
  ///
  /// Called when access token expires to obtain a new one.
  /// Returns: Either<Failure, Unit> indicating success or failure
  Future<Either<Failure, Unit>> refreshToken();
}
