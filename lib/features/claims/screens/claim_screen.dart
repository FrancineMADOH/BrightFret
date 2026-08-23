import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/http/api_exception.dart';
import '../../../core/router/app_router.dart';
import '../../../core/storage/token_storage.dart';
import '../../../shared/widgets/bf_bottom_nav.dart';
import '../../../shared/widgets/bf_loading_indicator.dart';
import '../../../shared/widgets/bf_primary_button.dart';
import '../models/claim_detail.dart';
import '../providers/claim_provider.dart';
import '../providers/claim_status_provider.dart';

/// S18 — Claim screen.
/// [showStatus]=false → S18A submission form.
/// [showStatus]=true  → S18B status view (fetches existing claim via GET).
class ClaimScreen extends ConsumerStatefulWidget {
  const ClaimScreen({
    super.key,
    required this.suffix,
    this.instanceUrl = '',
    this.showStatus = false,
    this.prefetchedClaim,
    this.declaredValue,
  });

  final String suffix;
  final String instanceUrl;

  /// When true, skips the form and shows the claim status view instead.
  final bool showStatus;

  /// When provided (from the claims list), S18B uses this data directly
  /// without fetching from the API.
  final ClaimDetail? prefetchedClaim;

  /// Ceiling for client-side validation. Passed by [ShipmentDetailScreen]
  /// from [FullShipment.declaredValue]. Null when navigating from [ClaimsListScreen].
  final double? declaredValue;

  @override
  ConsumerState<ClaimScreen> createState() => _ClaimScreenState();
}

class _ClaimScreenState extends ConsumerState<ClaimScreen> {
  String _claimType = 'lost';
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  String? _descError;
  String? _amountError;

  @override
  void dispose() {
    _descController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  bool _validate(AppLocalizations l10n) {
    final descOk = _descController.text.trim().isNotEmpty;
    final isDelayed = _claimType == 'delayed';

    final amount = isDelayed ? 0.0 : double.tryParse(_amountController.text.trim());
    final amountOk = isDelayed || (amount != null && amount > 0);
    final ceiling = widget.declaredValue;
    final withinCeiling = isDelayed ||
        ceiling == null ||
        ceiling <= 0 ||
        (amount != null && amount <= ceiling);

    setState(() {
      _descError = descOk ? null : l10n.claimDescriptionRequired;
      if (!isDelayed) {
        if (!amountOk) {
          _amountError = l10n.claimAmountInvalid;
        } else if (!withinCeiling) {
          _amountError = l10n.claimAmountExceedsValue(ceiling.toInt());
        } else {
          _amountError = null;
        }
      }
    });
    return descOk && amountOk && withinCeiling;
  }

  Future<void> _submit(AppLocalizations l10n) async {
    if (!_validate(l10n)) return;
    final isDelayed = _claimType == 'delayed';
    await ref
        .read(claimNotifierProvider(widget.suffix, widget.instanceUrl).notifier)
        .submit(
          claimType: _claimType,
          description: _descController.text.trim(),
          claimedAmount: isDelayed ? 0.0 : double.parse(_amountController.text.trim()),
        );
  }

  void _handleError(BuildContext context, Object error) {
    if (error is UnauthorizedException) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!context.mounted) return;
        await ref
            .read(tokenStorageProvider)
            .deleteToken(widget.instanceUrl, widget.suffix);
        if (context.mounted) {
          context.goNamed(
            AppRoute.phoneVerify.name,
            pathParameters: {'suffix': widget.suffix},
            queryParameters: {'instance': widget.instanceUrl},
          );
        }
      });
    }
  }

  VoidCallback get _onBack => () =>
      context.canPop() ? context.pop() : context.go(AppRoute.home.path);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // S18B: status view — skip the form entirely
    if (widget.showStatus || widget.prefetchedClaim != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.claimStatusTitle),
          leading: BackButton(onPressed: _onBack),
        ),
        bottomNavigationBar: const BfBottomNavBar(currentIndex: 1),
        body: _ClaimStatusBody(
          suffix: widget.suffix,
          instanceUrl: widget.instanceUrl,
          l10n: l10n,
          onBack: _onBack,
          prefetchedClaim: widget.prefetchedClaim,
        ),
      );
    }

    // S18A: submission form
    final claimAsync =
        ref.watch(claimNotifierProvider(widget.suffix, widget.instanceUrl));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.claimTitle),
        leading: BackButton(
          onPressed: _onBack,
        ),
      ),
      bottomNavigationBar: const BfBottomNavBar(currentIndex: 1),
      body: claimAsync.when(
        loading: () => const BfLoadingIndicator(),
        data: (reference) => reference != null
            ? _SuccessView(
                reference: reference,
                l10n: l10n,
                onBack: _onBack,
              )
            : _ClaimForm(
                claimType: _claimType,
                descController: _descController,
                amountController: _amountController,
                descError: _descError,
                amountError: _amountError,
                apiError: null,
                onTypeChanged: (t) => setState(() => _claimType = t),
                onSubmit: () => _submit(l10n),
                l10n: l10n,
              ),
        error: (err, _) {
          _handleError(context, err);
          if (err is UnauthorizedException) return const BfLoadingIndicator();
          return _ClaimForm(
            claimType: _claimType,
            descController: _descController,
            amountController: _amountController,
            descError: _descError,
            amountError: _amountError,
            apiError: _errorMessage(err, l10n),
            onTypeChanged: (t) => setState(() => _claimType = t),
            onSubmit: () => _submit(l10n),
            l10n: l10n,
          );
        },
      ),
    );
  }

  static String _errorMessage(Object err, AppLocalizations l10n) {
    if (err is ConflictException) return l10n.claimAlreadyExists;
    if (err is BadRequestException) return l10n.claimAmountExceedsDeclared;
    if (err is NetworkException) return l10n.errorNetworkBody;
    return l10n.claimSubmitError;
  }
}

// ── Claim form ────────────────────────────────────────────────────────────────

class _ClaimForm extends StatelessWidget {
  const _ClaimForm({
    required this.claimType,
    required this.descController,
    required this.amountController,
    required this.descError,
    required this.amountError,
    required this.apiError,
    required this.onTypeChanged,
    required this.onSubmit,
    required this.l10n,
  });

  final String claimType;
  final TextEditingController descController;
  final TextEditingController amountController;
  final String? descError;
  final String? amountError;
  final String? apiError;
  final ValueChanged<String> onTypeChanged;
  final VoidCallback onSubmit;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (apiError != null) ...[
            _ApiErrorBanner(message: apiError!),
            const SizedBox(height: 20),
          ],
          _SectionLabel(l10n.claimTypeLabel),
          const SizedBox(height: 8),
          _TypeSelector(
            selected: claimType,
            onChanged: onTypeChanged,
            l10n: l10n,
          ),
          const SizedBox(height: 24),
          _SectionLabel(l10n.claimDescriptionLabel),
          const SizedBox(height: 8),
          TextField(
            controller: descController,
            minLines: 3,
            maxLines: 6,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: l10n.claimDescriptionHint,
              errorText: descError,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          if (claimType != 'delayed') ...[
            const SizedBox(height: 24),
            _SectionLabel(l10n.claimAmountLabel),
            const SizedBox(height: 8),
            TextField(
              controller: amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                hintText: l10n.claimAmountHint,
                errorText: amountError,
                suffixText: 'XAF',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),
          BfPrimaryButton(
            label: l10n.claimSubmit,
            onPressed: onSubmit,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Type selector ─────────────────────────────────────────────────────────────

class _TypeSelector extends StatelessWidget {
  const _TypeSelector({
    required this.selected,
    required this.onChanged,
    required this.l10n,
  });

  final String selected;
  final ValueChanged<String> onChanged;
  final AppLocalizations l10n;

  static const _types = [
    ('lost', Icons.inventory_2_outlined),
    ('damaged', Icons.broken_image_outlined),
    ('delayed', Icons.timer_off_outlined),
  ];

  String _label(String type, AppLocalizations l10n) => switch (type) {
        'lost' => l10n.claimLost,
        'damaged' => l10n.claimDamaged,
        _ => l10n.claimDelay,
      };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _types.map((entry) {
        final (type, icon) = entry;
        final isSelected = selected == type;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withAlpha(15)
                : AppColors.surface,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.divider,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: RadioListTile<String>(
            value: type,
            groupValue: selected,
            onChanged: (v) => onChanged(v!),
            activeColor: AppColors.primary,
            title: Row(
              children: [
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(_label(type, l10n), style: AppTextStyles.label),
              ],
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        );
      }).toList(),
    );
  }
}

// ── Success view ──────────────────────────────────────────────────────────────

class _SuccessView extends StatelessWidget {
  const _SuccessView({
    required this.reference,
    required this.l10n,
    required this.onBack,
  });

  final String reference;
  final AppLocalizations l10n;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline,
                size: 80, color: AppColors.statusDelivered),
            const SizedBox(height: 24),
            Text(
              l10n.claimSuccessTitle,
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                l10n.claimSuccessRef(reference),
                style: AppTextStyles.label
                    .copyWith(color: AppColors.statusArchived),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.claimSuccessBody,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.statusArchived),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            BfPrimaryButton(
              label: l10n.backToShipment,
              onPressed: onBack,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(text, style: AppTextStyles.label);
}

// ── S18B — Claim status ───────────────────────────────────────────────────────

/// Watches [claimStatusProvider] and delegates to [_ClaimStatusView] or error states.
class _ClaimStatusBody extends ConsumerWidget {
  const _ClaimStatusBody({
    required this.suffix,
    required this.instanceUrl,
    required this.l10n,
    required this.onBack,
    this.prefetchedClaim,
  });

  final String suffix;
  final String instanceUrl;
  final AppLocalizations l10n;
  final VoidCallback onBack;
  final ClaimDetail? prefetchedClaim;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use prefetched data from the list screen when available — avoids a redundant API call.
    final claimAsync = prefetchedClaim != null
        ? AsyncData(prefetchedClaim!)
        : ref.watch(claimStatusProvider(suffix, instanceUrl));

    return claimAsync.when(
      loading: () => const BfLoadingIndicator(),
      error: (err, _) => _buildError(context, ref, err),
      data: (claim) {
        final messenger = ScaffoldMessenger.of(context);
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(claimStatusProvider(suffix, instanceUrl));
            await ref
                .read(claimStatusProvider(suffix, instanceUrl).future)
                .catchError((_) => claim);
            messenger.showSnackBar(
              SnackBar(content: Text(l10n.refreshSuccess)),
            );
          },
          child: _ClaimStatusView(
            claim: claim,
            l10n: l10n,
            onBack: onBack,
            onNewClaim: _isTerminal(claim.state)
                ? () => context.goNamed(
                      AppRoute.claim.name,
                      pathParameters: {'suffix': suffix},
                      queryParameters: {'instance': instanceUrl},
                    )
                : null,
          ),
        );
      },
    );
  }

  static bool _isTerminal(String state) =>
      state == 'refused' || state == 'accepted';

  Widget _buildError(BuildContext context, WidgetRef ref, Object err) {
    final msg = err is NotFoundException
        ? l10n.noClaimFound
        : err is NetworkException
            ? l10n.errorNetworkBody
            : l10n.claimSubmitError;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_off_outlined,
                size: 64, color: AppColors.statusArchived.withAlpha(120)),
            const SizedBox(height: 20),
            Text(msg,
                style: AppTextStyles.body
                    .copyWith(color: AppColors.statusArchived),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            BfPrimaryButton(
              label: l10n.retry,
              onPressed: () =>
                  ref.invalidate(claimStatusProvider(suffix, instanceUrl)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Displays the full claim detail: state badge, reference, dates, resolution.
class _ClaimStatusView extends StatelessWidget {
  const _ClaimStatusView({
    required this.claim,
    required this.l10n,
    required this.onBack,
    this.onNewClaim,
  });

  final ClaimDetail claim;
  final AppLocalizations l10n;
  final VoidCallback onBack;
  final VoidCallback? onNewClaim;

  static String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }

  Color _stateColor() => switch (claim.state) {
        'open' => AppColors.statusWarning,
        'under_review' => AppColors.statusActive,
        'accepted' => AppColors.statusDelivered,
        'refused' => AppColors.statusError,
        _ => AppColors.statusArchived,
      };

  String _stateLabel() => switch (claim.state) {
        'open' => l10n.claimStateOpen,
        'under_review' => l10n.claimStateUnderReview,
        'accepted' => l10n.claimStateAccepted,
        'refused' => l10n.claimStateRefused,
        _ => claim.state,
      };

  String _typeLabel() => switch (claim.claimType) {
        'lost' => l10n.claimLost,
        'damaged' => l10n.claimDamaged,
        _ => l10n.claimDelay,
      };

  @override
  Widget build(BuildContext context) {
    final color = _stateColor();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StateHeader(
            stateLabel: _stateLabel(),
            reference: claim.reference,
            color: color,
          ),
          const SizedBox(height: 24),
          _DetailRow(l10n.claimTypeDisplayLabel, _typeLabel()),
          const Divider(height: 24),
          _DetailRow(l10n.claimDescriptionLabel, claim.description),
          const Divider(height: 24),
          _DetailRow(l10n.claimOpenDate, _formatDate(claim.openDate)),
          if (claim.closeDate != null) ...[
            const Divider(height: 24),
            _DetailRow(l10n.claimCloseDate, _formatDate(claim.closeDate)),
          ],
          if (claim.resolutionNote != null &&
              claim.resolutionNote!.isNotEmpty) ...[
            const Divider(height: 24),
            _DetailRow(l10n.claimResolutionNote, claim.resolutionNote!),
          ],
          if (claim.creditAmount != null) ...[
            const Divider(height: 24),
            _DetailRow(
              l10n.claimCreditAmount,
              '${claim.creditAmount!.toStringAsFixed(0)} XAF',
            ),
          ],
          const SizedBox(height: 32),
          BfPrimaryButton(label: l10n.backToShipment, onPressed: onBack),
          if (onNewClaim != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onNewClaim,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.statusWarning,
                side: const BorderSide(color: AppColors.statusWarning),
                padding: const EdgeInsets.symmetric(vertical: 14),
                minimumSize: const Size.fromHeight(0),
              ),
              child: Text(l10n.fileNewClaim),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _StateHeader extends StatelessWidget {
  const _StateHeader({
    required this.stateLabel,
    required this.reference,
    required this.color,
  });

  final String stateLabel;
  final String reference;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        children: [
          Icon(Icons.assignment_outlined, color: color, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    stateLabel,
                    style: AppTextStyles.caption
                        .copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 6),
                Text(reference,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.statusArchived)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                AppTextStyles.caption.copyWith(color: AppColors.statusArchived)),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.body),
      ],
    );
  }
}

// ── API error banner ──────────────────────────────────────────────────────────

class _ApiErrorBanner extends StatelessWidget {
  const _ApiErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.statusError.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.statusError.withAlpha(80)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline,
              color: AppColors.statusError, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.statusError),
            ),
          ),
        ],
      ),
    );
  }
}
