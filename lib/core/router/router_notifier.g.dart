// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$routerNotifierHash() => r'74d5ededf53f6deeaebccf6405f8116c84105723';

/// Bridges Riverpod state into go_router's redirect and refresh mechanism.
/// Listens to [OnboardingState]; notify listeners so the router re-evaluates
/// its redirect logic whenever onboarding or auth state changes.
///
/// Copied from [RouterNotifier].
@ProviderFor(RouterNotifier)
final routerNotifierProvider = NotifierProvider<RouterNotifier, void>.internal(
  RouterNotifier.new,
  name: r'routerNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$routerNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$RouterNotifier = Notifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
