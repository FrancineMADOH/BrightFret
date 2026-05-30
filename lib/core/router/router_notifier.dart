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

    // Auth guard: all /shipment/* routes require a valid token.
    if (location.startsWith('/shipment/')) {
      final suffix = state.pathParameters['suffix'];
      if (suffix != null && !ref.read(hasValidTokenProvider(suffix))) {
        return '/track/$suffix/verify';
      }
    }

    return null;
  }

  @override
  void addListener(VoidCallback listener) => _routerListener = listener;

  @override
  void removeListener(VoidCallback listener) => _routerListener = null;
}
