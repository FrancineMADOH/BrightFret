// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_shipment_toggle_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$savedShipmentToggleHash() =>
    r'3ba64f8a93d7661195d880efed143cace8e8ee98';

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

abstract class _$SavedShipmentToggle
    extends BuildlessAutoDisposeNotifier<bool> {
  late final String trackingCode;

  bool build(
    String trackingCode,
  );
}

/// Tracks whether the shipment with [trackingCode] is saved in
/// [HiveService.myShipments], and exposes a [toggle] mutation.
///
/// Copied from [SavedShipmentToggle].
@ProviderFor(SavedShipmentToggle)
const savedShipmentToggleProvider = SavedShipmentToggleFamily();

/// Tracks whether the shipment with [trackingCode] is saved in
/// [HiveService.myShipments], and exposes a [toggle] mutation.
///
/// Copied from [SavedShipmentToggle].
class SavedShipmentToggleFamily extends Family<bool> {
  /// Tracks whether the shipment with [trackingCode] is saved in
  /// [HiveService.myShipments], and exposes a [toggle] mutation.
  ///
  /// Copied from [SavedShipmentToggle].
  const SavedShipmentToggleFamily();

  /// Tracks whether the shipment with [trackingCode] is saved in
  /// [HiveService.myShipments], and exposes a [toggle] mutation.
  ///
  /// Copied from [SavedShipmentToggle].
  SavedShipmentToggleProvider call(
    String trackingCode,
  ) {
    return SavedShipmentToggleProvider(
      trackingCode,
    );
  }

  @override
  SavedShipmentToggleProvider getProviderOverride(
    covariant SavedShipmentToggleProvider provider,
  ) {
    return call(
      provider.trackingCode,
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
  String? get name => r'savedShipmentToggleProvider';
}

/// Tracks whether the shipment with [trackingCode] is saved in
/// [HiveService.myShipments], and exposes a [toggle] mutation.
///
/// Copied from [SavedShipmentToggle].
class SavedShipmentToggleProvider
    extends AutoDisposeNotifierProviderImpl<SavedShipmentToggle, bool> {
  /// Tracks whether the shipment with [trackingCode] is saved in
  /// [HiveService.myShipments], and exposes a [toggle] mutation.
  ///
  /// Copied from [SavedShipmentToggle].
  SavedShipmentToggleProvider(
    String trackingCode,
  ) : this._internal(
          () => SavedShipmentToggle()..trackingCode = trackingCode,
          from: savedShipmentToggleProvider,
          name: r'savedShipmentToggleProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$savedShipmentToggleHash,
          dependencies: SavedShipmentToggleFamily._dependencies,
          allTransitiveDependencies:
              SavedShipmentToggleFamily._allTransitiveDependencies,
          trackingCode: trackingCode,
        );

  SavedShipmentToggleProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.trackingCode,
  }) : super.internal();

  final String trackingCode;

  @override
  bool runNotifierBuild(
    covariant SavedShipmentToggle notifier,
  ) {
    return notifier.build(
      trackingCode,
    );
  }

  @override
  Override overrideWith(SavedShipmentToggle Function() create) {
    return ProviderOverride(
      origin: this,
      override: SavedShipmentToggleProvider._internal(
        () => create()..trackingCode = trackingCode,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        trackingCode: trackingCode,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<SavedShipmentToggle, bool>
      createElement() {
    return _SavedShipmentToggleProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SavedShipmentToggleProvider &&
        other.trackingCode == trackingCode;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, trackingCode.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SavedShipmentToggleRef on AutoDisposeNotifierProviderRef<bool> {
  /// The parameter `trackingCode` of this provider.
  String get trackingCode;
}

class _SavedShipmentToggleProviderElement
    extends AutoDisposeNotifierProviderElement<SavedShipmentToggle, bool>
    with SavedShipmentToggleRef {
  _SavedShipmentToggleProviderElement(super.provider);

  @override
  String get trackingCode =>
      (origin as SavedShipmentToggleProvider).trackingCode;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
