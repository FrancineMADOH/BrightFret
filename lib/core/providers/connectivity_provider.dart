import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_provider.g.dart';

/// Reactive network-status provider.
/// Emits `true` when at least one non-[ConnectivityResult.none] result is present.
/// Starts optimistically at `true` and corrects itself after the first platform check.
@Riverpod(keepAlive: true)
class ConnectivityNotifier extends _$ConnectivityNotifier {
  @override
  bool build() {
    final connectivity = Connectivity();

    // Subscribe to stream — cancelled when provider disposes.
    final sub = connectivity.onConnectivityChanged.listen((results) {
      state = _isOnline(results);
    });
    ref.onDispose(sub.cancel);

    // Kick off an initial check without blocking the synchronous build().
    Future.microtask(() async {
      try {
        final initial = await connectivity.checkConnectivity();
        state = _isOnline(initial);
      } catch (_) {
        // Ignore — keep optimistic true on unsupported platforms (e.g. web simulator).
      }
    });

    return true; // optimistic until first async check resolves
  }

  static bool _isOnline(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);
}
