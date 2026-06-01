import 'package:dio/dio.dart';

/// Typed API errors surfaced to the UI and providers.
/// Callers pattern-match on subtypes — never inspect raw [DioException].
sealed class ApiException implements Exception {
  const ApiException();

  /// Converts a [DioException] to the appropriate [ApiException] subtype.
  /// Handles every [DioExceptionType] exhaustively.
  static ApiException fromDioException(DioException e) {
    return switch (e.type) {
      DioExceptionType.badResponse => _fromStatus(e),
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError ||
      DioExceptionType.badCertificate ||
      DioExceptionType.cancel ||
      DioExceptionType.unknown =>
        const NetworkException(),
    };
  }

  static ApiException _fromStatus(DioException e) {
    final status = e.response?.statusCode ?? 0;
    return switch (status) {
      401 => const UnauthorizedException(),
      404 => const NotFoundException(),
      409 => const ConflictException(),
      429 => const RateLimitException(),
      >= 500 => ServerException(e.response?.statusMessage ?? 'Server error'),
      _ => ServerException('Unexpected HTTP status $status'),
    };
  }
}

/// No network connectivity or request timed out.
final class NetworkException extends ApiException {
  const NetworkException();

  @override
  String toString() => 'NetworkException: no connectivity or timeout';
}

/// The requested resource does not exist (HTTP 404).
final class NotFoundException extends ApiException {
  const NotFoundException();

  @override
  String toString() => 'NotFoundException: resource not found (404)';
}

/// Authentication token is missing or expired (HTTP 401).
/// Must never be silently swallowed — always triggers re-authentication.
final class UnauthorizedException extends ApiException {
  const UnauthorizedException();

  @override
  String toString() => 'UnauthorizedException: token expired or invalid (401)';
}

/// A conflicting resource already exists (HTTP 409).
/// Used when a claim is submitted but an active claim already exists.
final class ConflictException extends ApiException {
  const ConflictException();

  @override
  String toString() => 'ConflictException: resource conflict (409)';
}

/// Request was rate-limited by the server (HTTP 429).
final class RateLimitException extends ApiException {
  const RateLimitException();

  @override
  String toString() => 'RateLimitException: too many requests (429)';
}

/// Unexpected server-side error (HTTP 5xx).
final class ServerException extends ApiException {
  const ServerException(this.message);

  final String message;

  @override
  String toString() => 'ServerException: $message';
}

/// Convenience extension — services use `throw e.asApiException` instead of
/// manually unwrapping [DioException.error] or calling the factory.
extension DioExceptionX on DioException {
  /// Returns the [ApiException] stored by [ErrorInterceptor], or converts
  /// this exception on the fly if the interceptor did not run.
  ApiException get asApiException =>
      error is ApiException ? error as ApiException : ApiException.fromDioException(this);
}
