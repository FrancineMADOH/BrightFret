import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/connectivity_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/bf_bottom_nav.dart';
import '../../../shared/widgets/bf_offline_banner.dart';
import '../../../shared/widgets/bf_shipment_card.dart';
import '../providers/home_provider.dart';

/// S03 — Home Hub.
/// Entry point for tracking: search bar, QR scanner shortcut, recent shipments.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shipments = ref.watch(homeShipmentsProvider);
    final isOnline = ref.watch(connectivityNotifierProvider);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!isOnline) const BfOfflineBanner(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _searchSection(context, l10n),
                    const SizedBox(height: 12),
                    _scanButton(context, l10n),
                    const SizedBox(height: 32),
                    _recentSection(context, l10n, shipments),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BfBottomNavBar(currentIndex: 0),
    );
  }

  Widget _searchSection(BuildContext context, AppLocalizations l10n) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.trackYourShipment, style: AppTextStyles.heading1),
          const SizedBox(height: 12),
          _SearchBarTile(l10n: l10n),
        ],
      );

  Widget _scanButton(BuildContext context, AppLocalizations l10n) =>
      OutlinedButton.icon(
        onPressed: () => context.push(AppRoute.trackScan.path),
        icon: const Icon(Icons.qr_code_scanner),
        label: Text(l10n.scanQrCode),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      );

  Widget _recentSection(
    BuildContext context,
    AppLocalizations l10n,
    List<HomeShipmentItem> shipments,
  ) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.recentShipments, style: AppTextStyles.heading2),
              if (shipments.isNotEmpty)
                TextButton(
                  onPressed: () => context.go(AppRoute.myShipments.path),
                  child: Text(l10n.viewAll),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (shipments.isEmpty)
            _EmptyState(l10n: l10n)
          else
            ...shipments.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: BfShipmentCard(
                  trackingCode: item.trackingCode,
                  transportType: item.transportType,
                  status: item.status,
                  lastUpdated: item.lastSeen,
                  onTap: () => context.goNamed(
                    AppRoute.publicTimeline.name,
                    pathParameters: {'suffix': item.suffix},
                    queryParameters: {'instance': item.instanceUrl},
                  ),
                ),
              ),
            ),
        ],
      );
}

/// Tappable fake search field that navigates to S04 (code input).
class _SearchBarTile extends StatelessWidget {
  const _SearchBarTile({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoute.trackInput.path),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.statusArchived),
            const SizedBox(width: 12),
            Text(
              l10n.enterTrackingCode,
              style:
                  AppTextStyles.body.copyWith(color: AppColors.statusArchived),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state shown when no shipments have been saved yet.
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 72,
              color: AppColors.statusArchived,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoute.trackInput.path),
              child: Text(l10n.followFirstShipment),
            ),
          ],
        ),
      ),
    );
  }
}
