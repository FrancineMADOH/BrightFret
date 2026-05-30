import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/updates_provider.dart';
import '../../core/router/app_router.dart';

/// Shared bottom navigation bar for the 4 top-level tab screens.
/// [currentIndex]: 0=Home, 1=My Shipments, 2=Updates, 3=Settings.
class BfBottomNavBar extends ConsumerWidget {
  const BfBottomNavBar({super.key, required this.currentIndex});

  final int currentIndex;

  static const _routes = [
    AppRoute.home,
    AppRoute.myShipments,
    AppRoute.updates,
    AppRoute.settings,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasUpdates = ref.watch(hasUnreadUpdatesProvider);
    final l10n = AppLocalizations.of(context)!;
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (i) => context.go(_routes[i].path),
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: l10n.tabHome,
        ),
        NavigationDestination(
          icon: const Icon(Icons.inventory_2_outlined),
          selectedIcon: const Icon(Icons.inventory_2),
          label: l10n.myShipments,
        ),
        NavigationDestination(
          icon: Badge(
            isLabelVisible: hasUpdates,
            child: const Icon(Icons.notifications_outlined),
          ),
          selectedIcon: Badge(
            isLabelVisible: hasUpdates,
            child: const Icon(Icons.notifications),
          ),
          label: l10n.tabUpdates,
        ),
        NavigationDestination(
          icon: const Icon(Icons.settings_outlined),
          selectedIcon: const Icon(Icons.settings),
          label: l10n.tabSettings,
        ),
      ],
    );
  }
}
