// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'updates_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$updatesNotifierHash() => r'b4064c1ada1861ed90d50af4a31d984b52e0aa11';

/// Manages in-app update notifications from [HiveService.updates].
/// State is sorted newest-first. All mutations persist to Hive immediately.
///
/// Copied from [UpdatesNotifier].
@ProviderFor(UpdatesNotifier)
final updatesNotifierProvider =
    AutoDisposeNotifierProvider<UpdatesNotifier, List<AppUpdate>>.internal(
  UpdatesNotifier.new,
  name: r'updatesNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$updatesNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UpdatesNotifier = AutoDisposeNotifier<List<AppUpdate>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
