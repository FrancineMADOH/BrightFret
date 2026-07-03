import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_enums.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/http/api_exception.dart';
import '../../../core/router/app_router.dart';
import '../../../core/storage/token_storage.dart';
import '../../../shared/widgets/bf_bottom_nav.dart';
import '../../../shared/widgets/bf_error_screen.dart';
import '../../../shared/widgets/bf_forwarder_header.dart';
import '../../../shared/widgets/bf_forwarder_theme.dart';
import '../../../shared/widgets/bf_loading_indicator.dart';
import '../../../shared/widgets/bf_timeline_step.dart';
import '../../tracking/models/forwarder_info.dart';
import '../../tracking/models/public_shipment.dart';
import '../../tracking/providers/forwarder_info_provider.dart';
import '../../tracking/providers/saved_shipment_toggle_provider.dart';
import '../models/full_shipment.dart';
import '../models/cargo_summary.dart';
import '../providers/full_shipment_provider.dart';
import 'cargo_summary_screen.dart';

/// S08 — Full authenticated shipment detail.
/// Requires a valid token (enforced by the router auth guard and [fullShipmentProvider]).
class ShipmentDetailScreen extends ConsumerWidget {
  const ShipmentDetailScreen({
    super.key,
    required this.suffix,
    this.instanceUrl = '',
  });

  final String suffix;
  final String instanceUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shipmentAsync = ref.watch(fullShipmentProvider(suffix, instanceUrl));
    final forwarder = ref.watch(forwarderInfoProvider(instanceUrl)).valueOrNull
        ?? ForwarderInfo.fallback;
    final l10n = AppLocalizations.of(context)!;

    return BfForwarderTheme(
      instanceUrl: instanceUrl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(suffix, style: AppTextStyles.label.copyWith(color: AppColors.white)),
          leading: BackButton(
            onPressed: () =>
                context.canPop() ? context.pop() : context.go(AppRoute.home.path),
          ),
          actions: [
            if (shipmentAsync.valueOrNull != null)
              _SaveButton(
                trackingCode: shipmentAsync.valueOrNull!.trackingCode,
                suffix: suffix,
                instanceUrl: instanceUrl,
                status: shipmentAsync.valueOrNull!.status,
              ),
          ],
        ),
        bottomNavigationBar: const BfBottomNavBar(currentIndex: 1),
        body: shipmentAsync.when(
          loading: () => const BfLoadingIndicator(),
          error: (err, _) => _buildError(context, ref, err, l10n),
          data: (shipment) => RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(fullShipmentProvider(suffix, instanceUrl));
              await ref
                  .read(fullShipmentProvider(suffix, instanceUrl).future)
                  .catchError((_) => shipment);
            },
            child: _DetailBody(
              shipment: shipment,
              forwarder: forwarder,
              suffix: suffix,
              instanceUrl: instanceUrl,
              l10n: l10n,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError(
    BuildContext context,
    WidgetRef ref,
    Object error,
    AppLocalizations l10n,
  ) {
    if (error is UnauthorizedException) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!context.mounted) return;
        // Delete the stale token so the router redirect doesn't immediately
        // send us back to S08, breaking the S07→S08→S07 flicker loop.
        await ref.read(tokenStorageProvider).deleteToken(instanceUrl, suffix);
        if (context.mounted) {
          context.goNamed(
            AppRoute.phoneVerify.name,
            pathParameters: {'suffix': suffix},
            queryParameters: {'instance': instanceUrl},
          );
        }
      });
      return const BfLoadingIndicator();
    }
    return BfErrorScreen(
      icon: Icons.wifi_off_outlined,
      title: l10n.errorNetworkTitle,
      body: l10n.errorNetworkBody,
      actions: [
        BfErrorAction(
          label: l10n.retry,
          onTap: () =>
              ref.invalidate(fullShipmentProvider(suffix, instanceUrl)),
        ),
      ],
    );
  }
}

// ── Detail body ───────────────────────────────────────────────────────────────

class _DetailBody extends StatelessWidget {
  const _DetailBody({
    required this.shipment,
    required this.forwarder,
    required this.suffix,
    required this.instanceUrl,
    required this.l10n,
  });

  final FullShipment shipment;
  final ForwarderInfo forwarder;
  final String suffix;
  final String instanceUrl;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        BfForwarderHeader(
          forwarderName: forwarder.name,
          logoUrl: forwarder.logoUrl,
        ),
        const SizedBox(height: 16),
        _SummarySection(shipment: shipment, l10n: l10n),
        const Divider(height: 32),
        _PricingSection(shipment: shipment, l10n: l10n),
        const Divider(height: 32),
        _TimelineAccordion(events: shipment.events, l10n: l10n),
        const Divider(height: 32),
        _DocumentsSection(
          suffix: suffix,
          instanceUrl: instanceUrl,
          l10n: l10n,
          onViewAll: () => context.goNamed(
            AppRoute.documents.name,
            pathParameters: {'suffix': suffix},
            queryParameters: {'instance': instanceUrl},
          ),
        ),
        const Divider(height: 32),
        _MessagingSection(
          l10n: l10n,
          onTap: () => context.goNamed(
            AppRoute.messaging.name,
            pathParameters: {'suffix': suffix},
            queryParameters: {'instance': instanceUrl},
          ),
        ),
        if (shipment.cargo != null) ...[
          const Divider(height: 32),
          _CargoSection(
            cargo: shipment.cargo!,
            trackingCode: shipment.trackingCode,
            forwarderName: forwarder.name,
            l10n: l10n,
          ),
        ],
        const SizedBox(height: 16),
        Text(l10n.sectionClaim, style: AppTextStyles.heading2),
        const SizedBox(height: 8),
        _ClaimButton(
          hasActiveClaim: shipment.hasActiveClaim,
          l10n: l10n,
          onTap: () => context.goNamed(
            AppRoute.claim.name,
            pathParameters: {'suffix': suffix},
            queryParameters: {
              'instance': instanceUrl,
              if (shipment.hasActiveClaim) 'view': 'status',
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ── Section widgets ───────────────────────────────────────────────────────────

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.shipment, required this.l10n});

  final FullShipment shipment;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.sectionSummary, style: AppTextStyles.heading2),
        const SizedBox(height: 12),
        _Row('Client', shipment.clientName),
        _Row(l10n.transportAir.isEmpty ? 'Mode' : 'Mode',
            shipment.transportType == 'air' ? '✈️ ${l10n.transportAir}' : '🚢 ${l10n.transportSea}'),
        _Row('Origine', shipment.origin, maxLines: 2),
        _Row('Destination', shipment.destination, maxLines: 2),
        if (shipment.supplierRef != null)
          _Row('Réf. fournisseur', shipment.supplierRef!),
      ],
    );
  }
}

class _PricingSection extends StatelessWidget {
  const _PricingSection({required this.shipment, required this.l10n});

  final FullShipment shipment;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final isPaid = shipment.paymentStatus == 'confirmed';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.sectionPricing, style: AppTextStyles.heading2),
        const SizedBox(height: 12),
        _Row('Poids total', '${shipment.totalWeight.toStringAsFixed(2)} kg'),
        _Row('Volume total', '${shipment.totalVolume.toStringAsFixed(3)} m³'),
        _Row('Montant total', '${shipment.totalAmount.toStringAsFixed(0)} XAF'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Paiement', style: AppTextStyles.bodySmall.copyWith(color: AppColors.statusArchived)),
            Text(
              isPaid ? l10n.paymentConfirmed : l10n.paymentPending,
              style: AppTextStyles.label.copyWith(
                color: isPaid ? AppColors.statusDelivered : AppColors.statusWarning,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TimelineAccordion extends StatelessWidget {
  const _TimelineAccordion({required this.events, required this.l10n});

  final List<PublicEvent> events;
  final AppLocalizations l10n;

  static int _currentEventIndex(List<PublicEvent> events) {
    for (int i = events.length - 1; i >= 0; i--) {
      if (events[i].datetime != null) return i;
    }
    return -1;
  }

  static TimelineStepState _stepState(int index, int currentIdx) {
    if (currentIdx == -1) return TimelineStepState.future;
    if (index < currentIdx) return TimelineStepState.past;
    if (index == currentIdx) return TimelineStepState.current;
    return TimelineStepState.future;
  }

  @override
  Widget build(BuildContext context) {
    final currentIdx = _currentEventIndex(events);
    return ExpansionTile(
      title: Text(l10n.sectionTimeline, style: AppTextStyles.heading2),
      initiallyExpanded: false,
      childrenPadding: const EdgeInsets.only(top: 8),
      children: events.asMap().entries.map((entry) {
        final i = entry.key;
        final event = entry.value;
        return BfTimelineStep(
          stepState: _stepState(i, currentIdx),
          label: event.stage,
          datetime: event.datetime,
          note: event.note,
          isLast: i == events.length - 1,
        );
      }).toList(),
    );
  }
}

class _DocumentsSection extends StatelessWidget {
  const _DocumentsSection({
    required this.suffix,
    required this.instanceUrl,
    required this.l10n,
    required this.onViewAll,
  });

  final String suffix;
  final String instanceUrl;
  final AppLocalizations l10n;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.sectionDocuments, style: AppTextStyles.heading2),
            TextButton(
              onPressed: onViewAll,
              child: Text(l10n.viewAllDocuments),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          l10n.offlineDocumentsUnavailable,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.statusArchived),
        ),
      ],
    );
  }
}

class _MessagingSection extends StatelessWidget {
  const _MessagingSection({required this.l10n, required this.onTap});

  final AppLocalizations l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(l10n.sectionMessaging, style: AppTextStyles.heading2),
        TextButton(
          onPressed: onTap,
          child: Text(l10n.openMessaging),
        ),
      ],
    );
  }
}

class _ClaimButton extends StatelessWidget {
  const _ClaimButton({
    required this.hasActiveClaim,
    required this.l10n,
    required this.onTap,
  });

  final bool hasActiveClaim;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: hasActiveClaim ? AppColors.statusActive : AppColors.statusWarning,
        side: BorderSide(
          color: hasActiveClaim ? AppColors.statusActive : AppColors.statusWarning,
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Text(hasActiveClaim ? l10n.viewClaim : l10n.reportIssue),
    );
  }
}

// ── Cargo section ─────────────────────────────────────────────────────────────

class _CargoSection extends StatelessWidget {
  const _CargoSection({
    required this.cargo,
    required this.trackingCode,
    required this.forwarderName,
    required this.l10n,
  });

  final CargoSummary cargo;
  final String trackingCode;
  final String forwarderName;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.cargoSectionTitle, style: AppTextStyles.heading2),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.inventory_2_outlined),
          label: Text(l10n.cargoViewButton),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CargoSummaryScreen(
                cargo: cargo,
                trackingCode: trackingCode,
                forwarderName: forwarderName,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Save button (S08) ─────────────────────────────────────────────────────────

class _SaveButton extends ConsumerWidget {
  const _SaveButton({
    required this.trackingCode,
    required this.suffix,
    required this.instanceUrl,
    required this.status,
  });

  final String trackingCode;
  final String suffix;
  final String instanceUrl;
  final String status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSaved = ref.watch(savedShipmentToggleProvider(trackingCode));
    return IconButton(
      icon: Icon(isSaved ? Icons.star : Icons.star_border),
      color: AppColors.white,
      tooltip: AppLocalizations.of(context)!.saveShipment,
      onPressed: () => ref
          .read(savedShipmentToggleProvider(trackingCode).notifier)
          .toggle(suffix: suffix, instanceUrl: instanceUrl, status: status),
    );
  }
}

// ── Shared row widget ─────────────────────────────────────────────────────────

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.maxLines = 1});

  final String label;
  final String value;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.statusArchived)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              style: AppTextStyles.label,
              textAlign: TextAlign.end,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
