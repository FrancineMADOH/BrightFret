import '../../../core/utils/odoo_datetime.dart';
import '../../tracking/models/public_shipment.dart';
import 'cargo_summary.dart';

/// Full authenticated shipment detail returned by `GET /api/shipment/{suffix}`.
/// Extends [PublicShipment] with pricing, client, and claim fields
/// that are only accessible after phone verification (F2.1).
class FullShipment extends PublicShipment {
  const FullShipment({
    required super.trackingCode,
    required super.status,
    required super.transportType,
    required super.origin,
    required super.destination,
    super.expectedDate,
    required super.events,
    required this.clientName,
    this.supplierRef,
    required this.declaredValue,
    required this.totalAmount,
    required this.paymentStatus,
    required this.totalWeight,
    required this.totalVolume,
    required this.hasActiveClaim,
    this.claimStatus,
    this.cargo,
  });

  final String clientName;
  final String? supplierRef;
  final double declaredValue;
  final double totalAmount;

  /// `'pending'` or `'confirmed'`.
  final String paymentStatus;

  /// Total weight in kg.
  final double totalWeight;

  /// Total volume in m³.
  final double totalVolume;

  final bool hasActiveClaim;
  final String? claimStatus;

  /// Cargo lines for the client-facing shipment summary. Null if no lines exist yet.
  final CargoSummary? cargo;

  /// Parses the JSON response from `GET /api/shipment/{suffix}`.
  factory FullShipment.fromJson(Map<String, dynamic> json) {
    final rawEvents = json['events'] as List<dynamic>? ?? [];
    return FullShipment(
      trackingCode: json['tracking_code'] as String,
      status: json['status'] as String,
      transportType: json['transport_type'] as String,
      origin: json['origin'] as String,
      destination: json['destination'] as String,
      expectedDate: parseOdooDateTime(json['expected_date'] as String?),
      events: rawEvents
          .map((e) => PublicEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      clientName: json['client_name'] as String? ?? '',
      supplierRef: json['supplier_ref'] as String?,
      declaredValue: (json['declared_value'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: json['payment_status'] as String? ?? 'pending',
      totalWeight: (json['total_weight'] as num?)?.toDouble() ?? 0.0,
      totalVolume: (json['total_volume'] as num?)?.toDouble() ?? 0.0,
      hasActiveClaim: json['has_active_claim'] as bool? ?? false,
      claimStatus: json['claim_status'] as String?,
      cargo: json['cargo'] != null
          ? CargoSummary.fromJson(json['cargo'] as Map<String, dynamic>)
          : null,
    );
  }
}
