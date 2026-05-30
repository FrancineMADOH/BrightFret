// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locale_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$localeStateHash() => r'f54494b148cf959a249765d660115b51adee4e29';

/// App locale state, persisted in Hive `prefs` box.
/// Defaults to French if no saved language is found or the stored value is unsupported.
///
/// Copied from [LocaleState].
@ProviderFor(LocaleState)
final localeStateProvider = NotifierProvider<LocaleState, Locale>.internal(
  LocaleState.new,
  name: r'localeStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$localeStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LocaleState = Notifier<Locale>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
