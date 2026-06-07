import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/forwarder_resolver.dart';
import '../../../core/utils/tracking_code_parser.dart';
import '../../../shared/widgets/bf_bottom_nav.dart';
import '../../../shared/widgets/bf_primary_button.dart';
import '../providers/code_history_provider.dart';

// ── Mask ──────────────────────────────────────────────────────────────────────

String _applyTrackingMask(String raw) {
  final clean = raw.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
  final limited = clean.length > 13 ? clean.substring(0, 13) : clean;
  if (limited.length <= 3) return limited;
  if (limited.length <= 7) {
    return '${limited.substring(0, 3)}-${limited.substring(3)}';
  }
  return '${limited.substring(0, 3)}-'
      '${limited.substring(3, 7)}-'
      '${limited.substring(7)}';
}

class _TrackingCodeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final masked = _applyTrackingMask(newValue.text);
    return TextEditingValue(
      text: masked,
      selection: TextSelection.collapsed(offset: masked.length),
    );
  }
}

// ── Validation ────────────────────────────────────────────────────────────────

enum _ValidationStatus { neutral, known, unknown, invalid }

class _ValidationResult {
  const _ValidationResult({required this.status, this.parsed, this.entry});

  final _ValidationStatus status;
  final ParsedTrackingCode? parsed;
  final ForwarderEntry? entry;

  bool get canSubmit =>
      status == _ValidationStatus.known ||
      status == _ValidationStatus.unknown;
}

// ── Screen ────────────────────────────────────────────────────────────────────

/// S04 — Manual tracking code entry with auto-mask and real-time
/// forwarder validation.
class CodeInputScreen extends ConsumerStatefulWidget {
  const CodeInputScreen({super.key});

  @override
  ConsumerState<CodeInputScreen> createState() => _CodeInputScreenState();
}

class _CodeInputScreenState extends ConsumerState<CodeInputScreen> {
  late final TextEditingController _controller;
  String _value = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() => _value = _controller.text);
  }

  _ValidationResult get _validation {
    final rawLen = _value.replaceAll('-', '').length;
    if (rawLen < 13) {
      return const _ValidationResult(status: _ValidationStatus.neutral);
    }
    final parsed = TrackingCodeParser.parse(_value);
    if (parsed == null) {
      return const _ValidationResult(status: _ValidationStatus.invalid);
    }
    final entry = ForwarderResolver.resolve(parsed.prefix);
    return _ValidationResult(
      status:
          entry != null ? _ValidationStatus.known : _ValidationStatus.unknown,
      parsed: parsed,
      entry: entry,
    );
  }

  Future<void> _submit() async {
    final v = _validation;
    if (!v.canSubmit) return;
    await ref.read(codeHistoryProvider.notifier).add(_value);
    if (!mounted) return;
    if (v.status == _ValidationStatus.known) {
      context.goNamed(
        AppRoute.publicTimeline.name,
        pathParameters: {'suffix': v.parsed!.suffix},
        queryParameters: {'instance': v.entry!.url},
      );
    } else {
      context.go(AppRoute.errorUnknownForwarder.path);
    }
  }

  void _prefill(String code) {
    final masked = _applyTrackingMask(code);
    _controller.value = TextEditingValue(
      text: masked,
      selection: TextSelection.collapsed(offset: masked.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final v = _validation;
    final history = ref.watch(codeHistoryProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.codeInputTitle),
        leading: BackButton(
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(AppRoute.home.path),
        ),
      ),
      bottomNavigationBar: const BfBottomNavBar(currentIndex: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _inputField(),
              const SizedBox(height: 8),
              _ValidationFeedback(
                status: v.status,
                forwarderName: v.entry?.name,
              ),
              const SizedBox(height: 16),
              BfPrimaryButton(
                label: l10n.trackThisShipment,
                onPressed: v.canSubmit ? () => _submit() : null,
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => context.push(AppRoute.trackScan.path),
                icon: const Icon(Icons.qr_code_scanner),
                label: Text(l10n.scanQrCode),
              ),
              if (history.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(l10n.recentCodes, style: AppTextStyles.heading2),
                const SizedBox(height: 8),
                ...history.map(
                  (code) => _HistoryItem(
                    code: code,
                    onTap: () => _prefill(code),
                    onDelete: () =>
                        ref.read(codeHistoryProvider.notifier).remove(code),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField() => TextField(
        controller: _controller,
        inputFormatters: [_TrackingCodeInputFormatter()],
        textCapitalization: TextCapitalization.characters,
        keyboardType: TextInputType.text,
        decoration: const InputDecoration(
          hintText: 'KMG-2026-A7X9K2',
          prefixIcon: Icon(Icons.tag),
        ),
        style: AppTextStyles.label,
      );
}

// ── Private widgets ───────────────────────────────────────────────────────────

class _ValidationFeedback extends StatelessWidget {
  const _ValidationFeedback({required this.status, this.forwarderName});

  final _ValidationStatus status;
  final String? forwarderName;

  @override
  Widget build(BuildContext context) {
    if (status == _ValidationStatus.neutral) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;

    final (icon, color, text) = switch (status) {
      _ValidationStatus.known => (
          Icons.check_circle_outline,
          AppColors.statusDelivered,
          l10n.forwarderRecognized(forwarderName ?? ''),
        ),
      _ValidationStatus.unknown => (
          Icons.warning_amber_rounded,
          AppColors.statusWarning,
          l10n.forwarderUnknown,
        ),
      _ValidationStatus.invalid => (
          Icons.error_outline,
          AppColors.statusError,
          l10n.invalidCodeFormat,
        ),
      _ValidationStatus.neutral => (
          Icons.info_outline,
          AppColors.statusArchived,
          '',
        ),
    };

    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.caption.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}

class _HistoryItem extends StatelessWidget {
  const _HistoryItem({
    required this.code,
    required this.onTap,
    required this.onDelete,
  });

  final String code;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            const Icon(
              Icons.history,
              size: 18,
              color: AppColors.statusArchived,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(code, style: AppTextStyles.label)),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.close, size: 18),
              color: AppColors.statusArchived,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}
