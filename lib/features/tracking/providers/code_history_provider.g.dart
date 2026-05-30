// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'code_history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$codeHistoryHash() => r'f853fb93071818efbc4285949c502e76df4fe9c8';

/// Manages the list of recently entered tracking codes (max 5).
/// Persisted in [HiveService.prefs] under key `search_history`.
///
/// Copied from [CodeHistory].
@ProviderFor(CodeHistory)
final codeHistoryProvider =
    AutoDisposeNotifierProvider<CodeHistory, List<String>>.internal(
  CodeHistory.new,
  name: r'codeHistoryProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$codeHistoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CodeHistory = AutoDisposeNotifier<List<String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
