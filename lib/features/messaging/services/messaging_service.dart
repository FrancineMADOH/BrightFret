import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/http/api_exception.dart';
import '../models/shipment_message.dart';

/// Service for the messaging endpoints:
/// - `GET /api/shipment/{suffix}/messages`
/// - `POST /api/shipment/{suffix}/message`
class MessagingService {
  const MessagingService(this._dio);

  final Dio _dio;

  static const _maxBytes = 5 * 1024 * 1024; // 5 MB

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

  /// Posts [body] (and optional [attachment]) to the forwarder chatter.
  /// Throws [AttachmentTooLargeException] if the file exceeds 5 MB.
  Future<void> sendMessage(
    String suffix,
    String body, {
    XFile? attachment,
  }) async {
    try {
      final Map<String, dynamic> payload = {'body': body};
      if (attachment != null) {
        final bytes = await attachment.readAsBytes();
        if (bytes.length > _maxBytes) {
          throw const AttachmentTooLargeException();
        }
        payload['attachments'] = [
          {
            'name': attachment.name,
            'data': base64Encode(bytes),
            'mimetype': attachment.mimeType ?? 'image/jpeg',
          }
        ];
      }
      await _dio.post('/api/shipment/$suffix/message', data: payload);
    } on AttachmentTooLargeException {
      rethrow;
    } on DioException catch (e) {
      throw e.asApiException;
    }
  }
}

/// Thrown when the selected file exceeds the 5 MB limit.
class AttachmentTooLargeException implements Exception {
  const AttachmentTooLargeException();
}
