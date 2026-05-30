// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dio_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dioForInstanceHash() => r'0293d7a672d5e105165f52df08a2bad0b1fc32ef';

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

/// Returns a [Dio] instance for [instanceUrl] with [TokenStorage] wired as
/// the [TokenReader]. Services use this instead of calling [DioClient.forInstance]
/// directly, so the auth interceptor always has access to Hive tokens.
///
/// Usage in a service:
/// ```dart
/// final dio = ref.read(dioForInstanceProvider(instanceUrl));
/// ```
///
/// Copied from [dioForInstance].
@ProviderFor(dioForInstance)
const dioForInstanceProvider = DioForInstanceFamily();

/// Returns a [Dio] instance for [instanceUrl] with [TokenStorage] wired as
/// the [TokenReader]. Services use this instead of calling [DioClient.forInstance]
/// directly, so the auth interceptor always has access to Hive tokens.
///
/// Usage in a service:
/// ```dart
/// final dio = ref.read(dioForInstanceProvider(instanceUrl));
/// ```
///
/// Copied from [dioForInstance].
class DioForInstanceFamily extends Family<Dio> {
  /// Returns a [Dio] instance for [instanceUrl] with [TokenStorage] wired as
  /// the [TokenReader]. Services use this instead of calling [DioClient.forInstance]
  /// directly, so the auth interceptor always has access to Hive tokens.
  ///
  /// Usage in a service:
  /// ```dart
  /// final dio = ref.read(dioForInstanceProvider(instanceUrl));
  /// ```
  ///
  /// Copied from [dioForInstance].
  const DioForInstanceFamily();

  /// Returns a [Dio] instance for [instanceUrl] with [TokenStorage] wired as
  /// the [TokenReader]. Services use this instead of calling [DioClient.forInstance]
  /// directly, so the auth interceptor always has access to Hive tokens.
  ///
  /// Usage in a service:
  /// ```dart
  /// final dio = ref.read(dioForInstanceProvider(instanceUrl));
  /// ```
  ///
  /// Copied from [dioForInstance].
  DioForInstanceProvider call(
    String instanceUrl,
  ) {
    return DioForInstanceProvider(
      instanceUrl,
    );
  }

  @override
  DioForInstanceProvider getProviderOverride(
    covariant DioForInstanceProvider provider,
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
  String? get name => r'dioForInstanceProvider';
}

/// Returns a [Dio] instance for [instanceUrl] with [TokenStorage] wired as
/// the [TokenReader]. Services use this instead of calling [DioClient.forInstance]
/// directly, so the auth interceptor always has access to Hive tokens.
///
/// Usage in a service:
/// ```dart
/// final dio = ref.read(dioForInstanceProvider(instanceUrl));
/// ```
///
/// Copied from [dioForInstance].
class DioForInstanceProvider extends Provider<Dio> {
  /// Returns a [Dio] instance for [instanceUrl] with [TokenStorage] wired as
  /// the [TokenReader]. Services use this instead of calling [DioClient.forInstance]
  /// directly, so the auth interceptor always has access to Hive tokens.
  ///
  /// Usage in a service:
  /// ```dart
  /// final dio = ref.read(dioForInstanceProvider(instanceUrl));
  /// ```
  ///
  /// Copied from [dioForInstance].
  DioForInstanceProvider(
    String instanceUrl,
  ) : this._internal(
          (ref) => dioForInstance(
            ref as DioForInstanceRef,
            instanceUrl,
          ),
          from: dioForInstanceProvider,
          name: r'dioForInstanceProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$dioForInstanceHash,
          dependencies: DioForInstanceFamily._dependencies,
          allTransitiveDependencies:
              DioForInstanceFamily._allTransitiveDependencies,
          instanceUrl: instanceUrl,
        );

  DioForInstanceProvider._internal(
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
    Dio Function(DioForInstanceRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DioForInstanceProvider._internal(
        (ref) => create(ref as DioForInstanceRef),
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
  ProviderElement<Dio> createElement() {
    return _DioForInstanceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DioForInstanceProvider && other.instanceUrl == instanceUrl;
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
mixin DioForInstanceRef on ProviderRef<Dio> {
  /// The parameter `instanceUrl` of this provider.
  String get instanceUrl;
}

class _DioForInstanceProviderElement extends ProviderElement<Dio>
    with DioForInstanceRef {
  _DioForInstanceProviderElement(super.provider);

  @override
  String get instanceUrl => (origin as DioForInstanceProvider).instanceUrl;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
