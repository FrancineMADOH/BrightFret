import 'package:dio/dio.dart';

import '../../../core/http/api_exception.dart';
import '../models/claim_detail.dart';

/// Service for claim endpoints:
/// - `POST /api/shipment/{suffix}/claim`
/// - `GET  /api/shipment/{suffix}/claim`
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

  /// Fetches the latest claim for [suffix].
  /// Throws [NotFoundException] (404) when no claim exists.
  Future<ClaimDetail> getClaim({required String suffix}) async {
    try {
      final response = await _dio.get('/api/shipment/$suffix/claim');
      return ClaimDetail.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw e.asApiException;
    }
  }

  /// Fetches all claims for [suffix], newest first.
  Future<List<ClaimDetail>> getClaims({required String suffix}) async {
    try {
      final response = await _dio.get('/api/shipment/$suffix/claims');
      final list = response.data as List<dynamic>;
      return list
          .map((e) => ClaimDetail.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.asApiException;
    }
  }
}
