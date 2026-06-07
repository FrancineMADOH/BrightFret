import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/constants/app_enums.dart';
import '../../core/models/app_update.dart';
import '../../core/models/auth_token.dart';
import '../../core/storage/hive_service.dart';

import '../../features/auth/screens/phone_verify_screen.dart';
import '../../features/claims/screens/claim_screen.dart';
import '../../features/messaging/screens/messaging_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/settings/screens/about_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/settings/screens/terms_screen.dart';
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
  about('about'),
  terms('terms'),
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
              instanceUrl: state.uri.queryParameters['instance'] ?? '',
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoute.shipmentDetail.path,
        name: AppRoute.shipmentDetail.name,
        builder: (_, state) => ShipmentDetailScreen(
          suffix: state.pathParameters['suffix']!,
          instanceUrl: state.uri.queryParameters['instance'] ?? '',
        ),
        routes: [
          GoRoute(
            path: AppRoute.documents.path,
            name: AppRoute.documents.name,
            builder: (_, state) => DocumentsScreen(
              suffix: state.pathParameters['suffix']!,
              instanceUrl: state.uri.queryParameters['instance'] ?? '',
            ),
          ),
          GoRoute(
            path: AppRoute.documentViewer.path,
            name: AppRoute.documentViewer.name,
            builder: (_, state) => DocumentViewerScreen(
              suffix: state.pathParameters['suffix']!,
              documentId: state.pathParameters['id']!,
              instanceUrl: state.uri.queryParameters['instance'] ?? '',
              documentUrl: state.uri.queryParameters['url'] ?? '',
              documentName: state.uri.queryParameters['name'] ?? '',
              documentType: state.uri.queryParameters['type'] ?? 'other',
            ),
          ),
          GoRoute(
            path: AppRoute.messaging.path,
            name: AppRoute.messaging.name,
            builder: (_, state) => MessagingScreen(
              suffix: state.pathParameters['suffix']!,
              instanceUrl: state.uri.queryParameters['instance'] ?? '',
            ),
          ),
          GoRoute(
            path: AppRoute.claim.path,
            name: AppRoute.claim.name,
            builder: (_, state) => ClaimScreen(
              suffix: state.pathParameters['suffix']!,
              instanceUrl: state.uri.queryParameters['instance'] ?? '',
              showStatus: state.uri.queryParameters['view'] == 'status',
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
        routes: [
          GoRoute(
            path: AppRoute.about.path,
            name: AppRoute.about.name,
            builder: (_, __) => const AboutScreen(),
          ),
          GoRoute(
            path: AppRoute.terms.path,
            name: AppRoute.terms.name,
            builder: (_, __) => const TermsScreen(),
          ),
        ],
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
      // Debug-only: inject a token into Hive and redirect to the messaging screen
      // Usage: /#/test/inject?suffix=31PSQJ&token=xxx&instance=http://localhost:8068
      if (kDebugMode)
        GoRoute(
          path: '/test/inject',
          builder: (_, state) {
            final suffix = state.uri.queryParameters['suffix'] ?? '';
            final token = state.uri.queryParameters['token'] ?? '';
            final instance = state.uri.queryParameters['instance'] ?? '';
            return _TestInjectScreen(
                suffix: suffix, token: token, instance: instance);
          },
        ),
      // Debug-only: seed fake AppUpdate entries and redirect to updates screen
      // Usage: /#/test/seed-updates
      if (kDebugMode)
        GoRoute(
          path: '/test/seed-updates',
          builder: (_, __) => const _SeedUpdatesScreen(),
        ),
    ];

/// Debug-only screen: stores a test token into Hive and redirects to the messaging screen.
/// Only reachable at /#/test/inject?suffix=...&token=...&instance=...
class _TestInjectScreen extends StatefulWidget {
  const _TestInjectScreen({
    required this.suffix,
    required this.token,
    required this.instance,
  });

  final String suffix;
  final String token;
  final String instance;

  @override
  State<_TestInjectScreen> createState() => _TestInjectScreenState();
}

class _TestInjectScreenState extends State<_TestInjectScreen> {
  @override
  void initState() {
    super.initState();
    _inject();
  }

  Future<void> _inject() async {
    if (widget.token.isNotEmpty && widget.suffix.isNotEmpty) {
      final authToken = AuthToken(
        token: widget.token,
        suffix: widget.suffix,
        instanceUrl: widget.instance,
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
      );
      await HiveService.tokens.put(
        '${widget.instance}:${widget.suffix}',
        authToken,
      );
    }
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    final encoded = Uri.encodeQueryComponent(widget.instance);
    GoRouter.of(context).go('/shipment/${widget.suffix}/messages?instance=$encoded');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

/// Debug-only screen: seeds fake AppUpdate entries into Hive and redirects to S13.
class _SeedUpdatesScreen extends StatefulWidget {
  const _SeedUpdatesScreen();

  @override
  State<_SeedUpdatesScreen> createState() => _SeedUpdatesScreenState();
}

class _SeedUpdatesScreenState extends State<_SeedUpdatesScreen> {
  @override
  void initState() {
    super.initState();
    _seed();
  }

  Future<void> _seed() async {
    final box = HiveService.updates;
    await box.clear();
    final now = DateTime.now();
    await box.add(AppUpdate(
      trackingCode: 'BWF-2026-31PSQJ',
      message: ShipmentStatus.delivered.name,
      detectedAt: now.subtract(const Duration(hours: 2)),
    ));
    await box.add(AppUpdate(
      trackingCode: 'BWF-2026-31PSQJ',
      message: ShipmentStatus.active.name,
      detectedAt: now.subtract(const Duration(days: 1)),
      isRead: true,
    ));
    await box.add(AppUpdate(
      trackingCode: 'BWF-2026-AB1234',
      message: ShipmentStatus.active.name,
      detectedAt: now.subtract(const Duration(days: 3)),
      isRead: true,
    ));
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    GoRouter.of(context).go('/updates');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
