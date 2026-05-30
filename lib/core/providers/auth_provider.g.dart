// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$hasValidTokenHash() => r'110eb4267e36379ca845e824661f50b315405577';

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

/// Returns true if a valid (non-expired) token exists for [suffix].
/// Reads from the Hive tokens box via [TokenStorage].
///
/// Copied from [hasValidToken].
@ProviderFor(hasValidToken)
const hasValidTokenProvider = HasValidTokenFamily();

/// Returns true if a valid (non-expired) token exists for [suffix].
/// Reads from the Hive tokens box via [TokenStorage].
///
/// Copied from [hasValidToken].
class HasValidTokenFamily extends Family<bool> {
  /// Returns true if a valid (non-expired) token exists for [suffix].
  /// Reads from the Hive tokens box via [TokenStorage].
  ///
  /// Copied from [hasValidToken].
  const HasValidTokenFamily();

  /// Returns true if a valid (non-expired) token exists for [suffix].
  /// Reads from the Hive tokens box via [TokenStorage].
  ///
  /// Copied from [hasValidToken].
  HasValidTokenProvider call(
    String suffix,
  ) {
    return HasValidTokenProvider(
      suffix,
    );
  }

  @override
  HasValidTokenProvider getProviderOverride(
    covariant HasValidTokenProvider provider,
  ) {
    return call(
      provider.suffix,
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
  String? get name => r'hasValidTokenProvider';
}

/// Returns true if a valid (non-expired) token exists for [suffix].
/// Reads from the Hive tokens box via [TokenStorage].
///
/// Copied from [hasValidToken].
class HasValidTokenProvider extends AutoDisposeProvider<bool> {
  /// Returns true if a valid (non-expired) token exists for [suffix].
  /// Reads from the Hive tokens box via [TokenStorage].
  ///
  /// Copied from [hasValidToken].
  HasValidTokenProvider(
    String suffix,
  ) : this._internal(
          (ref) => hasValidToken(
            ref as HasValidTokenRef,
            suffix,
          ),
          from: hasValidTokenProvider,
          name: r'hasValidTokenProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$hasValidTokenHash,
          dependencies: HasValidTokenFamily._dependencies,
          allTransitiveDependencies:
              HasValidTokenFamily._allTransitiveDependencies,
          suffix: suffix,
        );

  HasValidTokenProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.suffix,
  }) : super.internal();

  final String suffix;

  @override
  Override overrideWith(
    bool Function(HasValidTokenRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: HasValidTokenProvider._internal(
        (ref) => create(ref as HasValidTokenRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        suffix: suffix,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<bool> createElement() {
    return _HasValidTokenProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is HasValidTokenProvider && other.suffix == suffix;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, suffix.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin HasValidTokenRef on AutoDisposeProviderRef<bool> {
  /// The parameter `suffix` of this provider.
  String get suffix;
}

class _HasValidTokenProviderElement extends AutoDisposeProviderElement<bool>
    with HasValidTokenRef {
  _HasValidTokenProviderElement(super.provider);

  @override
  String get suffix => (origin as HasValidTokenProvider).suffix;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
