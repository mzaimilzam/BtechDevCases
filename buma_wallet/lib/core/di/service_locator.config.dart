// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:buma_wallet/core/database/app_database.dart' as _i4;
import 'package:buma_wallet/core/network/api_client.dart' as _i7;
import 'package:buma_wallet/core/network/dio_interceptors.dart' as _i8;
import 'package:buma_wallet/core/storage/secure_token_storage.dart' as _i9;
import 'package:buma_wallet/data/datasources/local_auth_datasource.dart' as _i3;
import 'package:buma_wallet/data/datasources/local_wallet_datasource.dart'
    as _i5;
import 'package:buma_wallet/data/datasources/remote_auth_datasource.dart'
    as _i13;
import 'package:buma_wallet/data/datasources/remote_wallet_datasource.dart'
    as _i6;
import 'package:buma_wallet/data/repositories/auth_repository_impl.dart'
    as _i15;
import 'package:buma_wallet/data/repositories/wallet_repository_impl.dart'
    as _i12;
import 'package:buma_wallet/domain/repositories/auth_repository.dart' as _i14;
import 'package:buma_wallet/domain/repositories/wallet_repository.dart' as _i11;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i10;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;

extension GetItInjectableX on _i1.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i1.GetIt init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.factory<_i3.LocalAuthDataSource>(
        () => _i3.LocalAuthDataSourceImpl(gh<_i4.AppDatabase>()));
    gh.factory<_i5.LocalWalletDataSource>(
        () => _i5.LocalWalletDataSourceImpl(gh<_i4.AppDatabase>()));
    gh.factory<_i6.RemoteWalletDataSource>(
        () => _i6.RemoteWalletDataSourceImpl(gh<_i7.ApiClient>()));
    gh.factory<_i8.RetryInterceptor>(() => _i8.RetryInterceptor());
    gh.factory<_i9.SecureTokenStorage>(
        () => _i9.SecureTokenStorageImpl(gh<_i10.FlutterSecureStorage>()));
    gh.factory<_i11.WalletRepository>(() => _i12.WalletRepositoryImpl(
          gh<_i6.RemoteWalletDataSource>(),
          gh<_i5.LocalWalletDataSource>(),
          gh<_i9.SecureTokenStorage>(),
        ));
    gh.factory<_i8.AuthInterceptor>(
        () => _i8.AuthInterceptor(gh<_i9.SecureTokenStorage>()));
    gh.factory<_i13.RemoteAuthDataSource>(() => _i13.RemoteAuthDataSourceImpl(
          gh<_i7.ApiClient>(),
          gh<_i9.SecureTokenStorage>(),
        ));
    gh.factory<_i14.AuthRepository>(() => _i15.AuthRepositoryImpl(
          gh<_i13.RemoteAuthDataSource>(),
          gh<_i3.LocalAuthDataSource>(),
          gh<_i9.SecureTokenStorage>(),
        ));
    return this;
  }
}
