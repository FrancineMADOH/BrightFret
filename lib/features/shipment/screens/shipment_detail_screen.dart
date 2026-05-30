import 'package:flutter/material.dart';

/// Stub for ShipmentDetailScreen — S08.
/// Full implementation in F2.2: full shipment detail after auth (pricing, docs, messaging CTA).
class ShipmentDetailScreen extends StatelessWidget {
  const ShipmentDetailScreen({super.key, required this.suffix});

  final String suffix;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('ShipmentDetailScreen — S08\nsuffix: $suffix'),
      ),
    );
  }
}
