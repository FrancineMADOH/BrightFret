// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'documents_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$documentsHash() => r'047a114fdbbc1c59cbc70f8155c659785efc2767';

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

/// Fetches the document list for [suffix] from [instanceUrl].
/// Requires a valid bearer token — throws [UnauthorizedException] if expired.
///
/// Copied from [documents].
@ProviderFor(documents)
const documentsProvider = DocumentsFamily();

/// Fetches the document list for [suffix] from [instanceUrl].
/// Requires a valid bearer token — throws [UnauthorizedException] if expired.
///
/// Copied from [documents].
class DocumentsFamily extends Family<AsyncValue<List<ShipmentDocument>>> {
  /// Fetches the document list for [suffix] from [instanceUrl].
  /// Requires a valid bearer token — throws [UnauthorizedException] if expired.
  ///
  /// Copied from [documents].
  const DocumentsFamily();

  /// Fetches the document list for [suffix] from [instanceUrl].
  /// Requires a valid bearer token — throws [UnauthorizedException] if expired.
  ///
  /// Copied from [documents].
  DocumentsProvider call(
    String suffix,
    String instanceUrl,
  ) {
    return DocumentsProvider(
      suffix,
      instanceUrl,
    );
  }

  @override
  DocumentsProvider getProviderOverride(
    covariant DocumentsProvider provider,
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
  String? get name => r'documentsProvider';
}

/// Fetches the document list for [suffix] from [instanceUrl].
/// Requires a valid bearer token — throws [UnauthorizedException] if expired.
///
/// Copied from [documents].
class DocumentsProvider
    extends AutoDisposeFutureProvider<List<ShipmentDocument>> {
  /// Fetches the document list for [suffix] from [instanceUrl].
  /// Requires a valid bearer token — throws [UnauthorizedException] if expired.
  ///
  /// Copied from [documents].
  DocumentsProvider(
    String suffix,
    String instanceUrl,
  ) : this._internal(
          (ref) => documents(
            ref as DocumentsRef,
            suffix,
            instanceUrl,
          ),
          from: documentsProvider,
          name: r'documentsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$documentsHash,
          dependencies: DocumentsFamily._dependencies,
          allTransitiveDependencies: DocumentsFamily._allTransitiveDependencies,
          suffix: suffix,
          instanceUrl: instanceUrl,
        );

  DocumentsProvider._internal(
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
    FutureOr<List<ShipmentDocument>> Function(DocumentsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: DocumentsProvider._internal(
        (ref) => create(ref as DocumentsRef),
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
  AutoDisposeFutureProviderElement<List<ShipmentDocument>> createElement() {
    return _DocumentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is DocumentsProvider &&
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
mixin DocumentsRef on AutoDisposeFutureProviderRef<List<ShipmentDocument>> {
  /// The parameter `suffix` of this provider.
  String get suffix;

  /// The parameter `instanceUrl` of this provider.
  String get instanceUrl;
}

class _DocumentsProviderElement
    extends AutoDisposeFutureProviderElement<List<ShipmentDocument>>
    with DocumentsRef {
  _DocumentsProviderElement(super.provider);

  @override
  String get suffix => (origin as DocumentsProvider).suffix;
  @override
  String get instanceUrl => (origin as DocumentsProvider).instanceUrl;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
