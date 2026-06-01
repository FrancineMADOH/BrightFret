import 'package:dio/dio.dart';

import '../../../core/http/api_exception.dart';

/// Service for claim endpoints:
/// - `POST /api/shipment/{suffix}/claim`
class ClaimService {
  const ClaimService(this._dio);

  final Dio _dio;

  /// Submits a new claim for [suffix]. Returns the Odoo claim reference on success.
  /// Throws [ConflictException] (409) if an active claim already exists.
  Future<String> submitClaim({
    required String suffix,
    required String claimType,
    required String description,
    required double claimedAmount,
  }) async {
    try {
      final response = await _dio.post(
        '/api/shipment/$suffix/claim',
        data: {
          'claim_type': claimType,
          'description': description,
          'claimed_amount': claimedAmount,
        },
      );
      return (response.data as Map<String, dynamic>)['reference'] as String;
    } on DioException catch (e) {
      throw e.asApiException;
    }
  }
}
