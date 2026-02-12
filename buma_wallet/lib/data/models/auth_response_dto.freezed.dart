// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AuthResponseDto {
  String get accessToken => throw _privateConstructorUsedError;
  String? get refreshToken => throw _privateConstructorUsedError;
  int get expiresIn => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $AuthResponseDtoCopyWith<AuthResponseDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthResponseDtoCopyWith<$Res> {
  factory $AuthResponseDtoCopyWith(
          AuthResponseDto value, $Res Function(AuthResponseDto) then) =
      _$AuthResponseDtoCopyWithImpl<$Res, AuthResponseDto>;
  @useResult
  $Res call({String accessToken, String? refreshToken, int expiresIn});
}

/// @nodoc
class _$AuthResponseDtoCopyWithImpl<$Res, $Val extends AuthResponseDto>
    implements $AuthResponseDtoCopyWith<$Res> {
  _$AuthResponseDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? refreshToken = freezed,
    Object? expiresIn = null,
  }) {
    return _then(_value.copyWith(
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      refreshToken: freezed == refreshToken
          ? _value.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
              as String?,
      expiresIn: null == expiresIn
          ? _value.expiresIn
          : expiresIn // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AuthResponseDtoImplCopyWith<$Res>
    implements $AuthResponseDtoCopyWith<$Res> {
  factory _$$AuthResponseDtoImplCopyWith(_$AuthResponseDtoImpl value,
          $Res Function(_$AuthResponseDtoImpl) then) =
      __$$AuthResponseDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String accessToken, String? refreshToken, int expiresIn});
}

/// @nodoc
class __$$AuthResponseDtoImplCopyWithImpl<$Res>
    extends _$AuthResponseDtoCopyWithImpl<$Res, _$AuthResponseDtoImpl>
    implements _$$AuthResponseDtoImplCopyWith<$Res> {
  __$$AuthResponseDtoImplCopyWithImpl(
      _$AuthResponseDtoImpl _value, $Res Function(_$AuthResponseDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? refreshToken = freezed,
    Object? expiresIn = null,
  }) {
    return _then(_$AuthResponseDtoImpl(
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      refreshToken: freezed == refreshToken
          ? _value.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
              as String?,
      expiresIn: null == expiresIn
          ? _value.expiresIn
          : expiresIn // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$AuthResponseDtoImpl extends _AuthResponseDto {
  const _$AuthResponseDtoImpl(
      {required this.accessToken, this.refreshToken, required this.expiresIn})
      : super._();

  @override
  final String accessToken;
  @override
  final String? refreshToken;
  @override
  final int expiresIn;

  @override
  String toString() {
    return 'AuthResponseDto(accessToken: $accessToken, refreshToken: $refreshToken, expiresIn: $expiresIn)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthResponseDtoImpl &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.refreshToken, refreshToken) ||
                other.refreshToken == refreshToken) &&
            (identical(other.expiresIn, expiresIn) ||
                other.expiresIn == expiresIn));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, accessToken, refreshToken, expiresIn);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthResponseDtoImplCopyWith<_$AuthResponseDtoImpl> get copyWith =>
      __$$AuthResponseDtoImplCopyWithImpl<_$AuthResponseDtoImpl>(
          this, _$identity);
}

abstract class _AuthResponseDto extends AuthResponseDto {
  const factory _AuthResponseDto(
      {required final String accessToken,
      final String? refreshToken,
      required final int expiresIn}) = _$AuthResponseDtoImpl;
  const _AuthResponseDto._() : super._();

  @override
  String get accessToken;
  @override
  String? get refreshToken;
  @override
  int get expiresIn;
  @override
  @JsonKey(ignore: true)
  _$$AuthResponseDtoImplCopyWith<_$AuthResponseDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$UserResponseDto {
  String get id => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $UserResponseDtoCopyWith<UserResponseDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserResponseDtoCopyWith<$Res> {
  factory $UserResponseDtoCopyWith(
          UserResponseDto value, $Res Function(UserResponseDto) then) =
      _$UserResponseDtoCopyWithImpl<$Res, UserResponseDto>;
  @useResult
  $Res call({String id, String email, String name});
}

/// @nodoc
class _$UserResponseDtoCopyWithImpl<$Res, $Val extends UserResponseDto>
    implements $UserResponseDtoCopyWith<$Res> {
  _$UserResponseDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? name = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserResponseDtoImplCopyWith<$Res>
    implements $UserResponseDtoCopyWith<$Res> {
  factory _$$UserResponseDtoImplCopyWith(_$UserResponseDtoImpl value,
          $Res Function(_$UserResponseDtoImpl) then) =
      __$$UserResponseDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String email, String name});
}

/// @nodoc
class __$$UserResponseDtoImplCopyWithImpl<$Res>
    extends _$UserResponseDtoCopyWithImpl<$Res, _$UserResponseDtoImpl>
    implements _$$UserResponseDtoImplCopyWith<$Res> {
  __$$UserResponseDtoImplCopyWithImpl(
      _$UserResponseDtoImpl _value, $Res Function(_$UserResponseDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? name = null,
  }) {
    return _then(_$UserResponseDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$UserResponseDtoImpl extends _UserResponseDto {
  const _$UserResponseDtoImpl(
      {required this.id, required this.email, required this.name})
      : super._();

  @override
  final String id;
  @override
  final String email;
  @override
  final String name;

  @override
  String toString() {
    return 'UserResponseDto(id: $id, email: $email, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserResponseDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.name, name) || other.name == name));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, email, name);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserResponseDtoImplCopyWith<_$UserResponseDtoImpl> get copyWith =>
      __$$UserResponseDtoImplCopyWithImpl<_$UserResponseDtoImpl>(
          this, _$identity);
}

abstract class _UserResponseDto extends UserResponseDto {
  const factory _UserResponseDto(
      {required final String id,
      required final String email,
      required final String name}) = _$UserResponseDtoImpl;
  const _UserResponseDto._() : super._();

  @override
  String get id;
  @override
  String get email;
  @override
  String get name;
  @override
  @JsonKey(ignore: true)
  _$$UserResponseDtoImplCopyWith<_$UserResponseDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
