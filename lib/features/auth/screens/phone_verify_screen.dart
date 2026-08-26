import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/http/api_exception.dart';
import '../../../core/http/dio_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/storage/hive_service.dart';
import '../../../core/storage/token_storage.dart';
import '../../../shared/widgets/bf_bottom_nav.dart';
import '../services/auth_service.dart';

/// S07 — Phone verification: 4-digit PIN entry, 24h token stored in Hive.
/// Auto-skipped if a valid token already exists for this suffix.
class PhoneVerifyScreen extends ConsumerStatefulWidget {
  const PhoneVerifyScreen({
    super.key,
    required this.suffix,
    this.instanceUrl = '',
  });

  final String suffix;
  final String instanceUrl;

  @override
  ConsumerState<PhoneVerifyScreen> createState() => _PhoneVerifyScreenState();
}

class _PhoneVerifyScreenState extends ConsumerState<PhoneVerifyScreen> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(4, (_) => FocusNode());

  bool _isLoading = false;
  String? _errorMessage;
  int _failureCount = 0;
  DateTime? _blockedUntil;
  Timer? _blockTimer;
  Duration _remaining = Duration.zero;

  // Hive prefs keys scoped to this suffix so multiple shipments don't collide.
  String get _hiveKeyUntil => 'lockout_until_${widget.suffix}';
  String get _hiveKeyCount => 'lockout_count_${widget.suffix}';

  String get _pin => _controllers.map((c) => c.text).join();
  bool get _isBlocked =>
      _blockedUntil != null && DateTime.now().isBefore(_blockedUntil!);

  @override
  void initState() {
    super.initState();
    // Token-skip logic is now handled by the router redirect (RouterNotifier).
    // S07 only renders when no valid token exists — no per-screen check needed.
    _restorePersistedLockout();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isBlocked) _focusNodes[0].requestFocus();
    });
  }

  void _restorePersistedLockout() {
    final prefs = HiveService.prefs;
    final storedMs = prefs.get(_hiveKeyUntil) as int?;
    if (storedMs == null) return;
    final until = DateTime.fromMillisecondsSinceEpoch(storedMs);
    if (!DateTime.now().isBefore(until)) {
      // Lockout has expired — clean up stale keys.
      prefs.delete(_hiveKeyUntil);
      prefs.delete(_hiveKeyCount);
      return;
    }
    _failureCount = (prefs.get(_hiveKeyCount) as int?) ?? 3;
    _blockedUntil = until;
    _remaining = until.difference(DateTime.now());
    // Restart the countdown timer.
    _blockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      final remaining = _blockedUntil!.difference(DateTime.now());
      if (remaining.isNegative) {
        timer.cancel();
        HiveService.prefs.delete(_hiveKeyUntil);
        HiveService.prefs.delete(_hiveKeyCount);
        setState(() {
          _blockedUntil = null;
          _errorMessage = null;
          _failureCount = 0;
          _remaining = Duration.zero;
        });
        _focusNodes[0].requestFocus();
      } else {
        setState(() => _remaining = remaining);
      }
    });
  }

  @override
  void dispose() {
    _blockTimer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    if (_pin.length == 4 && !_isBlocked && !_isLoading) {
      _submit();
    }
  }

  Future<void> _submit() async {
    if (_isLoading || _isBlocked) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final dio = ref.read(dioForInstanceProvider(widget.instanceUrl));
      final token = await AuthService(dio).verifyPhone(
        suffix: widget.suffix,
        phoneSuffix: _pin,
        instanceUrl: widget.instanceUrl,
      );
      await ref.read(tokenStorageProvider).saveToken(token);
      // Clear any persisted lockout state on successful auth.
      HiveService.prefs.delete(_hiveKeyUntil);
      HiveService.prefs.delete(_hiveKeyCount);
      if (!mounted) return;
      context.goNamed(
        AppRoute.shipmentDetail.name,
        pathParameters: {'suffix': widget.suffix},
        queryParameters: {'instance': widget.instanceUrl},
      );
    } on UnauthorizedException {
      if (mounted) _handleFailure(l10n.verificationError);
    } on RateLimitException {
      if (mounted) _handleBlock(l10n.tooManyAttempts);
    } on ApiException {
      if (mounted) _handleFailure(l10n.verificationError);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleFailure(String message) {
    _failureCount++;
    _resetBoxes();
    if (_failureCount >= 3) {
      _handleBlock(AppLocalizations.of(context)!.tooManyAttempts);
    } else {
      setState(() => _errorMessage = message);
    }
  }

  void _handleBlock(String message) {
    final until = DateTime.now().add(const Duration(minutes: 10));
    // Persist so the countdown survives navigation away and back.
    HiveService.prefs.put(_hiveKeyUntil, until.millisecondsSinceEpoch);
    HiveService.prefs.put(_hiveKeyCount, _failureCount);
    setState(() {
      _blockedUntil = until;
      _errorMessage = message;
      _remaining = const Duration(minutes: 10);
    });
    _blockTimer?.cancel();
    _blockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final remaining = _blockedUntil!.difference(DateTime.now());
      if (remaining.isNegative) {
        timer.cancel();
        HiveService.prefs.delete(_hiveKeyUntil);
        HiveService.prefs.delete(_hiveKeyCount);
        setState(() {
          _blockedUntil = null;
          _errorMessage = null;
          _failureCount = 0;
          _remaining = Duration.zero;
        });
        _focusNodes[0].requestFocus();
      } else {
        setState(() => _remaining = remaining);
      }
    });
  }

  void _resetBoxes() {
    for (final c in _controllers) {
      c.clear();
    }
    if (mounted) _focusNodes[0].requestFocus();
  }

  void _showHelpSheet(AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.helpNoPhoneTitle, style: AppTextStyles.heading2),
            const SizedBox(height: 12),
            Text(l10n.helpNoPhoneBody, style: AppTextStyles.body),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.phoneVerification),
        leading: BackButton(
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(AppRoute.home.path),
        ),
      ),
      bottomNavigationBar: const BfBottomNavBar(currentIndex: 1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.phoneVerification, style: AppTextStyles.heading1),
              const SizedBox(height: 12),
              Text(
                l10n.enterPhoneLastDigits,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.statusArchived,
                ),
              ),
              const SizedBox(height: 40),
              _buildPinArea(l10n),
              const SizedBox(height: 16),
              if (_errorMessage != null && !_isBlocked)
                Text(
                  _errorMessage!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.statusError,
                  ),
                  textAlign: TextAlign.center,
                ),
              const Spacer(),
              TextButton(
                onPressed: () => _showHelpSheet(l10n),
                child: Text(l10n.helpNoPhone),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinArea(AppLocalizations l10n) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (_isBlocked) {
      return _BlockedView(remaining: _remaining, l10n: l10n);
    }
    return _PinRow(
      controllers: _controllers,
      focusNodes: _focusNodes,
      onChanged: _onDigitChanged,
    );
  }
}

// ── Private widgets ───────────────────────────────────────────────────────────

class _PinRow extends StatelessWidget {
  const _PinRow({
    required this.controllers,
    required this.focusNodes,
    required this.onChanged,
  });

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final void Function(int, String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        4,
        (i) => Padding(
          padding: EdgeInsets.only(right: i < 3 ? 16 : 0),
          child: _PinBox(
            controller: controllers[i],
            focusNode: focusNodes[i],
            onChanged: (v) => onChanged(i, v),
          ),
        ),
      ),
    );
  }
}

class _PinBox extends StatelessWidget {
  const _PinBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 72,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        maxLength: 1,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: AppTextStyles.heading1,
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.divider, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          filled: true,
          fillColor: AppColors.surface,
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class _BlockedView extends StatelessWidget {
  const _BlockedView({required this.remaining, required this.l10n});

  final Duration remaining;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final min = remaining.inMinutes.toString().padLeft(2, '0');
    final sec = (remaining.inSeconds % 60).toString().padLeft(2, '0');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.lock_clock_outlined,
          size: 48,
          color: AppColors.statusWarning,
        ),
        const SizedBox(height: 16),
        Text(
          l10n.tooManyAttempts,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.statusWarning,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          '$min:$sec',
          style: AppTextStyles.heading1.copyWith(color: AppColors.statusWarning),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
