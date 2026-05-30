import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/models/saved_shipment.dart';
import '../../../core/storage/hive_service.dart';

part 'saved_shipment_toggle_provider.g.dart';

/// Tracks whether the shipment with [trackingCode] is saved in
/// [HiveService.myShipments], and exposes a [toggle] mutation.
@riverpod
class SavedShipmentToggle extends _$SavedShipmentToggle {
  @override
  bool build(String trackingCode) {
    return HiveService.myShipments.containsKey(trackingCode);
  }

  /// Adds or removes the shipment from the saved list.
  Future<void> toggle({
    required String suffix,
    required String instanceUrl,
    required String status,
  }) async {
    if (state) {
      await HiveService.myShipments.delete(trackingCode);
    } else {
      await HiveService.myShipments.put(
        trackingCode,
        SavedShipment(
          trackingCode: trackingCode,
          suffix: suffix,
          instanceUrl: instanceUrl,
          lastStatus: status,
          lastSeen: DateTime.now(),
        ),
      );
    }
    state = !state;
  }
}
