import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:jd_style_logistics/core/auth/token_manager.dart';
import 'package:jd_style_logistics/core/network/api_endpoints.dart';
import 'package:jd_style_logistics/core/network/api_exception.dart';
import 'package:jd_style_logistics/core/storage/secure_storage_service.dart';

/// Production-grade Dio client with:
///   1. Bearer token attached on every non-public request
///   2. Proactive token refresh when expiry < 30 s
///   3. Reactive 401 handler with one retry after refresh
///   4. Safe logout via [TokenManager.sessionExpiredStream] on refresh failure
class ApiClient {
  ApiClient._();
  static final ApiClient _instance = ApiClient._();
  static ApiClient get instance => _instance;

  late final Dio _dio;
  bool _initialized = false;

  void init() {
    if (_initialized) return;
    _initialized = true;

    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout:
            const Duration(milliseconds: ApiEndpoints.connectTimeoutMs),
        receiveTimeout:
            const Duration(milliseconds: ApiEndpoints.receiveTimeoutMs),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(_JwtInterceptor(_dio));

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: false,
          responseBody: false,
          logPrint: (o) => debugPrint('[API] $o'),
        ),
      );
    }
  }

  Dio get dio => _dio;

  // ── HTTP helpers ──────────────────────────────────────────────────────────

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? params,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(path,
          queryParameters: params, options: options);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? params,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(path,
          data: data, queryParameters: params, options: options);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(path, data: data, options: options);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    try {
      return await _dio.patch<T>(path, data: data, options: options);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Response<T>> delete<T>(String path, {Options? options}) async {
    try {
      return await _dio.delete<T>(path, options: options);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _JwtInterceptor extends Interceptor {
  final Dio _dio;

  _JwtInterceptor(this._dio);

  // Dart is single-threaded; this boolean is sufficient as a mutex.
  bool _isRefreshing = false;
  final List<Completer<bool>> _refreshWaiters = [];

  static const _retried = '_jwt_retried';

  static const _publicPaths = {
    ApiEndpoints.sendOtp,
    ApiEndpoints.verifyOtp,
    ApiEndpoints.refreshToken,
  };

  // ── onRequest ──────────────────────────────────────────────────────────────

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Skip auth header for public endpoints
    if (_isPublic(options.path)) {
      return handler.next(options);
    }

    // If this is an internal retry, token is already fresh — just attach it.
    if (options.extra[_retried] == true) {
      final token = await SecureStorageService.instance.getAccessToken();
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
      return handler.next(options);
    }

    // Proactive refresh: if token expires in < 30 s, refresh before sending.
    final expired = await TokenManager.instance.isTokenExpired();
    if (expired) {
      final ok = await _refreshWithLock();
      if (!ok) {
        await TokenManager.instance.clearSession();
        TokenManager.instance.signalSessionExpired();
        return handler.reject(
          DioException(
            requestOptions: options,
            message: 'Session expired. Please login again.',
            type: DioExceptionType.cancel,
          ),
        );
      }
    }

    // Attach current (possibly refreshed) token
    final token = await SecureStorageService.instance.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  // ── onError ────────────────────────────────────────────────────────────────

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) return handler.next(err);

    final alreadyRetried = err.requestOptions.extra[_retried] == true;
    final isRefreshCall  = err.requestOptions.path == ApiEndpoints.refreshToken;

    if (alreadyRetried || isRefreshCall) {
      await TokenManager.instance.clearSession();
      TokenManager.instance.signalSessionExpired();
      return handler.next(err);
    }

    // Try to refresh and retry once
    final ok = await _refreshWithLock();
    if (ok) {
      try {
        final token = await SecureStorageService.instance.getAccessToken();
        final retryOpts = err.requestOptions;
        retryOpts.extra[_retried] = true;
        retryOpts.headers['Authorization'] = 'Bearer $token';
        final response = await _dio.fetch(retryOpts);
        return handler.resolve(response);
      } on DioException catch (e) {
        return handler.next(e);
      }
    }

    await TokenManager.instance.clearSession();
    TokenManager.instance.signalSessionExpired();
    handler.next(err);
  }

  // ── Refresh with mutex ─────────────────────────────────────────────────────

  Future<bool> _refreshWithLock() async {
    // Another coroutine is already refreshing → wait for its result.
    if (_isRefreshing) {
      final c = Completer<bool>();
      _refreshWaiters.add(c);
      return c.future;
    }

    _isRefreshing = true;
    bool result = false;

    try {
      result = await _doRefresh();
    } finally {
      _isRefreshing = false;
      for (final c in _refreshWaiters) {
        c.complete(result);
      }
      _refreshWaiters.clear();
    }

    return result;
  }

  Future<bool> _doRefresh() async {
    try {
      final refreshToken =
          await SecureStorageService.instance.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) return false;

      // Use a bare Dio instance (no interceptors) to avoid recursive calls.
      final bare = Dio(BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout:
            const Duration(milliseconds: ApiEndpoints.connectTimeoutMs),
        receiveTimeout:
            const Duration(milliseconds: ApiEndpoints.receiveTimeoutMs),
      ));

      final res = await bare.post(
        ApiEndpoints.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      final data = res.data['data'] as Map<String, dynamic>;
      final newAccess  = data['access_token'] as String;
      final newRefresh = data['refresh_token'] as String? ?? refreshToken;
      final expiresIn  = (data['expires_in'] as num?)?.toInt() ?? 3600;

      await TokenManager.instance.saveTokens(
        accessToken: newAccess,
        refreshToken: newRefresh,
        expiresInSeconds: expiresIn,
      );

      return true;
    } catch (_) {
      return false;
    }
  }

  bool _isPublic(String path) =>
      _publicPaths.any((p) => path == p || path.endsWith(p));
}
