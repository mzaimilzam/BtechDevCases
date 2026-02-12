import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../data/datasources/local_auth_datasource.dart';
import '../../data/datasources/local_wallet_datasource.dart';
import '../../data/datasources/remote_auth_datasource.dart';
import '../../data/datasources/remote_wallet_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/wallet_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../database/app_database.dart';
import '../network/api_client.dart';
import '../network/dio_interceptors.dart';
import '../storage/secure_token_storage.dart';

final getIt = GetIt.instance;

/// Service Locator Configuration
/// Initializes all dependencies using injectable package
///
/// Usage:
/// - Setup in main.dart: await configureDependencies();
/// - Access: final authRepo = getIt<AuthRepository>();
@InjectableInit()
Future<void> configureDependencies() async {
  // Register platform-specific dependencies
  getIt.registerSingleton<FlutterSecureStorage>(
    const FlutterSecureStorage(),
  );

  // Initialize database
  final database = await _initializeDatabase();
  getIt.registerSingleton<AppDatabase>(database);

  // Initialize Dio first (needed by ApiClient)
  final secureStorage = SecureTokenStorageImpl(
    getIt<FlutterSecureStorage>(),
  );
  final dio = _initializeDio(secureStorage);
  getIt.registerSingleton<Dio>(dio);

  // Register SecureTokenStorage interface
  getIt.registerSingleton<SecureTokenStorage>(secureStorage);

  // Register API client
  final apiClient = ApiClient(
    dio,
    baseUrl:
        'http://10.0.2.2:8080', // Android emulator uses 10.0.2.2 to access host
  );
  getIt.registerSingleton<ApiClient>(apiClient);

  // Register data sources
  getIt.registerSingleton<RemoteAuthDataSource>(
    RemoteAuthDataSourceImpl(apiClient, secureStorage as SecureTokenStorage),
  );
  getIt.registerSingleton<LocalAuthDataSource>(
    LocalAuthDataSourceImpl(database),
  );
  getIt.registerSingleton<RemoteWalletDataSource>(
    RemoteWalletDataSourceImpl(apiClient),
  );
  getIt.registerSingleton<LocalWalletDataSource>(
    LocalWalletDataSourceImpl(database),
  );

  // Register repositories
  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(
      getIt<RemoteAuthDataSource>(),
      getIt<LocalAuthDataSource>(),
      secureStorage,
    ),
  );
  getIt.registerSingleton<WalletRepository>(
    WalletRepositoryImpl(
      getIt<RemoteWalletDataSource>(),
      getIt<LocalWalletDataSource>(),
      secureStorage,
    ),
  );

  // Note: getIt.init() not called since we're manually registering all dependencies
}

/// Initialize Drift database
Future<AppDatabase> _initializeDatabase() async {
  final docsDir = await getApplicationDocumentsDirectory();
  final file = File('${docsDir.path}/buma_wallet.db');
  final queryExecutor = NativeDatabase(file);
  return AppDatabase(queryExecutor);
}

/// Initialize Dio with interceptors
Dio _initializeDio(SecureTokenStorage tokenStorage) {
  final dio = Dio();

  // Add retry interceptor for poor connectivity
  dio.interceptors.add(RetryInterceptor());

  // Add auth interceptor for JWT tokens
  dio.interceptors.add(AuthInterceptor(tokenStorage));

  // Add pretty logging interceptor (dev only)
  dio.interceptors.add(
    PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: true,
      error: true,
      compact: true,
    ),
  );

  // Configure timeouts
  dio.options = BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
    contentType: 'application/json',
    responseType: ResponseType.json,
  );

  return dio;
}
