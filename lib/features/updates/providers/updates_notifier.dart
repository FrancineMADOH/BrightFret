import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/models/app_update.dart';
import '../../../core/providers/updates_provider.dart';
import '../../../core/storage/hive_service.dart';

part 'updates_notifier.g.dart';

/// Manages in-app update notifications from [HiveService.updates].
/// State is sorted newest-first. All mutations persist to Hive immediately.
@riverpod
class UpdatesNotifier extends _$UpdatesNotifier {
  @override
  List<AppUpdate> build() => _sorted();

  /// Marks every unread update as read and refreshes the nav-badge provider.
  Future<void> markAllRead() async {
    final unread = HiveService.updates.values.where((u) => !u.isRead).toList();
    if (unread.isEmpty) return;
    for (final u in unread) {
      u.isRead = true;
      await u.save();
    }
    state = _sorted();
    ref.invalidate(hasUnreadUpdatesProvider);
  }

  /// Removes every update entry from Hive and clears the badge.
  Future<void> clearAll() async {
    await HiveService.updates.clear();
    state = [];
    ref.invalidate(hasUnreadUpdatesProvider);
  }

  List<AppUpdate> _sorted() => HiveService.updates.values.toList()
    ..sort((a, b) => b.detectedAt.compareTo(a.detectedAt));
}
