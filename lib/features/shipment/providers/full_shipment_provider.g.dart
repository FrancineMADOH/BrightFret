// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'full_shipment_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fullShipmentHash() => r'd4060675fb4d57fbe1df3716687bb566173acee1';

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

/// Fetches full authenticated shipment detail for [suffix] from [instanceUrl].
///
/// Throws [UnauthorizedException] when the token is expired — [ShipmentDetailScreen]
/// catches this and redirects to S07. All other [ApiException]s surface as
/// [AsyncError] for the UI to display.
///
/// Copied from [fullShipment].
@ProviderFor(fullShipment)
const fullShipmentProvider = FullShipmentFamily();

/// Fetches full authenticated shipment detail for [suffix] from [instanceUrl].
///
/// Throws [UnauthorizedException] when the token is expired — [ShipmentDetailScreen]
/// catches this and redirects to S07. All other [ApiException]s surface as
/// [AsyncError] for the UI to display.
///
/// Copied from [fullShipment].
class FullShipmentFamily extends Family<AsyncValue<FullShipment>> {
  /// Fetches full authenticated shipment detail for [suffix] from [instanceUrl].
  ///
  /// Throws [UnauthorizedException] when the token is expired — [ShipmentDetailScreen]
  /// catches this and redirects to S07. All other [ApiException]s surface as
  /// [AsyncError] for the UI to display.
  ///
  /// Copied from [fullShipment].
  const FullShipmentFamily();

  /// Fetches full authenticated shipment detail for [suffix] from [instanceUrl].
  ///
  /// Throws [UnauthorizedException] when the token is expired — [ShipmentDetailScreen]
  /// catches this and redirects to S07. All other [ApiException]s surface as
  /// [AsyncError] for the UI to display.
  ///
  /// Copied from [fullShipment].
  FullShipmentProvider call(
    String suffix,
    String instanceUrl,
  ) {
    return FullShipmentProvider(
      suffix,
      instanceUrl,
    );
  }

  @override
  FullShipmentProvider getProviderOverride(
    covariant FullShipmentProvider provider,
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
  String? get name => r'fullShipmentProvider';
}

/// Fetches full authenticated shipment detail for [suffix] from [instanceUrl].
///
/// Throws [UnauthorizedException] when the token is expired — [ShipmentDetailScreen]
/// catches this and redirects to S07. All other [ApiException]s surface as
/// [AsyncError] for the UI to display.
///
/// Copied from [fullShipment].
class FullShipmentProvider extends AutoDisposeFutureProvider<FullShipment> {
  /// Fetches full authenticated shipment detail for [suffix] from [instanceUrl].
  ///
  /// Throws [UnauthorizedException] when the token is expired — [ShipmentDetailScreen]
  /// catches this and redirects to S07. All other [ApiException]s surface as
  /// [AsyncError] for the UI to display.
  ///
  /// Copied from [fullShipment].
  FullShipmentProvider(
    String suffix,
    String instanceUrl,
  ) : this._internal(
          (ref) => fullShipment(
            ref as FullShipmentRef,
            suffix,
            instanceUrl,
          ),
          from: fullShipmentProvider,
          name: r'fullShipmentProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$fullShipmentHash,
          dependencies: FullShipmentFamily._dependencies,
          allTransitiveDependencies:
              FullShipmentFamily._allTransitiveDependencies,
          suffix: suffix,
          instanceUrl: instanceUrl,
        );

  FullShipmentProvider._internal(
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
    FutureOr<FullShipment> Function(FullShipmentRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FullShipmentProvider._internal(
        (ref) => create(ref as FullShipmentRef),
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
  AutoDisposeFutureProviderElement<FullShipment> createElement() {
    return _FullShipmentProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FullShipmentProvider &&
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
mixin FullShipmentRef on AutoDisposeFutureProviderRef<FullShipment> {
  /// The parameter `suffix` of this provider.
  String get suffix;

  /// The parameter `instanceUrl` of this provider.
  String get instanceUrl;
}

class _FullShipmentProviderElement
    extends AutoDisposeFutureProviderElement<FullShipment>
    with FullShipmentRef {
  _FullShipmentProviderElement(super.provider);

  @override
  String get suffix => (origin as FullShipmentProvider).suffix;
  @override
  String get instanceUrl => (origin as FullShipmentProvider).instanceUrl;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
