import 'package:dio/dio.dart';

import '../../../core/http/api_exception.dart';
import '../../../core/models/auth_token.dart';

/// Service for phone-based authentication (F2.1).
/// Wraps `POST /api/track/{suffix}/verify`.
class AuthService {
  const AuthService(this._dio);

  final Dio _dio;

  /// Sends [phoneSuffix] (last 4 digits) for [suffix] and returns a 24h [AuthToken].
  Future<AuthToken> verifyPhone({
    required String suffix,
    required String phoneSuffix,
    required String instanceUrl,
  }) async {
    try {
      final response = await _dio.post(
        '/api/track/$suffix/verify',
        data: {'phone_suffix': phoneSuffix},
      );
      final data = response.data as Map<String, dynamic>;
      return AuthToken(
        token: data['token'] as String,
        suffix: suffix,
        instanceUrl: instanceUrl,
        expiresAt: DateTime.now().add(
          Duration(seconds: (data['expires_in'] as int?) ?? 86400),
        ),
      );
    } on DioException catch (e) {
      throw e.asApiException;
    }
  }
}
