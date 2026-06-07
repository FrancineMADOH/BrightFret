import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_enums.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/models/app_update.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/forwarder_resolver.dart';
import '../../../core/utils/tracking_code_parser.dart';
import '../../../shared/widgets/bf_bottom_nav.dart';
import '../providers/updates_notifier.dart';

/// S13 — In-app delta notifications read from [HiveService.updates].
/// Marks all entries as read on open; badge clears automatically.
class UpdatesScreen extends ConsumerStatefulWidget {
  const UpdatesScreen({super.key});

  @override
  ConsumerState<UpdatesScreen> createState() => _UpdatesScreenState();
}

class _UpdatesScreenState extends ConsumerState<UpdatesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(updatesNotifierProvider.notifier).markAllRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    final updates = ref.watch(updatesNotifierProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tabUpdates),
        automaticallyImplyLeading: false,
        actions: [
          if (updates.isNotEmpty)
            TextButton(
              onPressed: () =>
                  ref.read(updatesNotifierProvider.notifier).clearAll(),
              child: Text(
                l10n.clearAllUpdates,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ),
      bottomNavigationBar: const BfBottomNavBar(currentIndex: 2),
      body: updates.isEmpty
          ? _EmptyState(l10n: l10n)
          : ListView.builder(
              itemCount: updates.length,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemBuilder: (_, i) => _UpdateTile(update: updates[i]),
            ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_outlined,
              size: 72,
              color: AppColors.statusArchived.withAlpha(120),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noUpdatesYet,
              style: AppTextStyles.heading2
                  .copyWith(color: AppColors.statusArchived),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.noUpdatesHint,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.statusArchived),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Update tile ───────────────────────────────────────────────────────────────

class _UpdateTile extends StatelessWidget {
  const _UpdateTile({required this.update});

  final AppUpdate update;

  /// [AppUpdate.message] stores a [ShipmentStatus.name] (written by
  /// [SavedShipments._refreshOne]). Falls back to the raw string for
  /// debug-seeded entries that predate this convention.
  static String _statusLabel(String message, AppLocalizations l10n) {
    final status = ShipmentStatus.values
        .where((s) => s.name == message)
        .firstOrNull;
    if (status == null) return message;
    return switch (status) {
      ShipmentStatus.active => l10n.statusActive,
      ShipmentStatus.delivered => l10n.statusDelivered,
      ShipmentStatus.warning => l10n.statusWarning,
      ShipmentStatus.error => l10n.statusError,
      ShipmentStatus.archived => l10n.statusArchived,
    };
  }

  static String _relativeTime(DateTime dt, AppLocalizations l10n) {
    final diff = DateTime.now().difference(dt);
    if (diff.isNegative || diff.inMinutes < 1) return l10n.justNow;
    if (diff.inHours < 1) return l10n.minutesAgo(diff.inMinutes);
    if (diff.inDays < 1) return l10n.hoursAgo(diff.inHours);
    return l10n.daysAgo(diff.inDays);
  }

  void _navigateToShipment(BuildContext context) {
    final parsed = TrackingCodeParser.parse(update.trackingCode);
    if (parsed == null) return;
    final instanceUrl = ForwarderResolver.resolveUrl(parsed.prefix);
    if (instanceUrl == null) return;
    context.goNamed(
      AppRoute.publicTimeline.name,
      pathParameters: {'suffix': parsed.suffix},
      queryParameters: {'instance': instanceUrl},
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isUnread = !update.isRead;

    return ColoredBox(
      color: isUnread
          ? AppColors.primary.withAlpha(10)
          : Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: _LeadingIcon(isUnread: isUnread),
            title: Text(
              update.trackingCode,
              style: AppTextStyles.label.copyWith(
                color: isUnread ? AppColors.primary : null,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                l10n.updateNewStatus(_statusLabel(update.message, l10n)),
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.statusArchived),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            trailing: Text(
              _relativeTime(update.detectedAt, l10n),
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.statusArchived),
            ),
            onTap: () => _navigateToShipment(context),
          ),
          const Divider(height: 1, indent: 72),
        ],
      ),
    );
  }
}

// ── Leading icon ──────────────────────────────────────────────────────────────

class _LeadingIcon extends StatelessWidget {
  const _LeadingIcon({required this.isUnread});

  final bool isUnread;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(isUnread ? 30 : 15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isUnread
                ? Icons.notifications_active_outlined
                : Icons.notifications_outlined,
            color: AppColors.primary,
            size: 22,
          ),
        ),
        if (isUnread)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
