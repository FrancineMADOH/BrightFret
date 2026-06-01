// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'claim_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$claimNotifierHash() => r'45995653a404ff5d186f63f5400916ec9bc1736a';

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

abstract class _$ClaimNotifier
    extends BuildlessAutoDisposeAsyncNotifier<String?> {
  late final String suffix;
  late final String instanceUrl;

  FutureOr<String?> build(
    String suffix,
    String instanceUrl,
  );
}

/// Manages claim submission for [suffix] / [instanceUrl].
/// State: `null` = not submitted · `String` = Odoo reference on success.
/// Errors propagate as [ApiException] subtypes for pattern-matching in the UI.
///
/// Copied from [ClaimNotifier].
@ProviderFor(ClaimNotifier)
const claimNotifierProvider = ClaimNotifierFamily();

/// Manages claim submission for [suffix] / [instanceUrl].
/// State: `null` = not submitted · `String` = Odoo reference on success.
/// Errors propagate as [ApiException] subtypes for pattern-matching in the UI.
///
/// Copied from [ClaimNotifier].
class ClaimNotifierFamily extends Family<AsyncValue<String?>> {
  /// Manages claim submission for [suffix] / [instanceUrl].
  /// State: `null` = not submitted · `String` = Odoo reference on success.
  /// Errors propagate as [ApiException] subtypes for pattern-matching in the UI.
  ///
  /// Copied from [ClaimNotifier].
  const ClaimNotifierFamily();

  /// Manages claim submission for [suffix] / [instanceUrl].
  /// State: `null` = not submitted · `String` = Odoo reference on success.
  /// Errors propagate as [ApiException] subtypes for pattern-matching in the UI.
  ///
  /// Copied from [ClaimNotifier].
  ClaimNotifierProvider call(
    String suffix,
    String instanceUrl,
  ) {
    return ClaimNotifierProvider(
      suffix,
      instanceUrl,
    );
  }

  @override
  ClaimNotifierProvider getProviderOverride(
    covariant ClaimNotifierProvider provider,
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
  String? get name => r'claimNotifierProvider';
}

/// Manages claim submission for [suffix] / [instanceUrl].
/// State: `null` = not submitted · `String` = Odoo reference on success.
/// Errors propagate as [ApiException] subtypes for pattern-matching in the UI.
///
/// Copied from [ClaimNotifier].
class ClaimNotifierProvider
    extends AutoDisposeAsyncNotifierProviderImpl<ClaimNotifier, String?> {
  /// Manages claim submission for [suffix] / [instanceUrl].
  /// State: `null` = not submitted · `String` = Odoo reference on success.
  /// Errors propagate as [ApiException] subtypes for pattern-matching in the UI.
  ///
  /// Copied from [ClaimNotifier].
  ClaimNotifierProvider(
    String suffix,
    String instanceUrl,
  ) : this._internal(
          () => ClaimNotifier()
            ..suffix = suffix
            ..instanceUrl = instanceUrl,
          from: claimNotifierProvider,
          name: r'claimNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$claimNotifierHash,
          dependencies: ClaimNotifierFamily._dependencies,
          allTransitiveDependencies:
              ClaimNotifierFamily._allTransitiveDependencies,
          suffix: suffix,
          instanceUrl: instanceUrl,
        );

  ClaimNotifierProvider._internal(
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
  FutureOr<String?> runNotifierBuild(
    covariant ClaimNotifier notifier,
  ) {
    return notifier.build(
      suffix,
      instanceUrl,
    );
  }

  @override
  Override overrideWith(ClaimNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: ClaimNotifierProvider._internal(
        () => create()
          ..suffix = suffix
          ..instanceUrl = instanceUrl,
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
  AutoDisposeAsyncNotifierProviderElement<ClaimNotifier, String?>
      createElement() {
    return _ClaimNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ClaimNotifierProvider &&
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
mixin ClaimNotifierRef on AutoDisposeAsyncNotifierProviderRef<String?> {
  /// The parameter `suffix` of this provider.
  String get suffix;

  /// The parameter `instanceUrl` of this provider.
  String get instanceUrl;
}

class _ClaimNotifierProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ClaimNotifier, String?>
    with ClaimNotifierRef {
  _ClaimNotifierProviderElement(super.provider);

  @override
  String get suffix => (origin as ClaimNotifierProvider).suffix;
  @override
  String get instanceUrl => (origin as ClaimNotifierProvider).instanceUrl;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
