import '../../../core/models/cached_forwarder_info.dart';

/// Forwarder branding returned by `GET /api/forwarder/info`.
class ForwarderInfo {
  const ForwarderInfo({
    required this.name,
    this.logoUrl,
    this.primaryColor,
    this.contactPhone,
    this.canCreateClaims = true,
  });

  final String name;
  final String? logoUrl;

  /// Hex colour string, e.g. `'#2E7D32'`. Used for dynamic theming (F5.4).
  final String? primaryColor;
  final String? contactPhone;

  /// `true` when the forwarder's plan allows claim creation (Pro+).
  /// Defaults to `true` so older API responses without this field remain permissive.
  final bool canCreateClaims;

  /// Safe fallback used when the API is unreachable and no cache exists.
  static const ForwarderInfo fallback = ForwarderInfo(name: 'BrightFret');

  factory ForwarderInfo.fromJson(
    Map<String, dynamic> json, {
    String? baseUrl,
  }) =>
      ForwarderInfo(
        name: json['name'] as String,
        logoUrl: _absolute(json['logo_url'] as String?, baseUrl),
        primaryColor: json['primary_color'] as String?,
        contactPhone: json['contact_phone'] as String?,
        canCreateClaims: json['can_create_claims'] as bool? ?? true,
      );

  /// Serialises to a [CachedForwarderInfo] for 7-day Hive storage.
  CachedForwarderInfo toCached(String instanceUrl) => CachedForwarderInfo(
        instanceUrl: instanceUrl,
        name: name,
        logoUrl: logoUrl,
        primaryColor: primaryColor,
        contactPhone: contactPhone,
        canCreateClaims: canCreateClaims,
        cachedAt: DateTime.now(),
      );

  /// Reconstructs a [ForwarderInfo] from a Hive [CachedForwarderInfo].
  /// Normalises stale relative [logoUrl] entries using the stored [instanceUrl].
  factory ForwarderInfo.fromCached(CachedForwarderInfo cached) => ForwarderInfo(
        name: cached.name,
        logoUrl: _absolute(cached.logoUrl, cached.instanceUrl),
        primaryColor: cached.primaryColor,
        contactPhone: cached.contactPhone,
        canCreateClaims: cached.canCreateClaims ?? true,
      );

  /// Makes [url] absolute using [base]. Returns [url] unchanged if already
  /// absolute or if either argument is null.
  static String? _absolute(String? url, String? base) {
    if (url == null || base == null || !url.startsWith('/')) return url;
    return '${base.replaceAll(RegExp(r'/$'), '')}$url';
  }
}
