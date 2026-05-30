import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/constants/app_enums.dart';
import '../../../core/models/saved_shipment.dart';
import '../../../core/storage/hive_service.dart';

part 'home_provider.g.dart';

/// Display-ready snapshot of a saved shipment for the Home screen cards.
class HomeShipmentItem {
  const HomeShipmentItem({
    required this.trackingCode,
    required this.suffix,
    required this.instanceUrl,
    required this.status,
    required this.transportType,
    required this.lastSeen,
  });

  final String trackingCode;
  final String suffix;
  final String instanceUrl;
  final ShipmentStatus status;
  final TransportType transportType;
  final DateTime lastSeen;
}

/// Returns up to 3 saved shipments sorted by most recently seen.
/// Data source: [HiveService.myShipments].
@riverpod
List<HomeShipmentItem> homeShipments(Ref ref) {
  final all = HiveService.myShipments.values.toList()
    ..sort((a, b) => b.lastSeen.compareTo(a.lastSeen));
  return all.take(3).map(_toItem).toList();
}

HomeShipmentItem _toItem(SavedShipment s) => HomeShipmentItem(
      trackingCode: s.trackingCode,
      suffix: s.suffix,
      instanceUrl: s.instanceUrl,
      status: _parseStatus(s.lastStatus),
      transportType: TransportType.sea,
      lastSeen: s.lastSeen,
    );

ShipmentStatus _parseStatus(String raw) {
  final s = raw.toLowerCase();
  if (s.contains('livré') || s.contains('done') || s.contains('delivered')) {
    return ShipmentStatus.delivered;
  }
  if (s.contains('annulé') ||
      s.contains('cancel') ||
      s.contains('erreur') ||
      s.contains('error')) {
    return ShipmentStatus.error;
  }
  if (s.contains('retard') ||
      s.contains('warning') ||
      s.contains('attention')) {
    return ShipmentStatus.warning;
  }
  if (s.contains('archivé') || s.contains('archived')) {
    return ShipmentStatus.archived;
  }
  return ShipmentStatus.active;
}
