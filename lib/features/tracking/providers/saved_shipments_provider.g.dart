// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_shipments_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$savedShipmentsHash() => r'd7d48595fb41c74dfce692d775adff7cfcdeb829';

/// Manages the list of saved shipments from [HiveService.myShipments].
/// Active shipments are sorted first, then by most recently seen.
///
/// Copied from [SavedShipments].
@ProviderFor(SavedShipments)
final savedShipmentsProvider =
    AutoDisposeNotifierProvider<SavedShipments, List<SavedShipment>>.internal(
  SavedShipments.new,
  name: r'savedShipmentsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$savedShipmentsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SavedShipments = AutoDisposeNotifier<List<SavedShipment>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
