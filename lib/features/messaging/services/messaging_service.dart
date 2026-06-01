import 'package:dio/dio.dart';

import '../../../core/http/api_exception.dart';
import '../models/shipment_message.dart';

/// Service for the messaging endpoints:
/// - `GET /api/shipment/{suffix}/messages`
/// - `POST /api/shipment/{suffix}/message`
class MessagingService {
  const MessagingService(this._dio);

  final Dio _dio;

  /// Returns all messages for [suffix], ordered oldest-first.
  Future<List<ShipmentMessage>> getMessages(String suffix) async {
    try {
      final response = await _dio.get('/api/shipment/$suffix/messages');
      final raw = response.data as List<dynamic>;
      return raw
          .map((e) => ShipmentMessage.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw e.asApiException;
    }
  }

  /// Posts [body] to the forwarder chatter for [suffix].
  /// Odoo returns `{'status': 'sent'}` — caller must refresh message list.
  Future<void> sendMessage(String suffix, String body) async {
    try {
      await _dio.post(
        '/api/shipment/$suffix/message',
        data: {'body': body},
      );
    } on DioException catch (e) {
      throw e.asApiException;
    }
  }
}
