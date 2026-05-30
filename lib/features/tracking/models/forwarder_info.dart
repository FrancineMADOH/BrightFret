import '../../../core/models/cached_forwarder_info.dart';

/// Forwarder branding returned by `GET /api/forwarder/info`.
class ForwarderInfo {
  const ForwarderInfo({
    required this.name,
    this.logoUrl,
    this.primaryColor,
    this.contactPhone,
  });

  final String name;
  final String? logoUrl;

  /// Hex colour string, e.g. `'#2E7D32'`. Used for dynamic theming (F5.4).
  final String? primaryColor;
  final String? contactPhone;

  /// Safe fallback used when the API is unreachable and no cache exists.
  static const ForwarderInfo fallback = ForwarderInfo(name: 'BrightFret');

  factory ForwarderInfo.fromJson(Map<String, dynamic> json) => ForwarderInfo(
        name: json['name'] as String,
        logoUrl: json['logo_url'] as String?,
        primaryColor: json['primary_color'] as String?,
        contactPhone: json['contact_phone'] as String?,
      );

  /// Serialises to a [CachedForwarderInfo] for 7-day Hive storage.
  CachedForwarderInfo toCached(String instanceUrl) => CachedForwarderInfo(
        instanceUrl: instanceUrl,
        name: name,
        logoUrl: logoUrl,
        primaryColor: primaryColor,
        contactPhone: contactPhone,
        cachedAt: DateTime.now(),
      );

  /// Reconstructs a [ForwarderInfo] from a Hive [CachedForwarderInfo].
  factory ForwarderInfo.fromCached(CachedForwarderInfo cached) => ForwarderInfo(
        name: cached.name,
        logoUrl: cached.logoUrl,
        primaryColor: cached.primaryColor,
        contactPhone: cached.contactPhone,
      );
}
