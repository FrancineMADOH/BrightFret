import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/http/api_exception.dart';
import '../../../core/http/dio_provider.dart';
import '../../../core/storage/hive_service.dart';
import '../models/public_shipment.dart';
import '../services/tracking_service.dart';

part 'shipment_tracking_provider.g.dart';

const Duration _kCacheTtl = Duration(minutes: 5);

bool _isCacheStale(DateTime cachedAt) =>
    DateTime.now().difference(cachedAt) > _kCacheTtl;

/// Provides the public shipment timeline for [suffix] from [instanceUrl].
///
/// - Cache < 5 min → returns cached data immediately (no network call).
/// - Cache stale or absent → fetches from API and updates cache.
/// - Network error + stale cache → returns stale data with [TrackingResult.cachedAt] set.
/// - Network error + no cache → rethrows [NetworkException].
///
/// Use `ref.invalidate(shipmentTrackingProvider(suffix, instanceUrl))` to
/// force a pull-to-refresh.
@riverpod
Future<TrackingResult> shipmentTracking(
  Ref ref,
  String suffix,
  String instanceUrl,
) async {
  final cacheKey = '$instanceUrl:$suffix';
  final cached = HiveService.shipments.get(cacheKey);

  if (cached != null && !_isCacheStale(cached.cachedAt)) {
    return TrackingResult(shipment: PublicShipment.fromCached(cached));
  }

  try {
    final dio = ref.read(dioForInstanceProvider(instanceUrl));
    final shipment = await TrackingService(dio).getPublicShipment(suffix);
    await HiveService.shipments.put(
      cacheKey,
      shipment.toCached(suffix, instanceUrl),
    );
    return TrackingResult(shipment: shipment);
  } on ApiException catch (e) {
    if (e is NetworkException && cached != null) {
      return TrackingResult(
        shipment: PublicShipment.fromCached(cached),
        cachedAt: cached.cachedAt,
      );
    }
    rethrow;
  }
}
