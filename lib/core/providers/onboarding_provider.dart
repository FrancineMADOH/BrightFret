import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_provider.g.dart';

/// Tracks whether the user has completed onboarding.
/// Stub: always starts false. Will read from Hive `prefs` box in F0.5.
@Riverpod(keepAlive: true)
class OnboardingState extends _$OnboardingState {
  @override
  bool build() => false;

  /// Marks onboarding as complete and persists to Hive in F0.5.
  void markDone() => state = true;
}
