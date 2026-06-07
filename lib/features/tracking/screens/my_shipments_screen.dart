import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_enums.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/models/saved_shipment.dart';
import '../../../core/router/app_router.dart';
import '../../../core/storage/hive_service.dart';
import '../../../shared/widgets/bf_bottom_nav.dart';
import '../../../shared/widgets/bf_shipment_card.dart';
import '../providers/saved_shipments_provider.dart';

/// S12 — Saved shipments list with filter tabs, swipe-to-remove, and
/// background status refresh on open.
class MyShipmentsScreen extends ConsumerStatefulWidget {
  const MyShipmentsScreen({super.key});

  @override
  ConsumerState<MyShipmentsScreen> createState() => _MyShipmentsScreenState();
}

class _MyShipmentsScreenState extends ConsumerState<MyShipmentsScreen> {
  bool _isRefreshing = false;
  int _filterIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _triggerRefresh());
  }

  Future<void> _triggerRefresh() async {
    if (!mounted) return;
    setState(() => _isRefreshing = true);
    try {
      await ref.read(savedShipmentsProvider.notifier).refreshAll();
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  List<SavedShipment> _applyFilter(List<SavedShipment> all) {
    return switch (_filterIndex) {
      1 => all.where((s) => _isActive(s.lastStatus)).toList(),
      2 => all.where((s) => !_isActive(s.lastStatus)).toList(),
      _ => all,
    };
  }

  static bool _isActive(String status) {
    final s = status.toLowerCase();
    return !s.contains('done') &&
        !s.contains('delivered') &&
        !s.contains('livré') &&
        !s.contains('cancelled') &&
        !s.contains('annulé') &&
        !s.contains('archived') &&
        !s.contains('archivé');
  }

  Future<bool?> _confirmRemove(AppLocalizations l10n) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.removeShipmentTitle),
        content: Text(l10n.removeShipmentBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.removeShipment,
              style: const TextStyle(color: AppColors.statusError),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final all = ref.watch(savedShipmentsProvider);
    final filtered = _applyFilter(all);
    final activeCount = all.where((s) => _isActive(s.lastStatus)).length;
    final deliveredCount = all.length - activeCount;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myShipments),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: l10n.enterTrackingCode,
            onPressed: () => context.push(AppRoute.trackInput.path),
          ),
        ],
      ),
      bottomNavigationBar: const BfBottomNavBar(currentIndex: 1),
      body: Column(
        children: [
          if (_isRefreshing)
            const LinearProgressIndicator(
              minHeight: 2,
              color: AppColors.statusActive,
              backgroundColor: AppColors.divider,
            ),
          _FilterBar(
            selectedIndex: _filterIndex,
            allCount: all.length,
            activeCount: activeCount,
            deliveredCount: deliveredCount,
            l10n: l10n,
            onChanged: (i) => setState(() => _filterIndex = i),
          ),
          Expanded(
            child: filtered.isEmpty
                ? _EmptyState(l10n: l10n)
                : ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final s = filtered[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Dismissible(
                          key: Key(s.trackingCode),
                          direction: DismissDirection.endToStart,
                          background: _RemoveBackground(
                            label: l10n.removeShipment,
                          ),
                          confirmDismiss: (_) => _confirmRemove(l10n),
                          onDismissed: (_) => ref
                              .read(savedShipmentsProvider.notifier)
                              .remove(s.trackingCode),
                          child: BfShipmentCard(
                            trackingCode: s.trackingCode,
                            transportType: _transportType(s),
                            status: _parseStatus(s.lastStatus),
                            lastUpdated: s.lastSeen,
                            onTap: () => context.goNamed(
                              AppRoute.publicTimeline.name,
                              pathParameters: {'suffix': s.suffix},
                              queryParameters: {'instance': s.instanceUrl},
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  static TransportType _transportType(SavedShipment s) {
    final cacheKey = '${s.instanceUrl}:${s.suffix}';
    final cached = HiveService.shipments.get(cacheKey);
    if (cached == null) return TransportType.sea;
    return cached.transportType == 'air' ? TransportType.air : TransportType.sea;
  }

  static ShipmentStatus _parseStatus(String raw) {
    final s = raw.toLowerCase();
    if (s.contains('livré') || s.contains('done') || s.contains('delivered')) {
      return ShipmentStatus.delivered;
    }
    if (s.contains('annulé') || s.contains('cancelled') || s.contains('error')) {
      return ShipmentStatus.error;
    }
    if (s.contains('retard') || s.contains('warning')) {
      return ShipmentStatus.warning;
    }
    if (s.contains('archivé') || s.contains('archived')) {
      return ShipmentStatus.archived;
    }
    return ShipmentStatus.active;
  }
}

// ── Private widgets ───────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.selectedIndex,
    required this.allCount,
    required this.activeCount,
    required this.deliveredCount,
    required this.l10n,
    required this.onChanged,
  });

  final int selectedIndex;
  final int allCount;
  final int activeCount;
  final int deliveredCount;
  final AppLocalizations l10n;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          _FilterChip(
            label: '${l10n.filterAll} ($allCount)',
            selected: selectedIndex == 0,
            onTap: () => onChanged(0),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: '${l10n.filterActive} ($activeCount)',
            selected: selectedIndex == 1,
            onTap: () => onChanged(1),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: '${l10n.filterDelivered} ($deliveredCount)',
            selected: selectedIndex == 2,
            onTap: () => onChanged(2),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: selected ? AppColors.white : AppColors.statusArchived,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _RemoveBackground extends StatelessWidget {
  const _RemoveBackground({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: AppColors.statusError,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.delete_outline, color: Colors.white),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

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
            const Icon(
              Icons.inventory_2_outlined,
              size: 72,
              color: AppColors.statusArchived,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.followFirstShipment,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.statusArchived),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push(AppRoute.trackInput.path),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
              icon: const Icon(Icons.add),
              label: Text(l10n.enterTrackingCode, overflow: TextOverflow.visible),
            ),
          ],
        ),
      ),
    );
  }
}
