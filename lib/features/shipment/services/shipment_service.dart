import 'package:dio/dio.dart';

import '../../../core/http/api_exception.dart';
import '../models/full_shipment.dart';

/// Service for the authenticated shipment endpoint (`GET /api/shipment/{suffix}`).
/// Requires a valid bearer token injected automatically by [AuthInterceptor].
class ShipmentService {
  const ShipmentService(this._dio);

  final Dio _dio;

  /// Fetches full shipment detail including pricing, client, and claim status.
  /// Throws [UnauthorizedException] when the token is expired — the caller
  /// should redirect to S07 for re-authentication.
  Future<FullShipment> getFullShipment(String suffix) async {
    try {
      final response = await _dio.get('/api/shipment/$suffix');
      return FullShipment.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.asApiException;
    }
  }
}
