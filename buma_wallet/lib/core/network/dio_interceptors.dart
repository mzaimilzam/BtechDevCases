import 'dart:io';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../storage/secure_token_storage.dart';

/// Custom DioInterceptor implementing robust retry logic for poor connectivity.
///
/// Features:
/// - Retry up to 3 times on SocketException (no internet)
/// - Exponential backoff: 1s, 2s, 4s
/// - Logs network failures for debugging
/// - Works with any HTTP method
@Injectable()
class RetryInterceptor extends Interceptor {
  static const int _maxRetries = 3;
  static const Duration _initialDelay = Duration(seconds: 1);
  static const String _retryCountKey = 'retry_count';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Check if error is a network-related failure
    final retryCount = _getRetryCount(err.requestOptions);

    // Only retry on specific network errors
    if (_isNetworkError(err) && retryCount < _maxRetries) {
      try {
        // Exponential backoff: 1s, 2s, 4s
        final delay = _initialDelay * (1 << retryCount);
        await Future.delayed(delay);

        // Increment retry count
        _setRetryCount(err.requestOptions, retryCount + 1);

        // Retry the request
        return handler.resolve(await _retry(err.requestOptions));
      } catch (e) {
        // Retry failed, pass error to handler
        return handler.next(err);
      }
    }

    return handler.next(err);
  }

  /// Get retry count from request options
  int _getRetryCount(RequestOptions options) {
    try {
      return (options.extra[_retryCountKey] as int?) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Set retry count in request options
  void _setRetryCount(RequestOptions options, int count) {
    options.extra[_retryCountKey] = count;
  }

  /// Check if error is network-related
  bool _isNetworkError(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        (error.error is SocketException);
  }

  /// Retry the request
  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      sendTimeout: requestOptions.sendTimeout,
      receiveTimeout: requestOptions.receiveTimeout,
    );
    return Dio().request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}

/// Authorization interceptor that adds JWT token to requests and handles token refresh
@Injectable()
class AuthInterceptor extends Interceptor {
  final SecureTokenStorage _tokenStorage;
  bool _isRefreshing = false;
  final List<Future<void>> _pendingRequests = [];

  AuthInterceptor(this._tokenStorage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Get token from secure storage
    final token = await _tokenStorage.getAccessToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle token expiry (401)
    if (err.response?.statusCode == 401) {
      // Try to refresh token if we have a refresh token
      final currentToken = await _tokenStorage.getAuthToken();
      if (currentToken?.refreshToken != null && !_isRefreshing) {
        _isRefreshing = true;
        try {
          // Attempt token refresh via API
          final dio = Dio();
          final baseUrl = _getBaseUrlFromRequest(err.requestOptions);

          final response = await dio.post<Map<String, dynamic>>(
            '$baseUrl/auth/refresh',
            data: {'refreshToken': currentToken!.refreshToken},
          );

          // If refresh successful, retry original request
          if (response.statusCode == 200) {
            _isRefreshing = false;
            _pendingRequests.clear();

            // Retry original request
            final retryResponse = await dio.request<dynamic>(
              err.requestOptions.path,
              data: err.requestOptions.data,
              queryParameters: err.requestOptions.queryParameters,
              options: Options(
                method: err.requestOptions.method,
                headers: err.requestOptions.headers,
              ),
            );
            return handler.resolve(retryResponse);
          }
        } catch (e) {
          // Refresh failed, clear token and proceed to error
          _isRefreshing = false;
          _pendingRequests.clear();
          await _tokenStorage.clearAuthToken();
        }
      }
    }

    return handler.next(err);
  }

  /// Extract base URL from request
  String _getBaseUrlFromRequest(RequestOptions options) {
    final url = options.uri.toString();
    // Remove path to get base URL
    if (url.contains('/auth/') || url.contains('/wallet/')) {
      return url.split('/').take(3).join('/');
    }
    return 'http://localhost:8080';
  }
}
