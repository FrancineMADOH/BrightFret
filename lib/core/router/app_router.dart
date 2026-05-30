import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/screens/phone_verify_screen.dart';
import '../../features/claims/screens/claim_screen.dart';
import '../../features/messaging/screens/messaging_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/shipment/screens/document_viewer_screen.dart';
import '../../features/shipment/screens/documents_screen.dart';
import '../../features/shipment/screens/shipment_detail_screen.dart';
import '../../features/tracking/screens/code_input_screen.dart';
import '../../features/tracking/screens/error_not_found_screen.dart';
import '../../features/tracking/screens/error_unknown_forwarder_screen.dart';
import '../../features/tracking/screens/home_screen.dart';
import '../../features/tracking/screens/my_shipments_screen.dart';
import '../../features/tracking/screens/public_timeline_screen.dart';
import '../../features/tracking/screens/qr_scanner_screen.dart';
import '../../features/tracking/screens/splash_screen.dart';
import '../../features/updates/screens/updates_screen.dart';
import 'router_notifier.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Named route identifiers used for type-safe navigation.
/// [path] is the route path segment (relative for nested routes).
/// [name] returns the Dart enum identifier string for use as go_router route names.
enum AppRoute {
  splash('/'),
  onboarding('/onboarding'),
  home('/home'),
  trackInput('/track/input'),
  trackScan('/track/scan'),
  publicTimeline('/track/:suffix'),
  phoneVerify('verify'),
  shipmentDetail('/shipment/:suffix'),
  documents('documents'),
  documentViewer('document/:id'),
  messaging('messages'),
  myShipments('/my-shipments'),
  updates('/updates'),
  settings('/settings'),
  errorUnknownForwarder('/error/unknown-forwarder'),
  errorNotFound('/error/not-found'),
  claim('claim');

  const AppRoute(this.path);

  /// The path segment used in the GoRoute definition.
  /// Nested routes (phoneVerify, documents, etc.) use relative paths.
  final String path;
}

/// The app-wide [GoRouter] instance.
/// Kept alive for the app's lifetime so the navigation stack is never reset.
@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final notifier = ref.watch(routerNotifierProvider.notifier);
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoute.splash.path,
    debugLogDiagnostics: kDebugMode,
    refreshListenable: notifier,
    redirect: notifier.redirect,
    errorBuilder: (context, state) => const ErrorNotFoundScreen(),
    routes: _buildRoutes(notifier),
  );
}

List<RouteBase> _buildRoutes(RouterNotifier notifier) => [
      GoRoute(
        path: AppRoute.splash.path,
        name: AppRoute.splash.name,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoute.onboarding.path,
        name: AppRoute.onboarding.name,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoute.home.path,
        name: AppRoute.home.name,
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoute.trackInput.path,
        name: AppRoute.trackInput.name,
        builder: (_, __) => const CodeInputScreen(),
      ),
      GoRoute(
        path: AppRoute.trackScan.path,
        name: AppRoute.trackScan.name,
        builder: (_, __) => const QrScannerScreen(),
      ),
      GoRoute(
        path: AppRoute.publicTimeline.path,
        name: AppRoute.publicTimeline.name,
        builder: (_, state) => PublicTimelineScreen(
          suffix: state.pathParameters['suffix']!,
          instanceUrl: state.uri.queryParameters['instance'] ?? '',
        ),
        routes: [
          GoRoute(
            path: AppRoute.phoneVerify.path,
            name: AppRoute.phoneVerify.name,
            builder: (_, state) => PhoneVerifyScreen(
              suffix: state.pathParameters['suffix']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoute.shipmentDetail.path,
        name: AppRoute.shipmentDetail.name,
        builder: (_, state) => ShipmentDetailScreen(
          suffix: state.pathParameters['suffix']!,
        ),
        routes: [
          GoRoute(
            path: AppRoute.documents.path,
            name: AppRoute.documents.name,
            builder: (_, state) => DocumentsScreen(
              suffix: state.pathParameters['suffix']!,
            ),
          ),
          GoRoute(
            path: AppRoute.documentViewer.path,
            name: AppRoute.documentViewer.name,
            builder: (_, state) => DocumentViewerScreen(
              suffix: state.pathParameters['suffix']!,
              documentId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: AppRoute.messaging.path,
            name: AppRoute.messaging.name,
            builder: (_, state) => MessagingScreen(
              suffix: state.pathParameters['suffix']!,
            ),
          ),
          GoRoute(
            path: AppRoute.claim.path,
            name: AppRoute.claim.name,
            builder: (_, state) => ClaimScreen(
              suffix: state.pathParameters['suffix']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoute.myShipments.path,
        name: AppRoute.myShipments.name,
        builder: (_, __) => const MyShipmentsScreen(),
      ),
      GoRoute(
        path: AppRoute.updates.path,
        name: AppRoute.updates.name,
        builder: (_, __) => const UpdatesScreen(),
      ),
      GoRoute(
        path: AppRoute.settings.path,
        name: AppRoute.settings.name,
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoute.errorUnknownForwarder.path,
        name: AppRoute.errorUnknownForwarder.name,
        builder: (_, __) => const ErrorUnknownForwarderScreen(),
      ),
      GoRoute(
        path: AppRoute.errorNotFound.path,
        name: AppRoute.errorNotFound.name,
        builder: (_, __) => const ErrorNotFoundScreen(),
      ),
    ];
