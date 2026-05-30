import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/storage/hive_service.dart';

part 'code_history_provider.g.dart';

/// Manages the list of recently entered tracking codes (max 5).
/// Persisted in [HiveService.prefs] under key `search_history`.
@riverpod
class CodeHistory extends _$CodeHistory {
  static const _key = 'search_history';
  static const _maxItems = 5;

  @override
  List<String> build() {
    final raw = HiveService.prefs.get(_key);
    if (raw is! List) return [];
    return List<String>.from(raw);
  }

  /// Prepends [code], deduplicates, and caps at [_maxItems].
  Future<void> add(String code) async {
    final updated =
        [code, ...state.where((c) => c != code)].take(_maxItems).toList();
    await HiveService.prefs.put(_key, updated);
    state = updated;
  }

  /// Removes [code] from history.
  Future<void> remove(String code) async {
    final updated = state.where((c) => c != code).toList();
    await HiveService.prefs.put(_key, updated);
    state = updated;
  }
}
