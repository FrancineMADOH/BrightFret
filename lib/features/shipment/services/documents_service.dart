import 'package:dio/dio.dart';

import '../../../core/http/api_exception.dart';
import '../models/shipment_document.dart';

/// Service for `GET /api/shipment/{suffix}/documents`.
/// Requires a valid bearer token (injected by [AuthInterceptor]).
class DocumentsService {
  const DocumentsService(this._dio);

  final Dio _dio;

  /// Returns the list of documents attached to [suffix].
  /// [instanceUrl] is used to make relative document URLs absolute.
  Future<List<ShipmentDocument>> getDocuments(
    String suffix, {
    String instanceUrl = '',
  }) async {
    try {
      final response = await _dio.get('/api/shipment/$suffix/documents');
      final raw = response.data as List<dynamic>;
      return raw
          .map((e) => ShipmentDocument.fromJson(
                e as Map<String, dynamic>,
                baseUrl: instanceUrl,
              ))
          .toList();
    } on DioException catch (e) {
      throw e.asApiException;
    }
  }
}
