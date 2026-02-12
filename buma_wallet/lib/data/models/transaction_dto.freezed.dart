// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$TransferRequestDto {
  String get recipientEmail => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get note => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $TransferRequestDtoCopyWith<TransferRequestDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransferRequestDtoCopyWith<$Res> {
  factory $TransferRequestDtoCopyWith(
          TransferRequestDto value, $Res Function(TransferRequestDto) then) =
      _$TransferRequestDtoCopyWithImpl<$Res, TransferRequestDto>;
  @useResult
  $Res call({String recipientEmail, double amount, String note});
}

/// @nodoc
class _$TransferRequestDtoCopyWithImpl<$Res, $Val extends TransferRequestDto>
    implements $TransferRequestDtoCopyWith<$Res> {
  _$TransferRequestDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recipientEmail = null,
    Object? amount = null,
    Object? note = null,
  }) {
    return _then(_value.copyWith(
      recipientEmail: null == recipientEmail
          ? _value.recipientEmail
          : recipientEmail // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      note: null == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TransferRequestDtoImplCopyWith<$Res>
    implements $TransferRequestDtoCopyWith<$Res> {
  factory _$$TransferRequestDtoImplCopyWith(_$TransferRequestDtoImpl value,
          $Res Function(_$TransferRequestDtoImpl) then) =
      __$$TransferRequestDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String recipientEmail, double amount, String note});
}

/// @nodoc
class __$$TransferRequestDtoImplCopyWithImpl<$Res>
    extends _$TransferRequestDtoCopyWithImpl<$Res, _$TransferRequestDtoImpl>
    implements _$$TransferRequestDtoImplCopyWith<$Res> {
  __$$TransferRequestDtoImplCopyWithImpl(_$TransferRequestDtoImpl _value,
      $Res Function(_$TransferRequestDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? recipientEmail = null,
    Object? amount = null,
    Object? note = null,
  }) {
    return _then(_$TransferRequestDtoImpl(
      recipientEmail: null == recipientEmail
          ? _value.recipientEmail
          : recipientEmail // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      note: null == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$TransferRequestDtoImpl extends _TransferRequestDto {
  const _$TransferRequestDtoImpl(
      {required this.recipientEmail, required this.amount, required this.note})
      : super._();

  @override
  final String recipientEmail;
  @override
  final double amount;
  @override
  final String note;

  @override
  String toString() {
    return 'TransferRequestDto(recipientEmail: $recipientEmail, amount: $amount, note: $note)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransferRequestDtoImpl &&
            (identical(other.recipientEmail, recipientEmail) ||
                other.recipientEmail == recipientEmail) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.note, note) || other.note == note));
  }

  @override
  int get hashCode => Object.hash(runtimeType, recipientEmail, amount, note);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TransferRequestDtoImplCopyWith<_$TransferRequestDtoImpl> get copyWith =>
      __$$TransferRequestDtoImplCopyWithImpl<_$TransferRequestDtoImpl>(
          this, _$identity);
}

abstract class _TransferRequestDto extends TransferRequestDto {
  const factory _TransferRequestDto(
      {required final String recipientEmail,
      required final double amount,
      required final String note}) = _$TransferRequestDtoImpl;
  const _TransferRequestDto._() : super._();

  @override
  String get recipientEmail;
  @override
  double get amount;
  @override
  String get note;
  @override
  @JsonKey(ignore: true)
  _$$TransferRequestDtoImplCopyWith<_$TransferRequestDtoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$TransactionResponseDto {
  String get id => throw _privateConstructorUsedError;
  String get recipientEmail => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  String get note => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String get timestamp => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $TransactionResponseDtoCopyWith<TransactionResponseDto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransactionResponseDtoCopyWith<$Res> {
  factory $TransactionResponseDtoCopyWith(TransactionResponseDto value,
          $Res Function(TransactionResponseDto) then) =
      _$TransactionResponseDtoCopyWithImpl<$Res, TransactionResponseDto>;
  @useResult
  $Res call(
      {String id,
      String recipientEmail,
      double amount,
      String note,
      String status,
      String timestamp});
}

/// @nodoc
class _$TransactionResponseDtoCopyWithImpl<$Res,
        $Val extends TransactionResponseDto>
    implements $TransactionResponseDtoCopyWith<$Res> {
  _$TransactionResponseDtoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? recipientEmail = null,
    Object? amount = null,
    Object? note = null,
    Object? status = null,
    Object? timestamp = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      recipientEmail: null == recipientEmail
          ? _value.recipientEmail
          : recipientEmail // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      note: null == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TransactionResponseDtoImplCopyWith<$Res>
    implements $TransactionResponseDtoCopyWith<$Res> {
  factory _$$TransactionResponseDtoImplCopyWith(
          _$TransactionResponseDtoImpl value,
          $Res Function(_$TransactionResponseDtoImpl) then) =
      __$$TransactionResponseDtoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String recipientEmail,
      double amount,
      String note,
      String status,
      String timestamp});
}

/// @nodoc
class __$$TransactionResponseDtoImplCopyWithImpl<$Res>
    extends _$TransactionResponseDtoCopyWithImpl<$Res,
        _$TransactionResponseDtoImpl>
    implements _$$TransactionResponseDtoImplCopyWith<$Res> {
  __$$TransactionResponseDtoImplCopyWithImpl(
      _$TransactionResponseDtoImpl _value,
      $Res Function(_$TransactionResponseDtoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? recipientEmail = null,
    Object? amount = null,
    Object? note = null,
    Object? status = null,
    Object? timestamp = null,
  }) {
    return _then(_$TransactionResponseDtoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      recipientEmail: null == recipientEmail
          ? _value.recipientEmail
          : recipientEmail // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      note: null == note
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$TransactionResponseDtoImpl extends _TransactionResponseDto {
  const _$TransactionResponseDtoImpl(
      {required this.id,
      required this.recipientEmail,
      required this.amount,
      required this.note,
      required this.status,
      required this.timestamp})
      : super._();

  @override
  final String id;
  @override
  final String recipientEmail;
  @override
  final double amount;
  @override
  final String note;
  @override
  final String status;
  @override
  final String timestamp;

  @override
  String toString() {
    return 'TransactionResponseDto(id: $id, recipientEmail: $recipientEmail, amount: $amount, note: $note, status: $status, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransactionResponseDtoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.recipientEmail, recipientEmail) ||
                other.recipientEmail == recipientEmail) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, id, recipientEmail, amount, note, status, timestamp);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TransactionResponseDtoImplCopyWith<_$TransactionResponseDtoImpl>
      get copyWith => __$$TransactionResponseDtoImplCopyWithImpl<
          _$TransactionResponseDtoImpl>(this, _$identity);
}

abstract class _TransactionResponseDto extends TransactionResponseDto {
  const factory _TransactionResponseDto(
      {required final String id,
      required final String recipientEmail,
      required final double amount,
      required final String note,
      required final String status,
      required final String timestamp}) = _$TransactionResponseDtoImpl;
  const _TransactionResponseDto._() : super._();

  @override
  String get id;
  @override
  String get recipientEmail;
  @override
  double get amount;
  @override
  String get note;
  @override
  String get status;
  @override
  String get timestamp;
  @override
  @JsonKey(ignore: true)
  _$$TransactionResponseDtoImplCopyWith<_$TransactionResponseDtoImpl>
      get copyWith => throw _privateConstructorUsedError;
}
