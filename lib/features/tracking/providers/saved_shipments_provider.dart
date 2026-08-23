import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/app_enums.dart';
import '../../../core/http/dio_provider.dart';
import '../../../core/models/app_update.dart';
import '../../../core/models/saved_shipment.dart';
import '../../../core/providers/updates_provider.dart';
import '../../../core/storage/hive_service.dart';
import '../../messaging/models/shipment_message.dart';
import '../../messaging/services/messaging_service.dart';
import '../services/tracking_service.dart';

part 'saved_shipments_provider.g.dart';

/// Maps the public API's fixed status enum (`registered`/`in_transit`/
/// `delivered`/`cancelled`/`unknown`) to a [ShipmentStatus]. Stored as
/// [AppUpdate.message] so S13 can render a localized label at display time
/// instead of the raw API identifier.
ShipmentStatus _apiStatusToShipmentStatus(String raw) => switch (raw) {
      'delivered' => ShipmentStatus.delivered,
      'cancelled' => ShipmentStatus.error,
      _ => ShipmentStatus.active,
    };

/// Manages the list of saved shipments from [HiveService.myShipments].
/// Active shipments are sorted first, then by most recently seen.
@riverpod
class SavedShipments extends _$SavedShipments {
  @override
  List<SavedShipment> build() => _sorted();

  List<SavedShipment> _sorted() {
    final all = HiveService.myShipments.values.toList();
    all.sort((a, b) {
      final aActive = _isActive(a.lastStatus);
      final bActive = _isActive(b.lastStatus);
      if (aActive != bActive) return aActive ? -1 : 1;
      return b.lastSeen.compareTo(a.lastSeen);
    });
    return all;
  }

  /// Removes [trackingCode] from Hive and updates state.
  Future<void> remove(String trackingCode) async {
    await HiveService.myShipments.delete(trackingCode);
    state = _sorted();
  }

  /// Calls `GET /api/track/{suffix}` for each saved shipment in batches of 5.
  /// Silently ignores network errors — cached data is preserved as-is.
  /// Updates [SavedShipment.lastStatus] and [lastSeen] in Hive when status changes.
  Future<void> refreshAll() async {
    final entries = List<SavedShipment>.from(state);
    if (entries.isEmpty) return;

    for (var i = 0; i < entries.length; i += 5) {
      final batch = entries.sublist(i, min(i + 5, entries.length));
      await Future.wait(batch.map(_refreshOne));
    }

    try {
      state = _sorted();
    } catch (_) {}
  }

  Future<void> _refreshOne(SavedShipment shipment) async {
    try {
      final dio = ref.read(dioForInstanceProvider(shipment.instanceUrl));
      final result = await TrackingService(dio).getPublicShipment(shipment.suffix);
      var dirty = false;

      if (result.status != shipment.lastStatus) {
        shipment.lastStatus = result.status;
        shipment.lastSeen = DateTime.now();
        await HiveService.updates.add(AppUpdate(
          trackingCode: shipment.trackingCode,
          message: _apiStatusToShipmentStatus(result.status).name,
          detectedAt: DateTime.now(),
        ));
        dirty = true;
      }

      final newCount = result.events.length;
      final knownCount = shipment.lastEventCount;
      if (knownCount == null) {
        // First refresh after field introduction — initialise silently.
        shipment.lastEventCount = newCount;
        dirty = true;
      } else if (newCount > knownCount) {
        for (final event in result.events.skip(knownCount)) {
          await HiveService.updates.add(AppUpdate(
            trackingCode: shipment.trackingCode,
            message: 'transit:${event.stage}',
            detectedAt: DateTime.now(),
          ));
        }
        shipment.lastEventCount = newCount;
        dirty = true;
      }

      if (dirty) {
        await shipment.save();
        ref.invalidate(hasUnreadUpdatesProvider);
      }
    } catch (_) {
      // Offline or API error — keep existing cached data silently.
    }

    await _checkForwarderMessages(shipment);
  }

  /// Checks for new forwarder messages on authenticated shipments.
  /// Creates an [AppUpdate] when a message newer than the last-detected one
  /// is found. Stores the latest message ID in Hive prefs to avoid duplicates.
  /// First call initialises silently (no notification for pre-existing messages).
  Future<void> _checkForwarderMessages(SavedShipment shipment) async {
    try {
      final tokenKey = '${shipment.instanceUrl}:${shipment.suffix}';
      final stored = HiveService.tokens.get(tokenKey);
      if (stored == null || stored.isExpired) return;

      final dio = ref.read(dioForInstanceProvider(shipment.instanceUrl));
      final messages = await MessagingService(dio).getMessages(shipment.suffix);

      ShipmentMessage? latest;
      for (final m in messages.reversed) {
        if (!m.isFromClient) {
          latest = m;
          break;
        }
      }
      if (latest == null) return;

      final prefKey = _forwarderMsgKey(shipment.suffix);
      final lastId = HiveService.prefs.get(prefKey, defaultValue: 0) as int;

      if (lastId == 0) {
        // First time — initialise silently, no notification for pre-existing messages.
        await HiveService.prefs.put(prefKey, latest.id);
        return;
      }

      if (latest.id > lastId) {
        await HiveService.updates.add(AppUpdate(
          trackingCode: shipment.trackingCode,
          message: 'forwarder_message',
          detectedAt: DateTime.now(),
        ));
        await HiveService.prefs.put(prefKey, latest.id);
        ref.invalidate(hasUnreadUpdatesProvider);
      }
    } catch (_) {
      // Best-effort — ignore failures silently.
    }
  }

  static String _forwarderMsgKey(String suffix) => 'last_forwarder_msg_$suffix';

  static bool _isActive(String status) {
    final s = status.toLowerCase();
    return !s.contains('done') &&
        !s.contains('delivered') &&
        !s.contains('livré') &&
        !s.contains('cancelled') &&
        !s.contains('annulé') &&
        !s.contains('archived') &&
        !s.contains('archivé');
  }
}
