import 'package:freezed_annotation/freezed_annotation.dart';

part 'failure.freezed.dart';

/// Base failure union type for all errors in the application.
/// Uses sealed class pattern for exhaustive pattern matching.
@freezed
sealed class Failure with _$Failure {
  const Failure._();

  /// Network-related failures (no internet, timeout, etc.)
  const factory Failure.network(String message) = NetworkFailure;

  /// Server-side failures (4xx, 5xx errors)
  const factory Failure.server(String message, int? statusCode) = ServerFailure;

  /// Local database/cache failures
  const factory Failure.cache(String message) = CacheFailure;

  /// Authentication-related failures (invalid credentials, token expired)
  const factory Failure.auth(String message) = AuthFailure;

  /// Validation failures
  const factory Failure.validation(String message) = ValidationFailure;

  /// Unknown/unexpected failures
  const factory Failure.unknown(String message) = UnknownFailure;

  /// Get user-friendly error message
  @override
  String get message => when(
        network: (msg) => msg,
        server: (msg, _) => msg,
        cache: (msg) => msg,
        auth: (msg) => msg,
        validation: (msg) => msg,
        unknown: (msg) => msg,
      );

  /// Get detailed error information
  String get details => when(
        network: (msg) => 'Network Error: $msg',
        server: (msg, code) => 'Server Error (${code ?? 'Unknown'}): $msg',
        cache: (msg) => 'Cache Error: $msg',
        auth: (msg) => 'Authentication Error: $msg',
        validation: (msg) => 'Validation Error: $msg',
        unknown: (msg) => 'Unknown Error: $msg',
      );
}
