// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wallet_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$WalletResponseDto {
  double get balance => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $WalletResponseDtoCopyWith<WalletResponseDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WalletResponseDtoCopyWith<$Res> {
  factory $WalletResponseDtoCopyWith(
          WalletResponseDto value, $Res Function(WalletResponseDto) then) =
      _$WalletResponseDtoCopyWithImpl<$Res, WalletResponseDto>;
  @useResult
  $Res call({double balance, String currency});
}

/// @nodoc
class _$WalletResponseDtoCopyWithImpl<$Res, $Val extends WalletResponseDto>
    implements $WalletResponseDtoCopyWith<$Res> {
  _$WalletResponseDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? balance = null,
    Object? currency = null,
  }) {
    return _then(_value.copyWith(
      balance: null == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WalletResponseDtoImplCopyWith<$Res>
    implements $WalletResponseDtoCopyWith<$Res> {
  factory _$$WalletResponseDtoImplCopyWith(_$WalletResponseDtoImpl value,
          $Res Function(_$WalletResponseDtoImpl) then) =
      __$$WalletResponseDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double balance, String currency});
}

/// @nodoc
class __$$WalletResponseDtoImplCopyWithImpl<$Res>
    extends _$WalletResponseDtoCopyWithImpl<$Res, _$WalletResponseDtoImpl>
    implements _$$WalletResponseDtoImplCopyWith<$Res> {
  __$$WalletResponseDtoImplCopyWithImpl(_$WalletResponseDtoImpl _value,
      $Res Function(_$WalletResponseDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? balance = null,
    Object? currency = null,
  }) {
    return _then(_$WalletResponseDtoImpl(
      balance: null == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as double,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$WalletResponseDtoImpl extends _WalletResponseDto {
  const _$WalletResponseDtoImpl({required this.balance, required this.currency})
      : super._();

  @override
  final double balance;
  @override
  final String currency;

  @override
  String toString() {
    return 'WalletResponseDto(balance: $balance, currency: $currency)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WalletResponseDtoImpl &&
            (identical(other.balance, balance) || other.balance == balance) &&
            (identical(other.currency, currency) ||
                other.currency == currency));
  }

  @override
  int get hashCode => Object.hash(runtimeType, balance, currency);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WalletResponseDtoImplCopyWith<_$WalletResponseDtoImpl> get copyWith =>
      __$$WalletResponseDtoImplCopyWithImpl<_$WalletResponseDtoImpl>(
          this, _$identity);
}

abstract class _WalletResponseDto extends WalletResponseDto {
  const factory _WalletResponseDto(
      {required final double balance,
      required final String currency}) = _$WalletResponseDtoImpl;
  const _WalletResponseDto._() : super._();

  @override
  double get balance;
  @override
  String get currency;
  @override
  @JsonKey(ignore: true)
  _$$WalletResponseDtoImplCopyWith<_$WalletResponseDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
