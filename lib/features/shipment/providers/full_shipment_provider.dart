import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/http/dio_provider.dart';
import '../../../core/models/app_update.dart';
import '../../../core/providers/updates_provider.dart';
import '../../../core/storage/hive_service.dart';
import '../models/full_shipment.dart';
import '../services/shipment_service.dart';

part 'full_shipment_provider.g.dart';

/// Fetches full authenticated shipment detail for [suffix] from [instanceUrl].
///
/// Throws [UnauthorizedException] when the token is expired — [ShipmentDetailScreen]
/// catches this and redirects to S07. All other [ApiException]s surface as
/// [AsyncError] for the UI to display.
///
/// Side-effect: detects claim state changes and writes an [AppUpdate] to Hive
/// when the state transitions (e.g. open → under_review → accepted/refused).
@riverpod
Future<FullShipment> fullShipment(
  Ref ref,
  String suffix,
  String instanceUrl,
) async {
  final dio = ref.read(dioForInstanceProvider(instanceUrl));
  final shipment = await ShipmentService(dio).getFullShipment(suffix);
  await _detectClaimUpdate(ref, shipment);
  return shipment;
}

/// Writes an [AppUpdate] when the claim state for a saved shipment changes.
/// No update on the first observation (`null` → any state) — the user just
/// filed it and already knows. Updates fire on subsequent transitions.
Future<void> _detectClaimUpdate(Ref ref, FullShipment shipment) async {
  try {
    final saved = HiveService.myShipments.get(shipment.trackingCode);
    if (saved == null) return;

    final previous = saved.lastClaimStatus;
    final current = shipment.claimStatus;

    // Always persist the latest observed state.
    if (saved.lastClaimStatus != current) {
      saved.lastClaimStatus = current;
      await saved.save();
    }

    // Only emit an update when transitioning FROM a known state (not first sight).
    if (previous == null || current == null || previous == current) return;

    await HiveService.updates.add(AppUpdate(
      trackingCode: shipment.trackingCode,
      message: 'claim:$current',
      detectedAt: DateTime.now(),
    ));
    ref.invalidate(hasUnreadUpdatesProvider);
  } catch (_) {
    // Never break the main fetch for a side-effect failure.
  }
}
