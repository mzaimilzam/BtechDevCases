// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_request_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$LoginRequestDto {
  String get email => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $LoginRequestDtoCopyWith<LoginRequestDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LoginRequestDtoCopyWith<$Res> {
  factory $LoginRequestDtoCopyWith(
          LoginRequestDto value, $Res Function(LoginRequestDto) then) =
      _$LoginRequestDtoCopyWithImpl<$Res, LoginRequestDto>;
  @useResult
  $Res call({String email, String password});
}

/// @nodoc
class _$LoginRequestDtoCopyWithImpl<$Res, $Val extends LoginRequestDto>
    implements $LoginRequestDtoCopyWith<$Res> {
  _$LoginRequestDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? password = null,
  }) {
    return _then(_value.copyWith(
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LoginRequestDtoImplCopyWith<$Res>
    implements $LoginRequestDtoCopyWith<$Res> {
  factory _$$LoginRequestDtoImplCopyWith(_$LoginRequestDtoImpl value,
          $Res Function(_$LoginRequestDtoImpl) then) =
      __$$LoginRequestDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String email, String password});
}

/// @nodoc
class __$$LoginRequestDtoImplCopyWithImpl<$Res>
    extends _$LoginRequestDtoCopyWithImpl<$Res, _$LoginRequestDtoImpl>
    implements _$$LoginRequestDtoImplCopyWith<$Res> {
  __$$LoginRequestDtoImplCopyWithImpl(
      _$LoginRequestDtoImpl _value, $Res Function(_$LoginRequestDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? password = null,
  }) {
    return _then(_$LoginRequestDtoImpl(
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$LoginRequestDtoImpl extends _LoginRequestDto {
  const _$LoginRequestDtoImpl({required this.email, required this.password})
      : super._();

  @override
  final String email;
  @override
  final String password;

  @override
  String toString() {
    return 'LoginRequestDto(email: $email, password: $password)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LoginRequestDtoImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.password, password) ||
                other.password == password));
  }

  @override
  int get hashCode => Object.hash(runtimeType, email, password);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LoginRequestDtoImplCopyWith<_$LoginRequestDtoImpl> get copyWith =>
      __$$LoginRequestDtoImplCopyWithImpl<_$LoginRequestDtoImpl>(
          this, _$identity);
}

abstract class _LoginRequestDto extends LoginRequestDto {
  const factory _LoginRequestDto(
      {required final String email,
      required final String password}) = _$LoginRequestDtoImpl;
  const _LoginRequestDto._() : super._();

  @override
  String get email;
  @override
  String get password;
  @override
  @JsonKey(ignore: true)
  _$$LoginRequestDtoImplCopyWith<_$LoginRequestDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$RegisterRequestDto {
  String get email => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;
  String get confirmPassword => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $RegisterRequestDtoCopyWith<RegisterRequestDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RegisterRequestDtoCopyWith<$Res> {
  factory $RegisterRequestDtoCopyWith(
          RegisterRequestDto value, $Res Function(RegisterRequestDto) then) =
      _$RegisterRequestDtoCopyWithImpl<$Res, RegisterRequestDto>;
  @useResult
  $Res call({String email, String password, String confirmPassword});
}

/// @nodoc
class _$RegisterRequestDtoCopyWithImpl<$Res, $Val extends RegisterRequestDto>
    implements $RegisterRequestDtoCopyWith<$Res> {
  _$RegisterRequestDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? password = null,
    Object? confirmPassword = null,
  }) {
    return _then(_value.copyWith(
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      confirmPassword: null == confirmPassword
          ? _value.confirmPassword
          : confirmPassword // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RegisterRequestDtoImplCopyWith<$Res>
    implements $RegisterRequestDtoCopyWith<$Res> {
  factory _$$RegisterRequestDtoImplCopyWith(_$RegisterRequestDtoImpl value,
          $Res Function(_$RegisterRequestDtoImpl) then) =
      __$$RegisterRequestDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String email, String password, String confirmPassword});
}

/// @nodoc
class __$$RegisterRequestDtoImplCopyWithImpl<$Res>
    extends _$RegisterRequestDtoCopyWithImpl<$Res, _$RegisterRequestDtoImpl>
    implements _$$RegisterRequestDtoImplCopyWith<$Res> {
  __$$RegisterRequestDtoImplCopyWithImpl(_$RegisterRequestDtoImpl _value,
      $Res Function(_$RegisterRequestDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? password = null,
    Object? confirmPassword = null,
  }) {
    return _then(_$RegisterRequestDtoImpl(
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      confirmPassword: null == confirmPassword
          ? _value.confirmPassword
          : confirmPassword // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$RegisterRequestDtoImpl extends _RegisterRequestDto {
  const _$RegisterRequestDtoImpl(
      {required this.email,
      required this.password,
      required this.confirmPassword})
      : super._();

  @override
  final String email;
  @override
  final String password;
  @override
  final String confirmPassword;

  @override
  String toString() {
    return 'RegisterRequestDto(email: $email, password: $password, confirmPassword: $confirmPassword)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RegisterRequestDtoImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.confirmPassword, confirmPassword) ||
                other.confirmPassword == confirmPassword));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, email, password, confirmPassword);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RegisterRequestDtoImplCopyWith<_$RegisterRequestDtoImpl> get copyWith =>
      __$$RegisterRequestDtoImplCopyWithImpl<_$RegisterRequestDtoImpl>(
          this, _$identity);
}

abstract class _RegisterRequestDto extends RegisterRequestDto {
  const factory _RegisterRequestDto(
      {required final String email,
      required final String password,
      required final String confirmPassword}) = _$RegisterRequestDtoImpl;
  const _RegisterRequestDto._() : super._();

  @override
  String get email;
  @override
  String get password;
  @override
  String get confirmPassword;
  @override
  @JsonKey(ignore: true)
  _$$RegisterRequestDtoImplCopyWith<_$RegisterRequestDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
