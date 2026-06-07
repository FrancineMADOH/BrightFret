import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../shared/widgets/bf_bottom_nav.dart';
import '../../../shared/widgets/bf_error_screen.dart';

/// S15 — Unknown forwarder.
/// Shown when the tracking code prefix is absent from forwarders.json.
class ErrorUnknownForwarderScreen extends StatelessWidget {
  const ErrorUnknownForwarderScreen({super.key});

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
        icon: Icons.business_center_outlined,
        title: l10n.errorUnknownForwarderTitle,
        body: l10n.errorUnknownForwarderBody,
        actions: [
          BfErrorAction(
            label: l10n.scanQrCode,
            onTap: () => context.push(AppRoute.trackScan.path),
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
