import 'package:dio/dio.dart';

import '../../../core/http/api_exception.dart';
import '../models/public_shipment.dart';

/// Service for the public tracking API endpoint (`GET /api/track/{suffix}`).
/// Instantiated per-call in [shipmentTrackingProvider] with a Dio instance
/// from [dioForInstanceProvider].
class TrackingService {
  const TrackingService(this._dio);

  final Dio _dio;

  /// Fetches the public shipment timeline for [suffix] from the forwarder instance.
  /// Throws an [ApiException] subtype on any HTTP or connectivity error.
  Future<PublicShipment> getPublicShipment(String suffix) async {
    try {
      final response = await _dio.get('/api/track/$suffix');
      return PublicShipment.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.asApiException;
    }
  }
}
