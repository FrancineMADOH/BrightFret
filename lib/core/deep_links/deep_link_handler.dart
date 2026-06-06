import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';
import '../utils/forwarder_resolver.dart';
import '../utils/tracking_code_parser.dart';

/// Handles `brightfret://track/{FULL_CODE}` deep links.
///
/// Call [listen] once (from `BrightFretApp.initState`).
/// Call [dispose] when the app is torn down.
///
/// Supported URI format: `brightfret://track/BWF-2026-31PSQJ`
abstract class DeepLinkHandler {
  static const _scheme = 'brightfret';
  static const _host = 'track';

  static StreamSubscription<Uri>? _subscription;
  static bool _listening = false;

  /// Starts listening for deep links and dispatches navigation via [router].
  /// Safe to call multiple times — subsequent calls are no-ops.
  static Future<void> listen(GoRouter router) async {
    if (_listening) return;
    _listening = true;

    final appLinks = AppLinks();

    // Cold-start: process the link that launched the app.
    try {
      final initial = await appLinks.getInitialLink();
      if (initial != null) _dispatch(initial, router);
    } catch (_) {
      // getInitialLink() may throw on platforms with no cold-start link — ignore.
    }

    // Foreground: subscribe to incoming links while the app is running.
    _subscription = appLinks.uriLinkStream.listen(
      (uri) => _dispatch(uri, router),
      onError: (_) {}, // Never let stream errors crash the app.
    );
  }

  /// Cancels the deep link subscription. Call from the root widget's dispose.
  static void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _listening = false;
  }

  /// Parses [uri] and navigates to the appropriate screen.
  ///
  /// - Valid code + known forwarder → [AppRoute.publicTimeline]
  /// - Valid code + unknown forwarder → [AppRoute.errorUnknownForwarder]
  /// - Invalid format or wrong scheme → ignored silently.
  static void _dispatch(Uri uri, GoRouter router) {
    if (uri.scheme != _scheme || uri.host != _host) return;

    final segments = uri.pathSegments;
    if (segments.isEmpty) return;

    final fullCode = segments.first;
    final parsed = TrackingCodeParser.parse(fullCode);
    if (parsed == null) {
      debugPrint('[DeepLink] Ignored — invalid code format: $fullCode');
      return;
    }

    final entry = ForwarderResolver.resolve(parsed.prefix);
    if (entry == null) {
      debugPrint('[DeepLink] Unknown forwarder prefix: ${parsed.prefix}');
      router.go(AppRoute.errorUnknownForwarder.path);
      return;
    }

    final encoded = Uri.encodeQueryComponent(entry.url);
    final path = '/track/${parsed.suffix}?instance=$encoded';
    debugPrint('[DeepLink] → $path');
    router.go(path);
  }
}
