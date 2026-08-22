// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forwarder_info_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$forwarderInfoHash() => r'd96468a9944d713a2f122fc01d55770000a8d42b';

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

/// Provides the forwarder's branding data for [instanceUrl].
///
/// - Cache valid (< 7 days) → returns cache immediately.
/// - Cache stale or absent → fetches from API and updates cache.
/// - Any API failure → returns stale cache if available, otherwise
///   [ForwarderInfo.fallback] ("BrightFret"). Never throws.
///
/// Copied from [forwarderInfo].
@ProviderFor(forwarderInfo)
const forwarderInfoProvider = ForwarderInfoFamily();

/// Provides the forwarder's branding data for [instanceUrl].
///
/// - Cache valid (< 7 days) → returns cache immediately.
/// - Cache stale or absent → fetches from API and updates cache.
/// - Any API failure → returns stale cache if available, otherwise
///   [ForwarderInfo.fallback] ("BrightFret"). Never throws.
///
/// Copied from [forwarderInfo].
class ForwarderInfoFamily extends Family<AsyncValue<ForwarderInfo>> {
  /// Provides the forwarder's branding data for [instanceUrl].
  ///
  /// - Cache valid (< 7 days) → returns cache immediately.
  /// - Cache stale or absent → fetches from API and updates cache.
  /// - Any API failure → returns stale cache if available, otherwise
  ///   [ForwarderInfo.fallback] ("BrightFret"). Never throws.
  ///
  /// Copied from [forwarderInfo].
  const ForwarderInfoFamily();

  /// Provides the forwarder's branding data for [instanceUrl].
  ///
  /// - Cache valid (< 7 days) → returns cache immediately.
  /// - Cache stale or absent → fetches from API and updates cache.
  /// - Any API failure → returns stale cache if available, otherwise
  ///   [ForwarderInfo.fallback] ("BrightFret"). Never throws.
  ///
  /// Copied from [forwarderInfo].
  ForwarderInfoProvider call(
    String instanceUrl,
  ) {
    return ForwarderInfoProvider(
      instanceUrl,
    );
  }

  @override
  ForwarderInfoProvider getProviderOverride(
    covariant ForwarderInfoProvider provider,
  ) {
    return call(
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
  String? get name => r'forwarderInfoProvider';
}

/// Provides the forwarder's branding data for [instanceUrl].
///
/// - Cache valid (< 7 days) → returns cache immediately.
/// - Cache stale or absent → fetches from API and updates cache.
/// - Any API failure → returns stale cache if available, otherwise
///   [ForwarderInfo.fallback] ("BrightFret"). Never throws.
///
/// Copied from [forwarderInfo].
class ForwarderInfoProvider extends AutoDisposeFutureProvider<ForwarderInfo> {
  /// Provides the forwarder's branding data for [instanceUrl].
  ///
  /// - Cache valid (< 7 days) → returns cache immediately.
  /// - Cache stale or absent → fetches from API and updates cache.
  /// - Any API failure → returns stale cache if available, otherwise
  ///   [ForwarderInfo.fallback] ("BrightFret"). Never throws.
  ///
  /// Copied from [forwarderInfo].
  ForwarderInfoProvider(
    String instanceUrl,
  ) : this._internal(
          (ref) => forwarderInfo(
            ref as ForwarderInfoRef,
            instanceUrl,
          ),
          from: forwarderInfoProvider,
          name: r'forwarderInfoProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$forwarderInfoHash,
          dependencies: ForwarderInfoFamily._dependencies,
          allTransitiveDependencies:
              ForwarderInfoFamily._allTransitiveDependencies,
          instanceUrl: instanceUrl,
        );

  ForwarderInfoProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.instanceUrl,
  }) : super.internal();

  final String instanceUrl;

  @override
  Override overrideWith(
    FutureOr<ForwarderInfo> Function(ForwarderInfoRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ForwarderInfoProvider._internal(
        (ref) => create(ref as ForwarderInfoRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        instanceUrl: instanceUrl,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ForwarderInfo> createElement() {
    return _ForwarderInfoProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ForwarderInfoProvider && other.instanceUrl == instanceUrl;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, instanceUrl.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ForwarderInfoRef on AutoDisposeFutureProviderRef<ForwarderInfo> {
  /// The parameter `instanceUrl` of this provider.
  String get instanceUrl;
}

class _ForwarderInfoProviderElement
    extends AutoDisposeFutureProviderElement<ForwarderInfo>
    with ForwarderInfoRef {
  _ForwarderInfoProviderElement(super.provider);

  @override
  String get instanceUrl => (origin as ForwarderInfoProvider).instanceUrl;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
