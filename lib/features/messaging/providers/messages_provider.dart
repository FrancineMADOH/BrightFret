import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/http/api_exception.dart';
import '../../../core/http/dio_provider.dart';
import '../models/shipment_message.dart';
import '../services/messaging_service.dart';

part 'messages_provider.g.dart';

/// Manages the list of messages for [suffix] / [instanceUrl].
/// Supports silent background refresh (poll) and optimistic appends on send.
@riverpod
class MessagesNotifier extends _$MessagesNotifier {
  @override
  Future<List<ShipmentMessage>> build(String suffix, String instanceUrl) async {
    final dio = ref.read(dioForInstanceProvider(instanceUrl));
    return MessagingService(dio).getMessages(suffix);
  }

  /// Silently fetches the latest messages without resetting state to loading.
  /// Used by the 30s poll timer — ignores errors to avoid wiping visible messages.
  Future<void> refresh() async {
    final dio = ref.read(dioForInstanceProvider(instanceUrl));
    try {
      final messages = await MessagingService(dio).getMessages(suffix);
      state = AsyncData(messages);
    } on ApiException {
      // Silently ignore transient poll errors
    }
  }

  /// Sends [body] (and optional [attachment]) then refreshes the message list.
  Future<void> sendMessage(String body, {XFile? attachment}) async {
    final dio = ref.read(dioForInstanceProvider(instanceUrl));
    await MessagingService(dio).sendMessage(suffix, body, attachment: attachment);
    await refresh();
  }
}
