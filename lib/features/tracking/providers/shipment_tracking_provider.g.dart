// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shipment_tracking_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$shipmentTrackingHash() => r'cfa2f828c945ec9f9330f3a49b6feea8fa0b1e39';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provides the public shipment timeline for [suffix] from [instanceUrl].
///
/// - Cache < 5 min → returns cached data immediately (no network call).
/// - Cache stale or absent → fetches from API and updates cache.
/// - Network error + stale cache → returns stale data with [TrackingResult.cachedAt] set.
/// - Network error + no cache → rethrows [NetworkException].
///
/// Use `ref.invalidate(shipmentTrackingProvider(suffix, instanceUrl))` to
/// force a pull-to-refresh.
///
/// Copied from [shipmentTracking].
@ProviderFor(shipmentTracking)
const shipmentTrackingProvider = ShipmentTrackingFamily();

/// Provides the public shipment timeline for [suffix] from [instanceUrl].
///
/// - Cache < 5 min → returns cached data immediately (no network call).
/// - Cache stale or absent → fetches from API and updates cache.
/// - Network error + stale cache → returns stale data with [TrackingResult.cachedAt] set.
/// - Network error + no cache → rethrows [NetworkException].
///
/// Use `ref.invalidate(shipmentTrackingProvider(suffix, instanceUrl))` to
/// force a pull-to-refresh.
///
/// Copied from [shipmentTracking].
class ShipmentTrackingFamily extends Family<AsyncValue<TrackingResult>> {
  /// Provides the public shipment timeline for [suffix] from [instanceUrl].
  ///
  /// - Cache < 5 min → returns cached data immediately (no network call).
  /// - Cache stale or absent → fetches from API and updates cache.
  /// - Network error + stale cache → returns stale data with [TrackingResult.cachedAt] set.
  /// - Network error + no cache → rethrows [NetworkException].
  ///
  /// Use `ref.invalidate(shipmentTrackingProvider(suffix, instanceUrl))` to
  /// force a pull-to-refresh.
  ///
  /// Copied from [shipmentTracking].
  const ShipmentTrackingFamily();

  /// Provides the public shipment timeline for [suffix] from [instanceUrl].
  ///
  /// - Cache < 5 min → returns cached data immediately (no network call).
  /// - Cache stale or absent → fetches from API and updates cache.
  /// - Network error + stale cache → returns stale data with [TrackingResult.cachedAt] set.
  /// - Network error + no cache → rethrows [NetworkException].
  ///
  /// Use `ref.invalidate(shipmentTrackingProvider(suffix, instanceUrl))` to
  /// force a pull-to-refresh.
  ///
  /// Copied from [shipmentTracking].
  ShipmentTrackingProvider call(
    String suffix,
    String instanceUrl,
  ) {
    return ShipmentTrackingProvider(
      suffix,
      instanceUrl,
    );
  }

  @override
  ShipmentTrackingProvider getProviderOverride(
    covariant ShipmentTrackingProvider provider,
  ) {
    return call(
      provider.suffix,
      provider.instanceUrl,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'shipmentTrackingProvider';
}

/// Provides the public shipment timeline for [suffix] from [instanceUrl].
///
/// - Cache < 5 min → returns cached data immediately (no network call).
/// - Cache stale or absent → fetches from API and updates cache.
/// - Network error + stale cache → returns stale data with [TrackingResult.cachedAt] set.
/// - Network error + no cache → rethrows [NetworkException].
///
/// Use `ref.invalidate(shipmentTrackingProvider(suffix, instanceUrl))` to
/// force a pull-to-refresh.
///
/// Copied from [shipmentTracking].
class ShipmentTrackingProvider
    extends AutoDisposeFutureProvider<TrackingResult> {
  /// Provides the public shipment timeline for [suffix] from [instanceUrl].
  ///
  /// - Cache < 5 min → returns cached data immediately (no network call).
  /// - Cache stale or absent → fetches from API and updates cache.
  /// - Network error + stale cache → returns stale data with [TrackingResult.cachedAt] set.
  /// - Network error + no cache → rethrows [NetworkException].
  ///
  /// Use `ref.invalidate(shipmentTrackingProvider(suffix, instanceUrl))` to
  /// force a pull-to-refresh.
  ///
  /// Copied from [shipmentTracking].
  ShipmentTrackingProvider(
    String suffix,
    String instanceUrl,
  ) : this._internal(
          (ref) => shipmentTracking(
            ref as ShipmentTrackingRef,
            suffix,
            instanceUrl,
          ),
          from: shipmentTrackingProvider,
          name: r'shipmentTrackingProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$shipmentTrackingHash,
          dependencies: ShipmentTrackingFamily._dependencies,
          allTransitiveDependencies:
              ShipmentTrackingFamily._allTransitiveDependencies,
          suffix: suffix,
          instanceUrl: instanceUrl,
        );

  ShipmentTrackingProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.suffix,
    required this.instanceUrl,
  }) : super.internal();

  final String suffix;
  final String instanceUrl;

  @override
  Override overrideWith(
    FutureOr<TrackingResult> Function(ShipmentTrackingRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ShipmentTrackingProvider._internal(
        (ref) => create(ref as ShipmentTrackingRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        suffix: suffix,
        instanceUrl: instanceUrl,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<TrackingResult> createElement() {
    return _ShipmentTrackingProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ShipmentTrackingProvider &&
        other.suffix == suffix &&
        other.instanceUrl == instanceUrl;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, suffix.hashCode);
    hash = _SystemHash.combine(hash, instanceUrl.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ShipmentTrackingRef on AutoDisposeFutureProviderRef<TrackingResult> {
  /// The parameter `suffix` of this provider.
  String get suffix;

  /// The parameter `instanceUrl` of this provider.
  String get instanceUrl;
}

class _ShipmentTrackingProviderElement
    extends AutoDisposeFutureProviderElement<TrackingResult>
    with ShipmentTrackingRef {
  _ShipmentTrackingProviderElement(super.provider);

  @override
  String get suffix => (origin as ShipmentTrackingProvider).suffix;
  @override
  String get instanceUrl => (origin as ShipmentTrackingProvider).instanceUrl;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
