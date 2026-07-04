// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'claims_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$claimsListHash() => r'f4aab7ee038103c17b1f02871337175ad2dc42cc';

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

/// Fetches all claims for [suffix] / [instanceUrl], newest first.
///
/// Copied from [claimsList].
@ProviderFor(claimsList)
const claimsListProvider = ClaimsListFamily();

/// Fetches all claims for [suffix] / [instanceUrl], newest first.
///
/// Copied from [claimsList].
class ClaimsListFamily extends Family<AsyncValue<List<ClaimDetail>>> {
  /// Fetches all claims for [suffix] / [instanceUrl], newest first.
  ///
  /// Copied from [claimsList].
  const ClaimsListFamily();

  /// Fetches all claims for [suffix] / [instanceUrl], newest first.
  ///
  /// Copied from [claimsList].
  ClaimsListProvider call(
    String suffix,
    String instanceUrl,
  ) {
    return ClaimsListProvider(
      suffix,
      instanceUrl,
    );
  }

  @override
  ClaimsListProvider getProviderOverride(
    covariant ClaimsListProvider provider,
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
  String? get name => r'claimsListProvider';
}

/// Fetches all claims for [suffix] / [instanceUrl], newest first.
///
/// Copied from [claimsList].
class ClaimsListProvider extends AutoDisposeFutureProvider<List<ClaimDetail>> {
  /// Fetches all claims for [suffix] / [instanceUrl], newest first.
  ///
  /// Copied from [claimsList].
  ClaimsListProvider(
    String suffix,
    String instanceUrl,
  ) : this._internal(
          (ref) => claimsList(
            ref as ClaimsListRef,
            suffix,
            instanceUrl,
          ),
          from: claimsListProvider,
          name: r'claimsListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$claimsListHash,
          dependencies: ClaimsListFamily._dependencies,
          allTransitiveDependencies:
              ClaimsListFamily._allTransitiveDependencies,
          suffix: suffix,
          instanceUrl: instanceUrl,
        );

  ClaimsListProvider._internal(
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
    FutureOr<List<ClaimDetail>> Function(ClaimsListRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ClaimsListProvider._internal(
        (ref) => create(ref as ClaimsListRef),
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
  AutoDisposeFutureProviderElement<List<ClaimDetail>> createElement() {
    return _ClaimsListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ClaimsListProvider &&
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
mixin ClaimsListRef on AutoDisposeFutureProviderRef<List<ClaimDetail>> {
  /// The parameter `suffix` of this provider.
  String get suffix;

  /// The parameter `instanceUrl` of this provider.
  String get instanceUrl;
}

class _ClaimsListProviderElement
    extends AutoDisposeFutureProviderElement<List<ClaimDetail>>
    with ClaimsListRef {
  _ClaimsListProviderElement(super.provider);

  @override
  String get suffix => (origin as ClaimsListProvider).suffix;
  @override
  String get instanceUrl => (origin as ClaimsListProvider).instanceUrl;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
