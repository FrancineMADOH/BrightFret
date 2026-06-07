import 'dart:convert';

import '../../../core/models/cached_shipment.dart';
import '../../../core/utils/odoo_datetime.dart';

/// A single transit event on the public shipment timeline.
class PublicEvent {
  const PublicEvent({
    required this.stage,
    this.datetime,
    this.location,
    this.note,
  });

  final String stage;

  /// Null for future steps that have not yet been reached.
  final DateTime? datetime;
  final String? location;
  final String? note;

  factory PublicEvent.fromJson(Map<String, dynamic> json) => PublicEvent(
        stage: json['stage'] as String,
        datetime: parseOdooDateTime(json['datetime'] as String?),
        location: json['location'] as String?,
        note: json['note'] as String?,
      );

  /// Serialises to JSON for [CachedShipment.eventsJson] storage.
  Map<String, dynamic> toJson() => {
        'stage': stage,
        'datetime': datetime?.toIso8601String(),
        'location': location,
        'note': note,
      };
}

/// Public shipment data returned by `GET /api/track/{suffix}`.
/// Contains no auth-gated fields (no photos, no pricing).
class PublicShipment {
  const PublicShipment({
    required this.trackingCode,
    required this.status,
    required this.transportType,
    required this.origin,
    required this.destination,
    this.expectedDate,
    required this.events,
  });

  final String trackingCode;

  /// Text label of the last reached transit stage.
  final String status;

  /// Transport mode: `'air'` or `'sea'`.
  final String transportType;

  final String origin;
  final String destination;
  final DateTime? expectedDate;
  final List<PublicEvent> events;

  /// Parses a JSON response from `GET /api/track/{suffix}`.
  factory PublicShipment.fromJson(Map<String, dynamic> json) {
    final rawEvents = json['events'] as List<dynamic>? ?? [];
    return PublicShipment(
      trackingCode: json['tracking_code'] as String,
      status: json['status'] as String,
      transportType: json['transport_type'] as String,
      origin: json['origin'] as String,
      destination: json['destination'] as String,
      expectedDate: parseOdooDateTime(json['expected_date'] as String?),
      events: rawEvents
          .map((e) => PublicEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Serialises this shipment to a [CachedShipment] for Hive storage.
  CachedShipment toCached(String suffix, String instanceUrl) => CachedShipment(
        suffix: suffix,
        instanceUrl: instanceUrl,
        trackingCode: trackingCode,
        status: status,
        transportType: transportType,
        cachedAt: DateTime.now(),
        eventsJson: jsonEncode(events.map((e) => e.toJson()).toList()),
        origin: origin,
        destination: destination,
      );

  /// Reconstructs a [PublicShipment] from a Hive [CachedShipment].
  factory PublicShipment.fromCached(CachedShipment cached) {
    final rawEvents = jsonDecode(cached.eventsJson) as List<dynamic>;
    return PublicShipment(
      trackingCode: cached.trackingCode,
      status: cached.status,
      transportType: cached.transportType,
      origin: cached.origin ?? '',
      destination: cached.destination ?? '',
      events: rawEvents
          .map((e) => PublicEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Wraps a [PublicShipment] with optional cache metadata.
/// [cachedAt] is non-null only when data is served from a stale Hive cache
/// (offline mode). The timeline screen uses [isFromCache] to show the offline
/// data banner.
class TrackingResult {
  const TrackingResult({required this.shipment, this.cachedAt});

  final PublicShipment shipment;

  /// Timestamp of the cached entry. Non-null only in offline-cache scenarios.
  final DateTime? cachedAt;

  bool get isFromCache => cachedAt != null;
}
