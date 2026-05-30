import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';

void main() {
  runApp(const ProviderScope(child: BrightFretApp()));
}

/// Root application widget.
/// Uses [routerProvider] so go_router controls all navigation.
class BrightFretApp extends ConsumerWidget {
  const BrightFretApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'BrightFret',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
