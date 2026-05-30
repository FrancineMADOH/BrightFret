import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_theme.dart';
import 'core/providers/locale_provider.dart';
import 'core/router/app_router.dart';
import 'core/storage/hive_service.dart';
import 'core/utils/forwarder_resolver.dart';

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
/// Wires [routerProvider], [AppTheme], and [AppLocalizations].
/// Locale is driven by [localeStateProvider] and persisted in Hive.
class BrightFretApp extends ConsumerWidget {
  const BrightFretApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
