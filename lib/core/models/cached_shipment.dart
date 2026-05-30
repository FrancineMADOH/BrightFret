import 'package:hive_flutter/hive_flutter.dart';

part 'cached_shipment.g.dart';

/// Cached public shipment data for offline display.
/// [eventsJson] stores a JSON-encoded list of events to avoid nested HiveObjects.
@HiveType(typeId: 0)
class CachedShipment extends HiveObject {
  CachedShipment({
    required this.suffix,
    required this.instanceUrl,
    required this.trackingCode,
    required this.status,
    required this.transportType,
    required this.cachedAt,
    required this.eventsJson,
    this.origin,
    this.destination,
  });

  @HiveField(0)
  String suffix;

  @HiveField(1)
  String instanceUrl;

  @HiveField(2)
  String trackingCode;

  /// Last reached stage label.
  @HiveField(3)
  String status;

  /// Transport mode: 'air' or 'sea'.
  @HiveField(4)
  String transportType;

  @HiveField(5)
  DateTime cachedAt;

  /// JSON-encoded list of transit events.
  @HiveField(6)
  String eventsJson;

  /// Origin city. Nullable for backward-compat with pre-F1.6 cached records.
  @HiveField(7)
  String? origin;

  /// Destination city. Nullable for backward-compat with pre-F1.6 cached records.
  @HiveField(8)
  String? destination;
}
