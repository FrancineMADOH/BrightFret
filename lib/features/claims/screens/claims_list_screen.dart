import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/bf_bottom_nav.dart';
import '../../../shared/widgets/bf_loading_indicator.dart';
import '../../../shared/widgets/bf_primary_button.dart';
import '../models/claim_detail.dart';
import '../providers/claims_list_provider.dart';

/// Lists all claims for a shipment, newest first.
/// Tapping a claim navigates to S18B with the claim data as extra (no re-fetch).
/// A "New claim" button is shown when no active claim exists.
class ClaimsListScreen extends ConsumerWidget {
  const ClaimsListScreen({
    super.key,
    required this.suffix,
    this.instanceUrl = '',
  });

  final String suffix;
  final String instanceUrl;

  static const _activeStates = {'open', 'under_review'};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final claimsAsync = ref.watch(claimsListProvider(suffix, instanceUrl));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myClaims),
        leading: BackButton(
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(AppRoute.home.path),
        ),
      ),
      bottomNavigationBar: const BfBottomNavBar(currentIndex: 1),
      body: claimsAsync.when(
        loading: () => const BfLoadingIndicator(),
        error: (err, _) => _buildError(context, ref, l10n),
        data: (claims) => _buildList(context, claims, l10n),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    List<ClaimDetail> claims,
    AppLocalizations l10n,
  ) {
    final hasActive = claims.any((c) => _activeStates.contains(c.state));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (claims.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: Text(
                l10n.noClaims,
                style: AppTextStyles.body.copyWith(color: AppColors.statusArchived),
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          ...claims.map((claim) => _ClaimTile(
                claim: claim,
                onTap: () => context.pushNamed(
                  AppRoute.claim.name,
                  pathParameters: {'suffix': suffix},
                  queryParameters: {
                    'instance': instanceUrl,
                    'view': 'status',
                  },
                  extra: claim,
                ),
              )),
        if (!hasActive) ...[
          const SizedBox(height: 24),
          BfPrimaryButton(
            label: l10n.newClaim,
            onPressed: () => context.pushNamed(
              AppRoute.claim.name,
              pathParameters: {'suffix': suffix},
              queryParameters: {'instance': instanceUrl},
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildError(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_outlined,
                size: 48, color: AppColors.statusArchived),
            const SizedBox(height: 16),
            Text(l10n.errorNetworkBody,
                style: AppTextStyles.body.copyWith(color: AppColors.statusArchived),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            BfPrimaryButton(
              label: l10n.retry,
              onPressed: () => ref.invalidate(claimsListProvider(suffix, instanceUrl)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClaimTile extends StatelessWidget {
  const _ClaimTile({required this.claim, required this.onTap});

  final ClaimDetail claim;
  final VoidCallback onTap;

  Color get _stateColor => switch (claim.state) {
        'open' => AppColors.statusWarning,
        'under_review' => AppColors.statusActive,
        'accepted' => AppColors.statusDelivered,
        'refused' => AppColors.statusError,
        _ => AppColors.statusArchived,
      };

  String _stateLabel(AppLocalizations l10n) => switch (claim.state) {
        'open' => l10n.claimStateOpen,
        'under_review' => l10n.claimStateUnderReview,
        'accepted' => l10n.claimStateAccepted,
        'refused' => l10n.claimStateRefused,
        _ => claim.state,
      };

  String _typeLabel(AppLocalizations l10n) => switch (claim.claimType) {
        'lost' => l10n.claimLost,
        'damaged' => l10n.claimDamaged,
        _ => l10n.claimDelay,
      };

  static String _fmtDate(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = _stateColor;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(claim.reference, style: AppTextStyles.label),
                    const SizedBox(height: 4),
                    Text(
                      _typeLabel(l10n),
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.statusArchived),
                    ),
                    if (claim.openDate != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        _fmtDate(claim.openDate),
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.statusArchived),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withAlpha(80)),
                ),
                child: Text(
                  _stateLabel(l10n),
                  style: AppTextStyles.caption.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: AppColors.statusArchived, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
