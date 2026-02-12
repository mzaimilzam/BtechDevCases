import '../../domain/entities/auth_token.dart';
import '../../domain/entities/user.dart';
import '../models/auth_response_dto.dart';

/// Extension for mapping AuthResponseDto to AuthToken domain entity
extension AuthResponseDtoX on AuthResponseDto {
  /// Convert AuthResponseDto to AuthToken domain entity
  AuthToken toDomain() {
    return AuthToken(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiry: DateTime.now().add(Duration(seconds: expiresIn)),
    );
  }
}

/// Extension for mapping UserResponseDto to User domain entity
extension UserResponseDtoX on UserResponseDto {
  /// Convert UserResponseDto to User domain entity
  User toDomain() {
    return User(
      id: id,
      email: email,
      name: name,
    );
  }
}

/// Extension for mapping User domain entity to Map (for storage/API)
extension UserX on User {
  /// Convert User to a JSON-serializable map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
    };
  }
}
