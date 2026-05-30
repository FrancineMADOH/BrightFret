// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$homeShipmentsHash() => r'4f31c90e328544172a1a93c57cfcc06b36b92234';

/// Returns up to 3 saved shipments sorted by most recently seen.
/// Data source: [HiveService.myShipments].
///
/// Copied from [homeShipments].
@ProviderFor(homeShipments)
final homeShipmentsProvider =
    AutoDisposeProvider<List<HomeShipmentItem>>.internal(
  homeShipments,
  name: r'homeShipmentsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$homeShipmentsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HomeShipmentsRef = AutoDisposeProviderRef<List<HomeShipmentItem>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
