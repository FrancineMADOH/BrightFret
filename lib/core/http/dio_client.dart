import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'api_exception.dart';

const Duration _kConnectTimeout = Duration(seconds: 10);
const Duration _kReceiveTimeout = Duration(seconds: 30);

/// Contract for reading an auth token given a Dio [RequestOptions].
/// Implemented by Hive token storage in F0.5. Stub returns null.
abstract interface class TokenReader {
  /// Returns the bearer token for this request, or null if unauthenticated.
  String? getToken(RequestOptions options);
}

/// No-op [TokenReader] used until Hive storage is wired in F0.5.
class _NullTokenReader implements TokenReader {
  const _NullTokenReader();

  @override
  String? getToken(RequestOptions options) => null;
}

/// Injects `Authorization: Bearer <token>` for requests that have a token.
class AuthInterceptor extends Interceptor {
  const AuthInterceptor(this._tokenReader);

  final TokenReader _tokenReader;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _tokenReader.getToken(options);
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

/// Converts [DioException] → [ApiException] so callers never see raw Dio errors.
/// Stores the converted exception in [DioException.error] for service-layer access
/// via the [DioExceptionX.asApiException] extension.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: ApiException.fromDioException(err),
        message: ApiException.fromDioException(err).toString(),
      ),
    );
  }
}

/// Injects `Accept-Language` from the persisted locale preference (Hive).
/// Reads at request time so a mid-session language change takes effect immediately.
class LanguageInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final box = Hive.box<dynamic>('prefs');
    final code = box.get('language', defaultValue: 'fr') as String;
    options.headers['Accept-Language'] = code;
    handler.next(options);
  }
}

/// Logs request method+URL and response status in debug builds only.
/// Never logs headers, bodies, or any field that could contain tokens or PII.
class _BfLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('[BF HTTP] → ${options.method} ${options.uri.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('[BF HTTP] ← ${response.statusCode} ${response.requestOptions.uri.path}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('[BF HTTP] ✗ ${err.type.name} ${err.requestOptions.uri.path}');
    handler.next(err);
  }
}

/// Factory + cache for [Dio] instances scoped to an Odoo instance base URL.
///
/// Usage:
/// ```dart
/// final dio = DioClient.forInstance('https://odoo.kamgho-transit.cm');
/// ```
///
/// One [Dio] instance is created per [baseUrl] and reused for the app lifetime.
/// The [tokenReader] is only used on first creation; pass one when Hive is ready (F0.5).
class DioClient {
  DioClient._();

  static final Map<String, Dio> _cache = {};

  /// Returns the cached [Dio] for [baseUrl], or creates one if not yet cached.
  /// [tokenReader] is applied only on first creation — ignored on subsequent calls.
  /// [database] sets the `X-Odoo-Database` header required by multi-db Odoo instances.
  static Dio forInstance(
    String baseUrl, {
    TokenReader? tokenReader,
    String? database,
  }) {
    return _cache.putIfAbsent(
      baseUrl,
      () => _build(
        baseUrl,
        tokenReader ?? const _NullTokenReader(),
        database: database,
      ),
    );
  }

  /// Removes and closes the cached [Dio] instance for [baseUrl].
  /// Call when a forwarder session ends or in tests between runs.
  static void dispose(String baseUrl) {
    _cache.remove(baseUrl)?.close();
  }

  /// Removes and closes all cached instances.
  static void disposeAll() {
    for (final dio in _cache.values) {
      dio.close();
    }
    _cache.clear();
  }

  static Dio _build(String baseUrl, TokenReader tokenReader, {String? database}) {
    final headers = <String, dynamic>{'Accept': 'application/json'};
    if (database != null) headers['X-Odoo-Database'] = database;

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: _kConnectTimeout,
        receiveTimeout: _kReceiveTimeout,
        headers: headers,
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(tokenReader),
      LanguageInterceptor(),
      ErrorInterceptor(),
      if (kDebugMode) _BfLogInterceptor(),
    ]);

    return dio;
  }
}
