// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UserCacheTableTable extends UserCacheTable
    with TableInfo<$UserCacheTableTable, UserCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserCacheTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, email, name, cachedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_cache_table';
  @override
  VerificationContext validateIntegrity(Insertable<UserCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserCacheData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cached_at'])!,
    );
  }

  @override
  $UserCacheTableTable createAlias(String alias) {
    return $UserCacheTableTable(attachedDatabase, alias);
  }
}

class UserCacheData extends DataClass implements Insertable<UserCacheData> {
  final String id;
  final String email;
  final String name;
  final DateTime cachedAt;
  const UserCacheData(
      {required this.id,
      required this.email,
      required this.name,
      required this.cachedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['email'] = Variable<String>(email);
    map['name'] = Variable<String>(name);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  UserCacheTableCompanion toCompanion(bool nullToAbsent) {
    return UserCacheTableCompanion(
      id: Value(id),
      email: Value(email),
      name: Value(name),
      cachedAt: Value(cachedAt),
    );
  }

  factory UserCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserCacheData(
      id: serializer.fromJson<String>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      name: serializer.fromJson<String>(json['name']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'email': serializer.toJson<String>(email),
      'name': serializer.toJson<String>(name),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  UserCacheData copyWith(
          {String? id, String? email, String? name, DateTime? cachedAt}) =>
      UserCacheData(
        id: id ?? this.id,
        email: email ?? this.email,
        name: name ?? this.name,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  @override
  String toString() {
    return (StringBuffer('UserCacheData(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('name: $name, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, email, name, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserCacheData &&
          other.id == this.id &&
          other.email == this.email &&
          other.name == this.name &&
          other.cachedAt == this.cachedAt);
}

class UserCacheTableCompanion extends UpdateCompanion<UserCacheData> {
  final Value<String> id;
  final Value<String> email;
  final Value<String> name;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const UserCacheTableCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.name = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserCacheTableCompanion.insert({
    required String id,
    required String email,
    required String name,
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        email = Value(email),
        name = Value(name),
        cachedAt = Value(cachedAt);
  static Insertable<UserCacheData> custom({
    Expression<String>? id,
    Expression<String>? email,
    Expression<String>? name,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (name != null) 'name': name,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserCacheTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? email,
      Value<String>? name,
      Value<DateTime>? cachedAt,
      Value<int>? rowid}) {
    return UserCacheTableCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserCacheTableCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('name: $name, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WalletCacheTableTable extends WalletCacheTable
    with TableInfo<$WalletCacheTableTable, WalletCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WalletCacheTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _balanceMeta =
      const VerificationMeta('balance');
  @override
  late final GeneratedColumn<double> balance = GeneratedColumn<double>(
      'balance', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _currencyMeta =
      const VerificationMeta('currency');
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
      'currency', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastUpdatedMeta =
      const VerificationMeta('lastUpdated');
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
      'last_updated', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [userId, balance, currency, lastUpdated, cachedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wallet_cache_table';
  @override
  VerificationContext validateIntegrity(Insertable<WalletCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('balance')) {
      context.handle(_balanceMeta,
          balance.isAcceptableOrUnknown(data['balance']!, _balanceMeta));
    } else if (isInserting) {
      context.missing(_balanceMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(_currencyMeta,
          currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta));
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('last_updated')) {
      context.handle(
          _lastUpdatedMeta,
          lastUpdated.isAcceptableOrUnknown(
              data['last_updated']!, _lastUpdatedMeta));
    } else if (isInserting) {
      context.missing(_lastUpdatedMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userId};
  @override
  WalletCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WalletCacheData(
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      balance: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}balance'])!,
      currency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency'])!,
      lastUpdated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_updated'])!,
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cached_at'])!,
    );
  }

  @override
  $WalletCacheTableTable createAlias(String alias) {
    return $WalletCacheTableTable(attachedDatabase, alias);
  }
}

class WalletCacheData extends DataClass implements Insertable<WalletCacheData> {
  final String userId;
  final double balance;
  final String currency;
  final DateTime lastUpdated;
  final DateTime cachedAt;
  const WalletCacheData(
      {required this.userId,
      required this.balance,
      required this.currency,
      required this.lastUpdated,
      required this.cachedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['balance'] = Variable<double>(balance);
    map['currency'] = Variable<String>(currency);
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  WalletCacheTableCompanion toCompanion(bool nullToAbsent) {
    return WalletCacheTableCompanion(
      userId: Value(userId),
      balance: Value(balance),
      currency: Value(currency),
      lastUpdated: Value(lastUpdated),
      cachedAt: Value(cachedAt),
    );
  }

  factory WalletCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WalletCacheData(
      userId: serializer.fromJson<String>(json['userId']),
      balance: serializer.fromJson<double>(json['balance']),
      currency: serializer.fromJson<String>(json['currency']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'balance': serializer.toJson<double>(balance),
      'currency': serializer.toJson<String>(currency),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  WalletCacheData copyWith(
          {String? userId,
          double? balance,
          String? currency,
          DateTime? lastUpdated,
          DateTime? cachedAt}) =>
      WalletCacheData(
        userId: userId ?? this.userId,
        balance: balance ?? this.balance,
        currency: currency ?? this.currency,
        lastUpdated: lastUpdated ?? this.lastUpdated,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  @override
  String toString() {
    return (StringBuffer('WalletCacheData(')
          ..write('userId: $userId, ')
          ..write('balance: $balance, ')
          ..write('currency: $currency, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(userId, balance, currency, lastUpdated, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WalletCacheData &&
          other.userId == this.userId &&
          other.balance == this.balance &&
          other.currency == this.currency &&
          other.lastUpdated == this.lastUpdated &&
          other.cachedAt == this.cachedAt);
}

class WalletCacheTableCompanion extends UpdateCompanion<WalletCacheData> {
  final Value<String> userId;
  final Value<double> balance;
  final Value<String> currency;
  final Value<DateTime> lastUpdated;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const WalletCacheTableCompanion({
    this.userId = const Value.absent(),
    this.balance = const Value.absent(),
    this.currency = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WalletCacheTableCompanion.insert({
    required String userId,
    required double balance,
    required String currency,
    required DateTime lastUpdated,
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  })  : userId = Value(userId),
        balance = Value(balance),
        currency = Value(currency),
        lastUpdated = Value(lastUpdated),
        cachedAt = Value(cachedAt);
  static Insertable<WalletCacheData> custom({
    Expression<String>? userId,
    Expression<double>? balance,
    Expression<String>? currency,
    Expression<DateTime>? lastUpdated,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (balance != null) 'balance': balance,
      if (currency != null) 'currency': currency,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WalletCacheTableCompanion copyWith(
      {Value<String>? userId,
      Value<double>? balance,
      Value<String>? currency,
      Value<DateTime>? lastUpdated,
      Value<DateTime>? cachedAt,
      Value<int>? rowid}) {
    return WalletCacheTableCompanion(
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (balance.present) {
      map['balance'] = Variable<double>(balance.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WalletCacheTableCompanion(')
          ..write('userId: $userId, ')
          ..write('balance: $balance, ')
          ..write('currency: $currency, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionQueueTableTable extends TransactionQueueTable
    with TableInfo<$TransactionQueueTableTable, TransactionQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionQueueTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _recipientEmailMeta =
      const VerificationMeta('recipientEmail');
  @override
  late final GeneratedColumn<String> recipientEmail = GeneratedColumn<String>(
      'recipient_email', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncedAtMeta =
      const VerificationMeta('syncedAt');
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
      'synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncErrorMessageMeta =
      const VerificationMeta('syncErrorMessage');
  @override
  late final GeneratedColumn<String> syncErrorMessage = GeneratedColumn<String>(
      'sync_error_message', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        recipientEmail,
        amount,
        note,
        status,
        timestamp,
        createdAt,
        syncedAt,
        syncErrorMessage
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_queue_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<TransactionQueueData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('recipient_email')) {
      context.handle(
          _recipientEmailMeta,
          recipientEmail.isAcceptableOrUnknown(
              data['recipient_email']!, _recipientEmailMeta));
    } else if (isInserting) {
      context.missing(_recipientEmailMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('synced_at')) {
      context.handle(_syncedAtMeta,
          syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta));
    }
    if (data.containsKey('sync_error_message')) {
      context.handle(
          _syncErrorMessageMeta,
          syncErrorMessage.isAcceptableOrUnknown(
              data['sync_error_message']!, _syncErrorMessageMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {userId, id},
      ];
  @override
  TransactionQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionQueueData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      recipientEmail: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}recipient_email'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      syncedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}synced_at']),
      syncErrorMessage: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}sync_error_message']),
    );
  }

  @override
  $TransactionQueueTableTable createAlias(String alias) {
    return $TransactionQueueTableTable(attachedDatabase, alias);
  }
}

class TransactionQueueData extends DataClass
    implements Insertable<TransactionQueueData> {
  final String id;
  final String userId;
  final String recipientEmail;
  final double amount;
  final String note;
  final String status;
  final DateTime timestamp;
  final DateTime createdAt;
  final DateTime? syncedAt;
  final String? syncErrorMessage;
  const TransactionQueueData(
      {required this.id,
      required this.userId,
      required this.recipientEmail,
      required this.amount,
      required this.note,
      required this.status,
      required this.timestamp,
      required this.createdAt,
      this.syncedAt,
      this.syncErrorMessage});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['recipient_email'] = Variable<String>(recipientEmail);
    map['amount'] = Variable<double>(amount);
    map['note'] = Variable<String>(note);
    map['status'] = Variable<String>(status);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || syncedAt != null) {
      map['synced_at'] = Variable<DateTime>(syncedAt);
    }
    if (!nullToAbsent || syncErrorMessage != null) {
      map['sync_error_message'] = Variable<String>(syncErrorMessage);
    }
    return map;
  }

  TransactionQueueTableCompanion toCompanion(bool nullToAbsent) {
    return TransactionQueueTableCompanion(
      id: Value(id),
      userId: Value(userId),
      recipientEmail: Value(recipientEmail),
      amount: Value(amount),
      note: Value(note),
      status: Value(status),
      timestamp: Value(timestamp),
      createdAt: Value(createdAt),
      syncedAt: syncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(syncedAt),
      syncErrorMessage: syncErrorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(syncErrorMessage),
    );
  }

  factory TransactionQueueData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionQueueData(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      recipientEmail: serializer.fromJson<String>(json['recipientEmail']),
      amount: serializer.fromJson<double>(json['amount']),
      note: serializer.fromJson<String>(json['note']),
      status: serializer.fromJson<String>(json['status']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      syncedAt: serializer.fromJson<DateTime?>(json['syncedAt']),
      syncErrorMessage: serializer.fromJson<String?>(json['syncErrorMessage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'recipientEmail': serializer.toJson<String>(recipientEmail),
      'amount': serializer.toJson<double>(amount),
      'note': serializer.toJson<String>(note),
      'status': serializer.toJson<String>(status),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'syncedAt': serializer.toJson<DateTime?>(syncedAt),
      'syncErrorMessage': serializer.toJson<String?>(syncErrorMessage),
    };
  }

  TransactionQueueData copyWith(
          {String? id,
          String? userId,
          String? recipientEmail,
          double? amount,
          String? note,
          String? status,
          DateTime? timestamp,
          DateTime? createdAt,
          Value<DateTime?> syncedAt = const Value.absent(),
          Value<String?> syncErrorMessage = const Value.absent()}) =>
      TransactionQueueData(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        recipientEmail: recipientEmail ?? this.recipientEmail,
        amount: amount ?? this.amount,
        note: note ?? this.note,
        status: status ?? this.status,
        timestamp: timestamp ?? this.timestamp,
        createdAt: createdAt ?? this.createdAt,
        syncedAt: syncedAt.present ? syncedAt.value : this.syncedAt,
        syncErrorMessage: syncErrorMessage.present
            ? syncErrorMessage.value
            : this.syncErrorMessage,
      );
  @override
  String toString() {
    return (StringBuffer('TransactionQueueData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('recipientEmail: $recipientEmail, ')
          ..write('amount: $amount, ')
          ..write('note: $note, ')
          ..write('status: $status, ')
          ..write('timestamp: $timestamp, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('syncErrorMessage: $syncErrorMessage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, recipientEmail, amount, note,
      status, timestamp, createdAt, syncedAt, syncErrorMessage);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionQueueData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.recipientEmail == this.recipientEmail &&
          other.amount == this.amount &&
          other.note == this.note &&
          other.status == this.status &&
          other.timestamp == this.timestamp &&
          other.createdAt == this.createdAt &&
          other.syncedAt == this.syncedAt &&
          other.syncErrorMessage == this.syncErrorMessage);
}

class TransactionQueueTableCompanion
    extends UpdateCompanion<TransactionQueueData> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> recipientEmail;
  final Value<double> amount;
  final Value<String> note;
  final Value<String> status;
  final Value<DateTime> timestamp;
  final Value<DateTime> createdAt;
  final Value<DateTime?> syncedAt;
  final Value<String?> syncErrorMessage;
  final Value<int> rowid;
  const TransactionQueueTableCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.recipientEmail = const Value.absent(),
    this.amount = const Value.absent(),
    this.note = const Value.absent(),
    this.status = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.syncErrorMessage = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionQueueTableCompanion.insert({
    required String id,
    required String userId,
    required String recipientEmail,
    required double amount,
    required String note,
    required String status,
    required DateTime timestamp,
    required DateTime createdAt,
    this.syncedAt = const Value.absent(),
    this.syncErrorMessage = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        recipientEmail = Value(recipientEmail),
        amount = Value(amount),
        note = Value(note),
        status = Value(status),
        timestamp = Value(timestamp),
        createdAt = Value(createdAt);
  static Insertable<TransactionQueueData> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? recipientEmail,
    Expression<double>? amount,
    Expression<String>? note,
    Expression<String>? status,
    Expression<DateTime>? timestamp,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? syncedAt,
    Expression<String>? syncErrorMessage,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (recipientEmail != null) 'recipient_email': recipientEmail,
      if (amount != null) 'amount': amount,
      if (note != null) 'note': note,
      if (status != null) 'status': status,
      if (timestamp != null) 'timestamp': timestamp,
      if (createdAt != null) 'created_at': createdAt,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (syncErrorMessage != null) 'sync_error_message': syncErrorMessage,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionQueueTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? recipientEmail,
      Value<double>? amount,
      Value<String>? note,
      Value<String>? status,
      Value<DateTime>? timestamp,
      Value<DateTime>? createdAt,
      Value<DateTime?>? syncedAt,
      Value<String?>? syncErrorMessage,
      Value<int>? rowid}) {
    return TransactionQueueTableCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      recipientEmail: recipientEmail ?? this.recipientEmail,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
      syncedAt: syncedAt ?? this.syncedAt,
      syncErrorMessage: syncErrorMessage ?? this.syncErrorMessage,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (recipientEmail.present) {
      map['recipient_email'] = Variable<String>(recipientEmail.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (syncErrorMessage.present) {
      map['sync_error_message'] = Variable<String>(syncErrorMessage.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionQueueTableCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('recipientEmail: $recipientEmail, ')
          ..write('amount: $amount, ')
          ..write('note: $note, ')
          ..write('status: $status, ')
          ..write('timestamp: $timestamp, ')
          ..write('createdAt: $createdAt, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('syncErrorMessage: $syncErrorMessage, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionHistoryTableTable extends TransactionHistoryTable
    with TableInfo<$TransactionHistoryTableTable, TransactionHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionHistoryTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _recipientEmailMeta =
      const VerificationMeta('recipientEmail');
  @override
  late final GeneratedColumn<String> recipientEmail = GeneratedColumn<String>(
      'recipient_email', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, recipientEmail, amount, note, status, timestamp, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_history_table';
  @override
  VerificationContext validateIntegrity(
      Insertable<TransactionHistoryData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('recipient_email')) {
      context.handle(
          _recipientEmailMeta,
          recipientEmail.isAcceptableOrUnknown(
              data['recipient_email']!, _recipientEmailMeta));
    } else if (isInserting) {
      context.missing(_recipientEmailMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {userId, id},
      ];
  @override
  TransactionHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionHistoryData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      recipientEmail: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}recipient_email'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $TransactionHistoryTableTable createAlias(String alias) {
    return $TransactionHistoryTableTable(attachedDatabase, alias);
  }
}

class TransactionHistoryData extends DataClass
    implements Insertable<TransactionHistoryData> {
  final String id;
  final String userId;
  final String recipientEmail;
  final double amount;
  final String note;
  final String status;
  final DateTime timestamp;
  final DateTime createdAt;
  const TransactionHistoryData(
      {required this.id,
      required this.userId,
      required this.recipientEmail,
      required this.amount,
      required this.note,
      required this.status,
      required this.timestamp,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['recipient_email'] = Variable<String>(recipientEmail);
    map['amount'] = Variable<double>(amount);
    map['note'] = Variable<String>(note);
    map['status'] = Variable<String>(status);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TransactionHistoryTableCompanion toCompanion(bool nullToAbsent) {
    return TransactionHistoryTableCompanion(
      id: Value(id),
      userId: Value(userId),
      recipientEmail: Value(recipientEmail),
      amount: Value(amount),
      note: Value(note),
      status: Value(status),
      timestamp: Value(timestamp),
      createdAt: Value(createdAt),
    );
  }

  factory TransactionHistoryData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionHistoryData(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      recipientEmail: serializer.fromJson<String>(json['recipientEmail']),
      amount: serializer.fromJson<double>(json['amount']),
      note: serializer.fromJson<String>(json['note']),
      status: serializer.fromJson<String>(json['status']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'recipientEmail': serializer.toJson<String>(recipientEmail),
      'amount': serializer.toJson<double>(amount),
      'note': serializer.toJson<String>(note),
      'status': serializer.toJson<String>(status),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TransactionHistoryData copyWith(
          {String? id,
          String? userId,
          String? recipientEmail,
          double? amount,
          String? note,
          String? status,
          DateTime? timestamp,
          DateTime? createdAt}) =>
      TransactionHistoryData(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        recipientEmail: recipientEmail ?? this.recipientEmail,
        amount: amount ?? this.amount,
        note: note ?? this.note,
        status: status ?? this.status,
        timestamp: timestamp ?? this.timestamp,
        createdAt: createdAt ?? this.createdAt,
      );
  @override
  String toString() {
    return (StringBuffer('TransactionHistoryData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('recipientEmail: $recipientEmail, ')
          ..write('amount: $amount, ')
          ..write('note: $note, ')
          ..write('status: $status, ')
          ..write('timestamp: $timestamp, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, userId, recipientEmail, amount, note, status, timestamp, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionHistoryData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.recipientEmail == this.recipientEmail &&
          other.amount == this.amount &&
          other.note == this.note &&
          other.status == this.status &&
          other.timestamp == this.timestamp &&
          other.createdAt == this.createdAt);
}

class TransactionHistoryTableCompanion
    extends UpdateCompanion<TransactionHistoryData> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> recipientEmail;
  final Value<double> amount;
  final Value<String> note;
  final Value<String> status;
  final Value<DateTime> timestamp;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TransactionHistoryTableCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.recipientEmail = const Value.absent(),
    this.amount = const Value.absent(),
    this.note = const Value.absent(),
    this.status = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionHistoryTableCompanion.insert({
    required String id,
    required String userId,
    required String recipientEmail,
    required double amount,
    required String note,
    required String status,
    required DateTime timestamp,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        recipientEmail = Value(recipientEmail),
        amount = Value(amount),
        note = Value(note),
        status = Value(status),
        timestamp = Value(timestamp),
        createdAt = Value(createdAt);
  static Insertable<TransactionHistoryData> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? recipientEmail,
    Expression<double>? amount,
    Expression<String>? note,
    Expression<String>? status,
    Expression<DateTime>? timestamp,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (recipientEmail != null) 'recipient_email': recipientEmail,
      if (amount != null) 'amount': amount,
      if (note != null) 'note': note,
      if (status != null) 'status': status,
      if (timestamp != null) 'timestamp': timestamp,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionHistoryTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? recipientEmail,
      Value<double>? amount,
      Value<String>? note,
      Value<String>? status,
      Value<DateTime>? timestamp,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return TransactionHistoryTableCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      recipientEmail: recipientEmail ?? this.recipientEmail,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (recipientEmail.present) {
      map['recipient_email'] = Variable<String>(recipientEmail.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionHistoryTableCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('recipientEmail: $recipientEmail, ')
          ..write('amount: $amount, ')
          ..write('note: $note, ')
          ..write('status: $status, ')
          ..write('timestamp: $timestamp, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $UserCacheTableTable userCacheTable = $UserCacheTableTable(this);
  late final $WalletCacheTableTable walletCacheTable =
      $WalletCacheTableTable(this);
  late final $TransactionQueueTableTable transactionQueueTable =
      $TransactionQueueTableTable(this);
  late final $TransactionHistoryTableTable transactionHistoryTable =
      $TransactionHistoryTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        userCacheTable,
        walletCacheTable,
        transactionQueueTable,
        transactionHistoryTable
      ];
}
