import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_theme.dart';
import 'core/deep_links/deep_link_handler.dart';
import 'core/providers/locale_provider.dart';
import 'core/router/app_router.dart';
import 'core/storage/hive_service.dart';
import 'core/utils/forwarder_resolver.dart';
import 'features/tracking/providers/saved_shipments_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  // Load forwarders.json before runApp so ForwarderResolver is available
  // regardless of which screen is shown first (direct URL navigation on web
  // bypasses SplashScreen and its own load() call).
  try {
    await ForwarderResolver.load();
  } catch (_) {
    // SplashScreen will retry and show the error UI if still unloaded.
  }
  runApp(const ProviderScope(child: BrightFretApp()));
}

/// Root application widget.
/// Wires [routerProvider], [AppTheme], [AppLocalizations], and [DeepLinkHandler].
/// Locale is driven by [localeStateProvider] and persisted in Hive.
class BrightFretApp extends ConsumerStatefulWidget {
  const BrightFretApp({super.key});

  @override
  ConsumerState<BrightFretApp> createState() => _BrightFretAppState();
}

class _BrightFretAppState extends ConsumerState<BrightFretApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      DeepLinkHandler.listen(ref.read(routerProvider));
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(savedShipmentsProvider.notifier).refreshAll();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    DeepLinkHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeStateProvider);
    return MaterialApp.router(
      title: 'BrightFret',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}
