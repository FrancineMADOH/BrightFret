import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/http/dio_provider.dart';
import '../models/full_shipment.dart';
import '../services/shipment_service.dart';

part 'full_shipment_provider.g.dart';

/// Fetches full authenticated shipment detail for [suffix] from [instanceUrl].
///
/// Throws [UnauthorizedException] when the token is expired — [ShipmentDetailScreen]
/// catches this and redirects to S07. All other [ApiException]s surface as
/// [AsyncError] for the UI to display.
@riverpod
Future<FullShipment> fullShipment(
  Ref ref,
  String suffix,
  String instanceUrl,
) async {
  final dio = ref.read(dioForInstanceProvider(instanceUrl));
  return ShipmentService(dio).getFullShipment(suffix);
}
