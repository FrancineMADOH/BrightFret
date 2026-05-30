import 'package:hive_flutter/hive_flutter.dart';

part 'cached_forwarder_info.g.dart';

/// Forwarder branding data cached for 7 days from GET /api/forwarder/info.
/// Keyed by [instanceUrl] in the [forwarderInfoBox].
@HiveType(typeId: 3)
class CachedForwarderInfo extends HiveObject {
  CachedForwarderInfo({
    required this.instanceUrl,
    required this.name,
    this.logoUrl,
    this.primaryColor,
    this.contactPhone,
    required this.cachedAt,
  });

  @HiveField(0)
  String instanceUrl;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? logoUrl;

  /// Hex colour string, e.g. '#2E7D32'. Applied to shipment screen CTAs (F5.4).
  @HiveField(3)
  String? primaryColor;

  @HiveField(4)
  String? contactPhone;

  @HiveField(5)
  DateTime cachedAt;

  static const Duration _ttl = Duration(days: 7);

  /// Returns true if this entry is older than 7 days.
  bool get isExpired => DateTime.now().difference(cachedAt) > _ttl;
}
