/// One cargo line on a shipment, from `freight.shipment.line`.
/// Unit price is per kg (billing_type='weight'), per m³ (billing_type='volume'),
/// or per piece (billing_type='unit').
/// Total = quantity × weight_or_volume × price  (weight/volume)
///       = quantity × price                      (unit)
class CargoLine {
  const CargoLine({
    required this.name,
    required this.billingType,
    required this.quantity,
    required this.weight,
    required this.volume,
    required this.price,
    required this.totalPrice,
  });

  final String name;

  /// `'weight'`, `'volume'`, or `'unit'`.
  final String billingType;

  /// Number of packages / units.
  final double quantity;

  /// Weight per unit in kg.
  final double weight;

  /// Volume per unit in m³.
  final double volume;

  /// Unit price per kg, per m³, or per piece (from the pricing grid).
  final double price;

  /// Total for this line (computed by Odoo, not re-derived here).
  final double totalPrice;

  bool get isByWeight => billingType == 'weight';
  bool get isByUnit   => billingType == 'unit';

  /// Billed measure for this line:
  /// weight → qty × weight (kg), volume → qty × volume (m³), unit → qty (pcs).
  double get totalMeasure {
    if (isByWeight) return quantity * weight;
    if (isByUnit)   return quantity;
    return quantity * volume;
  }

  factory CargoLine.fromJson(Map<String, dynamic> json) => CargoLine(
        name: json['name'] as String? ?? '',
        billingType: json['billing_type'] as String? ?? 'weight',
        quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
        weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
        volume: (json['volume'] as num?)?.toDouble() ?? 0.0,
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      );
}

/// Cargo summary for a shipment, returned by `GET /api/shipment/{suffix}` → `cargo` field.
/// The mobile app renders this as a client-facing receipt — not the accounting invoice.
class CargoSummary {
  const CargoSummary({
    required this.lines,
    required this.totalWeight,
    required this.totalVolume,
    required this.totalGoodsAmount,
    required this.currency,
  });

  final List<CargoLine> lines;

  /// Sum of all line weights (kg).
  final double totalWeight;

  /// Sum of all line volumes (m³).
  final double totalVolume;

  /// Sum of all line total prices.
  final double totalGoodsAmount;

  final String currency;

  factory CargoSummary.fromJson(Map<String, dynamic> json) {
    final rawLines = json['lines'] as List<dynamic>? ?? [];
    return CargoSummary(
      lines: rawLines
          .map((l) => CargoLine.fromJson(l as Map<String, dynamic>))
          .toList(),
      totalWeight: (json['total_weight'] as num?)?.toDouble() ?? 0.0,
      totalVolume: (json['total_volume'] as num?)?.toDouble() ?? 0.0,
      totalGoodsAmount: (json['total_goods_amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
    );
  }
}
