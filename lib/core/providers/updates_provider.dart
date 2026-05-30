import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../storage/hive_service.dart';

part 'updates_provider.g.dart';

/// Returns true if any entry in [HiveService.updates] has not been read.
/// Used by [BfBottomNavBar] to show the notification badge.
@riverpod
bool hasUnreadUpdates(Ref ref) {
  return HiveService.updates.values.any((u) => !u.isRead);
}
