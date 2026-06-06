import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_enums.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/http/api_exception.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/bf_error_screen.dart';
import '../../../shared/widgets/bf_forwarder_header.dart';
import '../../../shared/widgets/bf_forwarder_theme.dart';
import '../../../shared/widgets/bf_loading_indicator.dart';
import '../../../shared/widgets/bf_primary_button.dart';
import '../../../shared/widgets/bf_timeline_step.dart';
import '../models/forwarder_info.dart';
import '../models/public_shipment.dart';
import '../providers/forwarder_info_provider.dart';
import '../providers/saved_shipment_toggle_provider.dart';
import '../providers/shipment_tracking_provider.dart';

/// S06 — Public shipment timeline.
/// Shows forwarder branding, progress bar, transit event list, and CTA to
/// unlock authenticated detail (S07).
class PublicTimelineScreen extends ConsumerWidget {
  const PublicTimelineScreen({
    super.key,
    required this.suffix,
    this.instanceUrl = '',
  });

  final String suffix;
  final String instanceUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackingAsync =
        ref.watch(shipmentTrackingProvider(suffix, instanceUrl));
    final forwarder =
        ref.watch(forwarderInfoProvider(instanceUrl)).valueOrNull ??
            ForwarderInfo.fallback;
    final l10n = AppLocalizations.of(context)!;

    return BfForwarderTheme(
      instanceUrl: instanceUrl,
      child: Scaffold(
        appBar: _buildAppBar(context, trackingAsync),
        body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(shipmentTrackingProvider(suffix, instanceUrl));
          try {
            await ref
                .read(shipmentTrackingProvider(suffix, instanceUrl).future);
          } catch (_) {}
        },
        child: trackingAsync.when(
          loading: () => const BfLoadingIndicator(),
          error: (err, _) => _buildErrorBody(context, ref, err, l10n),
          data: (result) => _TimelineBody(
            result: result,
            forwarder: forwarder,
            suffix: suffix,
            instanceUrl: instanceUrl,
            l10n: l10n,
          ),
        ),
      ),
    ),    // Scaffold
    );    // BfForwarderTheme
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AsyncValue<TrackingResult> async,
  ) {
    final shipment = async.valueOrNull?.shipment;
    return AppBar(
      leading: BackButton(
        onPressed: () =>
            context.canPop() ? context.pop() : context.go(AppRoute.home.path),
      ),
      title: shipment != null
          ? Text(
              shipment.trackingCode,
              style: AppTextStyles.label.copyWith(color: AppColors.white),
            )
          : null,
      actions: shipment != null
          ? [
              _SaveButton(
                trackingCode: shipment.trackingCode,
                suffix: suffix,
                instanceUrl: instanceUrl,
                status: shipment.status,
              ),
            ]
          : null,
    );
  }

  Widget _buildErrorBody(
    BuildContext context,
    WidgetRef ref,
    Object error,
    AppLocalizations l10n,
  ) {
    if (error is NetworkException) {
      return BfErrorScreen(
        icon: Icons.wifi_off_outlined,
        title: l10n.errorNetworkTitle,
        body: l10n.errorNetworkBody,
        actions: [
          BfErrorAction(
            label: l10n.retry,
            onTap: () =>
                ref.invalidate(shipmentTrackingProvider(suffix, instanceUrl)),
          ),
        ],
      );
    }
    if (error is NotFoundException) {
      return BfErrorScreen(
        icon: Icons.search_off_outlined,
        title: l10n.errorNotFoundTitle,
        body: l10n.errorNotFoundBody,
        actions: [
          BfErrorAction(
            label: l10n.enterTrackingCode,
            onTap: () => context.go(AppRoute.trackInput.path),
          ),
        ],
      );
    }
    return BfErrorScreen(
      title: l10n.errorNetworkTitle,
      body: l10n.errorNetworkBody,
      actions: [
        BfErrorAction(
          label: l10n.retry,
          onTap: () =>
              ref.invalidate(shipmentTrackingProvider(suffix, instanceUrl)),
        ),
      ],
    );
  }
}

// ── Save button ───────────────────────────────────────────────────────────────

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

// ── Timeline body ─────────────────────────────────────────────────────────────

class _TimelineBody extends StatelessWidget {
  const _TimelineBody({
    required this.result,
    required this.forwarder,
    required this.suffix,
    required this.instanceUrl,
    required this.l10n,
  });

  final TrackingResult result;
  final ForwarderInfo forwarder;
  final String suffix;
  final String instanceUrl;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final shipment = result.shipment;
    final events = shipment.events;
    final currentIdx = _currentEventIndex(events);
    final progress =
        events.isEmpty || currentIdx == -1 ? 0.0 : (currentIdx + 1) / events.length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        BfForwarderHeader(
          forwarderName: forwarder.name,
          logoUrl: forwarder.logoUrl,
        ),
        if (result.isFromCache) ...[
          const SizedBox(height: 12),
          _OfflineBanner(cachedAt: result.cachedAt!, l10n: l10n),
        ],
        const SizedBox(height: 16),
        _ShipmentSummary(shipment: shipment),
        const SizedBox(height: 12),
        _ProgressBar(progress: progress, reached: currentIdx + 1, total: events.length),
        const Divider(height: 32),
        if (events.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                l10n.noEventsYet,
                style:
                    AppTextStyles.bodySmall.copyWith(color: AppColors.statusArchived),
              ),
            ),
          )
        else
          ...events.asMap().entries.map(
                (entry) => BfTimelineStep(
                  stepState: _stepState(entry.key, currentIdx),
                  label: entry.value.stage,
                  datetime: entry.value.datetime,
                  note: entry.value.note,
                  isLast: entry.key == events.length - 1,
                ),
              ),
        const SizedBox(height: 24),
        BfPrimaryButton(
          label: l10n.unlockDetails,
          onPressed: () => context.pushNamed(
            AppRoute.phoneVerify.name,
            pathParameters: {'suffix': suffix},
            queryParameters: {'instance': instanceUrl},
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

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
}

// ── Private sub-widgets ───────────────────────────────────────────────────────

class _ShipmentSummary extends StatelessWidget {
  const _ShipmentSummary({required this.shipment});

  final PublicShipment shipment;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          shipment.transportType == 'air'
              ? Icons.flight
              : Icons.directions_boat_outlined,
          color: AppColors.statusArchived,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '${shipment.origin} → ${shipment.destination}',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.statusArchived),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (shipment.expectedDate != null)
          Text(
            _fmtDate(shipment.expectedDate!),
            style: AppTextStyles.caption.copyWith(color: AppColors.statusArchived),
          ),
      ],
    );
  }

  static String _fmtDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.progress,
    required this.reached,
    required this.total,
  });

  final double progress;
  final int reached;
  final int total;

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$percent %', style: AppTextStyles.label),
            Text(
              '$reached / $total',
              style: AppTextStyles.caption.copyWith(color: AppColors.statusArchived),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppColors.divider,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.cachedAt, required this.l10n});

  final DateTime cachedAt;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final d = cachedAt.day.toString().padLeft(2, '0');
    final mo = cachedAt.month.toString().padLeft(2, '0');
    final h = cachedAt.hour.toString().padLeft(2, '0');
    final mi = cachedAt.minute.toString().padLeft(2, '0');
    final label = '$d/$mo/${cachedAt.year} $h:$mi';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.statusWarning.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.statusWarning.withAlpha(100)),
      ),
      child: Text(
        l10n.offlineDataBanner(label),
        style: AppTextStyles.caption.copyWith(color: AppColors.statusWarning),
      ),
    );
  }
}
