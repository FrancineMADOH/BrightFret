import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../shared/widgets/bf_bottom_nav.dart';
import '../../../shared/widgets/bf_error_screen.dart';

/// S16 — Shipment not found.
/// Shown when the tracking API returns 404 for a given suffix.
/// Also used as the go_router [errorBuilder] fallback for unknown app routes.
class ErrorNotFoundScreen extends StatelessWidget {
  const ErrorNotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(AppRoute.home.path),
        ),
      ),
      bottomNavigationBar: const BfBottomNavBar(currentIndex: 0),
      body: BfErrorScreen(
        icon: Icons.search_off_outlined,
        title: l10n.errorNotFoundTitle,
        body: l10n.errorNotFoundBody,
        actions: [
          BfErrorAction(
            label: l10n.retry,
            onTap: () => context.canPop()
                ? context.pop()
                : context.go(AppRoute.home.path),
          ),
          BfErrorAction(
            label: l10n.tryAnotherCode,
            onTap: () => context.go(AppRoute.trackInput.path),
          ),
        ],
      ),
    );
  }
}
