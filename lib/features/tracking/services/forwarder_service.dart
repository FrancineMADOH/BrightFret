import 'package:dio/dio.dart';

import '../../../core/http/api_exception.dart';
import '../models/forwarder_info.dart';

/// Service for the forwarder branding endpoint (`GET /api/forwarder/info`).
class ForwarderService {
  const ForwarderService(this._dio);

  final Dio _dio;

  /// Fetches the forwarder's name, logo URL, primary colour, and contact phone.
  /// Pass [baseUrl] so relative logo URLs are made absolute at parse time.
  /// Throws an [ApiException] subtype on failure.
  Future<ForwarderInfo> getForwarderInfo({String? baseUrl}) async {
    try {
      final response = await _dio.get('/api/forwarder/info');
      return ForwarderInfo.fromJson(
        response.data as Map<String, dynamic>,
        baseUrl: baseUrl,
      );
    } on DioException catch (e) {
      throw e.asApiException;
    }
  }
}
