// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$onboardingStateHash() => r'6ee0780f6e32530dc407c5425b085a991464421c';

/// Tracks whether the user has completed onboarding.
/// Reads from Hive `prefs` box (key: 'onboarding_done'); persists on [markDone].
///
/// Copied from [OnboardingState].
@ProviderFor(OnboardingState)
final onboardingStateProvider =
    NotifierProvider<OnboardingState, bool>.internal(
  OnboardingState.new,
  name: r'onboardingStateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$onboardingStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$OnboardingState = Notifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
