import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/onboarding_provider.dart';
import '../../../core/router/app_router.dart';

/// S02 — Three-slide onboarding shown on first launch.
/// On completion (last slide or skip), marks [onboardingStateProvider] as done
/// and lets the router redirect to /home automatically.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;
  int _currentPage = 0;
  bool _completing = false;

  static const int _pageCount = 3;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    if (_completing) return;
    setState(() => _completing = true);
    await ref.read(onboardingStateProvider.notifier).markDone();
    if (mounted) context.go(AppRoute.home.path);
  }

  void _goNext() {
    if (_currentPage < _pageCount - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _complete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isLast = _currentPage == _pageCount - 1;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(isLast: isLast, onSkip: _complete, l10n: l10n),
            Expanded(
              child: RepaintBoundary(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemCount: _pageCount,
                  itemBuilder: (_, i) => _OnboardingSlide(index: i, l10n: l10n),
                ),
              ),
            ),
            _DotIndicator(
              currentPage: _currentPage,
              pageCount: _pageCount,
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: _NextButton(
                isLast: isLast,
                completing: _completing,
                onPressed: _goNext,
                l10n: l10n,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ── Top bar with optional Skip ────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.isLast,
    required this.onSkip,
    required this.l10n,
  });

  final bool isLast;
  final VoidCallback onSkip;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AnimatedOpacity(
            opacity: isLast ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 250),
            child: IgnorePointer(
              ignoring: isLast,
              child: TextButton(
                onPressed: onSkip,
                child: Text(
                  l10n.onboardingSkip,
                  style: AppTextStyles.label
                      .copyWith(color: Colors.white70),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Slide ─────────────────────────────────────────────────────────────────────

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({required this.index, required this.l10n});

  final int index;
  final AppLocalizations l10n;

  static const _icons = <IconData>[
    Icons.local_shipping_outlined,
    Icons.description_outlined,
    Icons.chat_bubble_outline,
  ];

  String _title() => switch (index) {
        0 => l10n.onboardingSlide1Title,
        1 => l10n.onboardingSlide2Title,
        _ => l10n.onboardingSlide3Title,
      };

  String _body() => switch (index) {
        0 => l10n.onboardingSlide1Body,
        1 => l10n.onboardingSlide2Body,
        _ => l10n.onboardingSlide3Body,
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _SlideIcon(icon: _icons[index]),
          const SizedBox(height: 48),
          Text(
            _title(),
            style: AppTextStyles.heading1.copyWith(color: AppColors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            _body(),
            style: AppTextStyles.body.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Icon illustration ─────────────────────────────────────────────────────────

class _SlideIcon extends StatelessWidget {
  const _SlideIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 128,
      height: 128,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(30),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 60, color: AppColors.white),
    );
  }
}

// ── Dot indicator ─────────────────────────────────────────────────────────────

class _DotIndicator extends StatelessWidget {
  const _DotIndicator({required this.currentPage, required this.pageCount});

  final int currentPage;
  final int pageCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(pageCount, (i) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: i == currentPage ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: i == currentPage
                ? AppColors.white
                : Colors.white.withAlpha(80),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// ── Next / Get started button ─────────────────────────────────────────────────

class _NextButton extends StatelessWidget {
  const _NextButton({
    required this.isLast,
    required this.completing,
    required this.onPressed,
    required this.l10n,
  });

  final bool isLast;
  final bool completing;
  final VoidCallback onPressed;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: completing ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.primary,
          disabledBackgroundColor: Colors.white54,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: completing
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : Text(
                isLast ? l10n.onboardingGetStarted : l10n.onboardingNext,
                style: AppTextStyles.label.copyWith(color: AppColors.primary),
              ),
      ),
    );
  }
}
