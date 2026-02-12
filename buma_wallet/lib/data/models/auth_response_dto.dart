import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_response_dto.freezed.dart';

/// DTO for authentication response containing JWT tokens
@freezed
class AuthResponseDto with _$AuthResponseDto {
  const AuthResponseDto._();

  const factory AuthResponseDto({
    required String accessToken,
    String? refreshToken,
    required int expiresIn, // seconds
  }) = _AuthResponseDto;

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthResponseDto(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String?,
      expiresIn: json['expiresIn'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'expiresIn': expiresIn,
      };
}

/// DTO for user profile response
@freezed
class UserResponseDto with _$UserResponseDto {
  const UserResponseDto._();

  const factory UserResponseDto({
    required String id,
    required String email,
    required String name,
  }) = _UserResponseDto;

  factory UserResponseDto.fromJson(Map<String, dynamic> json) {
    return UserResponseDto(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['firstName'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'firstName': name,
      };
}
