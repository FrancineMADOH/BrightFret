import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../storage/hive_service.dart';

part 'onboarding_provider.g.dart';

/// Tracks whether the user has completed onboarding.
/// Reads from Hive `prefs` box (key: 'onboarding_done'); persists on [markDone].
@Riverpod(keepAlive: true)
class OnboardingState extends _$OnboardingState {
  static const _key = 'onboarding_done';

  @override
  bool build() {
    return HiveService.prefs.get(_key, defaultValue: false) as bool;
  }

  /// Marks onboarding as complete and persists to Hive.
  Future<void> markDone() async {
    await HiveService.prefs.put(_key, true);
    state = true;
  }
}
