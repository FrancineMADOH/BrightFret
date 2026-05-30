import 'package:dio/dio.dart';

import '../../../core/http/api_exception.dart';
import '../models/forwarder_info.dart';

/// Service for the forwarder branding endpoint (`GET /api/forwarder/info`).
class ForwarderService {
  const ForwarderService(this._dio);

  final Dio _dio;

  /// Fetches the forwarder's name, logo URL, primary colour, and contact phone.
  /// Throws an [ApiException] subtype on failure.
  Future<ForwarderInfo> getForwarderInfo() async {
    try {
      final response = await _dio.get('/api/forwarder/info');
      return ForwarderInfo.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.asApiException;
    }
  }
}
