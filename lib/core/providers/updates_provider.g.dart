// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'updates_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$hasUnreadUpdatesHash() => r'2b7f18332c35b31c4576f2384383ef88fec1b271';

/// Returns true if any entry in [HiveService.updates] has not been read.
/// Used by [BfBottomNavBar] to show the notification badge.
///
/// Copied from [hasUnreadUpdates].
@ProviderFor(hasUnreadUpdates)
final hasUnreadUpdatesProvider = AutoDisposeProvider<bool>.internal(
  hasUnreadUpdates,
  name: r'hasUnreadUpdatesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$hasUnreadUpdatesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HasUnreadUpdatesRef = AutoDisposeProviderRef<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
