import 'package:hive_flutter/hive_flutter.dart';

part 'saved_shipment.g.dart';

/// A shipment the user has saved locally in "Mes colis".
/// Keyed by [trackingCode] in the [myShipmentsBox].
@HiveType(typeId: 1)
class SavedShipment extends HiveObject {
  SavedShipment({
    required this.trackingCode,
    required this.suffix,
    required this.instanceUrl,
    required this.lastStatus,
    required this.lastSeen,
    this.isAuthenticated = false,
  });

  /// Full tracking code, e.g. KMG-2026-A7X9K2.
  @HiveField(0)
  String trackingCode;

  @HiveField(1)
  String suffix;

  @HiveField(2)
  String instanceUrl;

  @HiveField(3)
  String lastStatus;

  @HiveField(4)
  DateTime lastSeen;

  /// Whether the user has authenticated for this shipment.
  @HiveField(5)
  bool isAuthenticated;

  /// Last known claim state (`'open'` | `'under_review'` | `'accepted'` | `'refused'`).
  /// Null if no claim has been observed yet on this device.
  @HiveField(6)
  String? lastClaimStatus;
}
