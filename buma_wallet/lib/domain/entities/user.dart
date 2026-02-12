import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

/// User entity representing a user in the system.
/// Domain model - immutable and logic-focused.
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String name,
  }) = _User;

  const User._();

  /// Validate email format
  bool get isValidEmail {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
  }
}
