import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_request_dto.freezed.dart';

/// DTO for login request payload
@freezed
class LoginRequestDto with _$LoginRequestDto {
  const LoginRequestDto._();

  const factory LoginRequestDto({
    required String email,
    required String password,
  }) = _LoginRequestDto;

  factory LoginRequestDto.fromJson(Map<String, dynamic> json) {
    return LoginRequestDto(
      email: json['email'] as String,
      password: json['password'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

/// DTO for registration request payload
@freezed
class RegisterRequestDto with _$RegisterRequestDto {
  const RegisterRequestDto._();

  const factory RegisterRequestDto({
    required String email,
    required String password,
    required String confirmPassword,
  }) = _RegisterRequestDto;

  factory RegisterRequestDto.fromJson(Map<String, dynamic> json) {
    return RegisterRequestDto(
      email: json['email'] as String,
      password: json['password'] as String,
      confirmPassword: json['confirm_password'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'confirm_password': confirmPassword,
      };
}
