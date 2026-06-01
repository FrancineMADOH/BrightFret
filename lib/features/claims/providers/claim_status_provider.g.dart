// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'claim_status_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$claimStatusHash() => r'85c3a8e4fcbab4527cbdd911ffd65bf7ad12bce8';

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

/// Fetches the latest claim for [suffix] / [instanceUrl].
/// Throws [NotFoundException] when no claim exists for this shipment.
///
/// Copied from [claimStatus].
@ProviderFor(claimStatus)
const claimStatusProvider = ClaimStatusFamily();

/// Fetches the latest claim for [suffix] / [instanceUrl].
/// Throws [NotFoundException] when no claim exists for this shipment.
///
/// Copied from [claimStatus].
class ClaimStatusFamily extends Family<AsyncValue<ClaimDetail>> {
  /// Fetches the latest claim for [suffix] / [instanceUrl].
  /// Throws [NotFoundException] when no claim exists for this shipment.
  ///
  /// Copied from [claimStatus].
  const ClaimStatusFamily();

  /// Fetches the latest claim for [suffix] / [instanceUrl].
  /// Throws [NotFoundException] when no claim exists for this shipment.
  ///
  /// Copied from [claimStatus].
  ClaimStatusProvider call(
    String suffix,
    String instanceUrl,
  ) {
    return ClaimStatusProvider(
      suffix,
      instanceUrl,
    );
  }

  @override
  ClaimStatusProvider getProviderOverride(
    covariant ClaimStatusProvider provider,
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
  String? get name => r'claimStatusProvider';
}

/// Fetches the latest claim for [suffix] / [instanceUrl].
/// Throws [NotFoundException] when no claim exists for this shipment.
///
/// Copied from [claimStatus].
class ClaimStatusProvider extends AutoDisposeFutureProvider<ClaimDetail> {
  /// Fetches the latest claim for [suffix] / [instanceUrl].
  /// Throws [NotFoundException] when no claim exists for this shipment.
  ///
  /// Copied from [claimStatus].
  ClaimStatusProvider(
    String suffix,
    String instanceUrl,
  ) : this._internal(
          (ref) => claimStatus(
            ref as ClaimStatusRef,
            suffix,
            instanceUrl,
          ),
          from: claimStatusProvider,
          name: r'claimStatusProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$claimStatusHash,
          dependencies: ClaimStatusFamily._dependencies,
          allTransitiveDependencies:
              ClaimStatusFamily._allTransitiveDependencies,
          suffix: suffix,
          instanceUrl: instanceUrl,
        );

  ClaimStatusProvider._internal(
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
    FutureOr<ClaimDetail> Function(ClaimStatusRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ClaimStatusProvider._internal(
        (ref) => create(ref as ClaimStatusRef),
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
  AutoDisposeFutureProviderElement<ClaimDetail> createElement() {
    return _ClaimStatusProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ClaimStatusProvider &&
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
mixin ClaimStatusRef on AutoDisposeFutureProviderRef<ClaimDetail> {
  /// The parameter `suffix` of this provider.
  String get suffix;

  /// The parameter `instanceUrl` of this provider.
  String get instanceUrl;
}

class _ClaimStatusProviderElement
    extends AutoDisposeFutureProviderElement<ClaimDetail> with ClaimStatusRef {
  _ClaimStatusProviderElement(super.provider);

  @override
  String get suffix => (origin as ClaimStatusProvider).suffix;
  @override
  String get instanceUrl => (origin as ClaimStatusProvider).instanceUrl;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
