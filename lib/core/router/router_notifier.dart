import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../providers/auth_provider.dart';
import '../providers/onboarding_provider.dart';

part 'router_notifier.g.dart';

/// Bridges Riverpod state into go_router's redirect and refresh mechanism.
/// Listens to [OnboardingState]; notify listeners so the router re-evaluates
/// its redirect logic whenever onboarding or auth state changes.
@Riverpod(keepAlive: true)
class RouterNotifier extends _$RouterNotifier implements Listenable {
  VoidCallback? _routerListener;

  @override
  void build() {
    ref.listen(onboardingStateProvider, (_, __) => _routerListener?.call());
  }

  /// Evaluates whether a redirect is needed for the current route.
  /// Returns a redirect path, or null to allow navigation to proceed.
  String? redirect(BuildContext context, GoRouterState state) {
    final location = state.matchedLocation;

    // Splash handles its own post-init routing — never redirect it.
    if (location == '/') return null;

    final isOnboardingDone = ref.read(onboardingStateProvider);

    // Onboarding guard — error pages and /onboarding itself are exempt.
    if (!isOnboardingDone &&
        !location.startsWith('/error/') &&
        location != '/onboarding') {
      return '/onboarding';
    }

    // Once onboarding is done, redirect away from the onboarding page.
    if (isOnboardingDone && location == '/onboarding') return '/home';

    // If already on verify screen but a valid token exists → skip to S08.
    // This replaces the per-screen _checkExistingToken() call and avoids
    // the 1-frame flicker where S07 renders before jumping to S08.
    if (location.endsWith('/verify')) {
      final suffix = state.pathParameters['suffix'];
      final instance = state.uri.queryParameters['instance'] ?? '';
      if (suffix != null && ref.read(hasValidTokenProvider(suffix))) {
        final encoded = Uri.encodeQueryComponent(instance);
        return '/shipment/$suffix?instance=$encoded';
      }
    }

    // Auth guard: all /shipment/* routes require a valid token.
    // Preserves the instanceUrl in the redirect so S07 can navigate back to S08.
    if (location.startsWith('/shipment/')) {
      final suffix = state.pathParameters['suffix'];
      final instance = state.uri.queryParameters['instance'] ?? '';
      if (suffix != null && !ref.read(hasValidTokenProvider(suffix))) {
        final encoded = Uri.encodeQueryComponent(instance);
        return '/track/$suffix/verify?instance=$encoded';
      }
    }

    return null;
  }

  @override
  void addListener(VoidCallback listener) => _routerListener = listener;

  @override
  void removeListener(VoidCallback listener) => _routerListener = null;
}
