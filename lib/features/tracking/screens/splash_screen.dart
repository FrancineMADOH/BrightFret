import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers/onboarding_provider.dart';
import '../../../core/storage/hive_service.dart';
import '../../../core/utils/forwarder_resolver.dart';
import '../../../shared/widgets/bf_error_screen.dart';

const Duration _kMinSplashDuration = Duration(milliseconds: 1500);
const Duration _kFadeInDuration = Duration(milliseconds: 600);

/// S01 — Splash screen.
/// Loads [ForwarderResolver] from assets, enforces a 1.5s minimum display,
/// then routes to /onboarding (first launch) or /home.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: _kFadeInDuration);
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runInit());
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _runInit() async {
    final stopwatch = Stopwatch()..start();
    Object? initError;

    try {
      await ForwarderResolver.load();
    } catch (e) {
      initError = e;
    }

    // Guarantee minimum visual display time.
    final remaining = _kMinSplashDuration - stopwatch.elapsed;
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }

    if (!mounted) return;

    if (initError != null) {
      setState(() => _hasError = true);
      return;
    }

    final isOnboardingDone = ref.read(onboardingStateProvider);
    context.go(isOnboardingDone ? '/home' : '/onboarding');
  }

  Future<void> _resetAndRetry() async {
    await HiveService.prefs.clear();
    // Delete all Hive data and re-initialise from scratch.
    await HiveService.deleteAllData();

    if (!mounted) return;
    setState(() => _hasError = false);
    _runInit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _hasError ? Colors.white : AppColors.primary,
      body: _hasError ? _errorView() : _splashView(),
    );
  }

  Widget _splashView() => Center(
        child: RepaintBoundary(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Image.asset(
              'assets/images/logo_brightfret.png',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
          ),
        ),
      );

  Widget _errorView() => BfErrorScreen(
        icon: Icons.warning_amber_rounded,
        title: 'Erreur de démarrage',
        body: "Impossible de charger les données de l'application.",
        actions: [
          BfErrorAction(
            label: "Réinitialiser l'app",
            onTap: _resetAndRetry,
          ),
        ],
      );
}
