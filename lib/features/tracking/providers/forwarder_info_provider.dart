import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/http/api_exception.dart';
import '../../../core/http/dio_provider.dart';
import '../../../core/storage/hive_service.dart';
import '../models/forwarder_info.dart';
import '../services/forwarder_service.dart';

part 'forwarder_info_provider.g.dart';

/// Provides the forwarder's branding data for [instanceUrl].
///
/// - Cache valid (< 7 days) → returns cache immediately.
/// - Cache stale or absent → fetches from API and updates cache.
/// - Any API failure → returns stale cache if available, otherwise
///   [ForwarderInfo.fallback] ("BrightFret"). Never throws.
@riverpod
Future<ForwarderInfo> forwarderInfo(Ref ref, String instanceUrl) async {
  final cached = HiveService.forwarderInfo.get(instanceUrl);
  if (cached != null && !cached.isExpired) {
    return ForwarderInfo.fromCached(cached);
  }

  try {
    final dio = ref.read(dioForInstanceProvider(instanceUrl));
    final info = await ForwarderService(dio).getForwarderInfo();
    await HiveService.forwarderInfo.put(instanceUrl, info.toCached(instanceUrl));
    return info;
  } on ApiException catch (_) {
    if (cached != null) return ForwarderInfo.fromCached(cached);
    return ForwarderInfo.fallback;
  }
}
