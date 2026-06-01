/// Full claim data returned by `GET /api/shipment/{suffix}/claim`.
class ClaimDetail {
  const ClaimDetail({
    required this.reference,
    required this.claimType,
    required this.description,
    required this.state,
    this.openDate,
    this.closeDate,
    this.resolutionNote,
    this.creditAmount,
  });

  /// Odoo sequence reference, e.g. `CLAIM/2026/0001`.
  final String reference;

  /// `'lost'` | `'damaged'` | `'delayed'`.
  final String claimType;

  final String description;

  /// `'open'` | `'under_review'` | `'accepted'` | `'rejected'` | `'cancelled'`.
  final String state;

  final DateTime? openDate;
  final DateTime? closeDate;

  /// Populated by the forwarder when accepted or rejected.
  final String? resolutionNote;

  /// Non-null only when [state] is `'accepted'`.
  final double? creditAmount;

  factory ClaimDetail.fromJson(Map<String, dynamic> json) {
    return ClaimDetail(
      reference: json['reference'] as String,
      claimType: json['claim_type'] as String? ?? '',
      description: json['description'] as String? ?? '',
      state: json['state'] as String? ?? 'open',
      openDate: json['open_date'] != null
          ? DateTime.tryParse(json['open_date'] as String)
          : null,
      closeDate: json['close_date'] != null
          ? DateTime.tryParse(json['close_date'] as String)
          : null,
      resolutionNote: json['resolution_note'] as String?,
      creditAmount: (json['credit_amount'] as num?)?.toDouble(),
    );
  }
}
