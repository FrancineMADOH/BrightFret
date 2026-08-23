import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/providers/updates_provider.dart';
import '../../../core/storage/hive_service.dart';
import '../../../shared/widgets/bf_bottom_nav.dart';

/// S14 — Settings screen.
/// Language selection (FR/EN) persists via [LocaleState].
/// Cache clear wipes shipment + forwarder caches only (saved shipments preserved).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const String _kAppVersion = '1.0.0';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeStateProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tabSettings),
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: const BfBottomNavBar(currentIndex: 3),
      body: ListView(
        children: [
          _SectionHeader(l10n.settingsLanguageSection),
          _LanguageSelector(
            currentCode: currentLocale.languageCode,
            onChanged: (code) =>
                ref.read(localeStateProvider.notifier).setLocale(code),
            l10n: l10n,
          ),
          const Divider(height: 1),
          _SectionHeader(l10n.settingsDataSection),
          _CacheTile(
            l10n: l10n,
            onTap: () => _confirmClearCache(context, ref, l10n),
          ),
          const Divider(height: 1),
          _SectionHeader(l10n.settingsAboutSection),
          _InfoTile(
            icon: Icons.info_outline,
            label: l10n.settingsVersion,
            value: _kAppVersion,
          ),
          _InfoTile(
            icon: Icons.local_shipping_outlined,
            label: 'BrightWill',
            value: '© 2026',
          ),
          _NavTile(
            icon: Icons.info_outline,
            label: l10n.aboutTitle,
            onTap: () => context.pushNamed(AppRoute.about.name),
          ),
          _NavTile(
            icon: Icons.description_outlined,
            label: l10n.termsTitle,
            onTap: () => context.pushNamed(AppRoute.terms.name),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClearCache(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.settingsClearCacheTitle),
        content: Text(l10n.settingsClearCacheSubtitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.settingsClearCacheConfirm,
              style: const TextStyle(color: AppColors.statusWarning),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await HiveService.shipments.clear();
    await HiveService.forwarderInfo.clear();
    await HiveService.updates.clear();
    ref.invalidate(hasUnreadUpdatesProvider);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.settingsCacheClearedDone)),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.caption.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

// ── Language selector ─────────────────────────────────────────────────────────

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector({
    required this.currentCode,
    required this.onChanged,
    required this.l10n,
  });

  final String currentCode;
  final ValueChanged<String> onChanged;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SegmentedButton<String>(
        segments: [
          ButtonSegment(
            value: 'fr',
            label: Text(l10n.settingsLanguageFr),
            icon: const Text('🇫🇷'),
          ),
          ButtonSegment(
            value: 'en',
            label: Text(l10n.settingsLanguageEn),
            icon: const Text('🇬🇧'),
          ),
        ],
        selected: {currentCode},
        onSelectionChanged: (set) => onChanged(set.first),
      ),
    );
  }
}

// ── Cache tile ────────────────────────────────────────────────────────────────

class _CacheTile extends StatelessWidget {
  const _CacheTile({required this.l10n, required this.onTap});

  final AppLocalizations l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.cleaning_services_outlined,
        color: AppColors.statusWarning,
      ),
      title: Text(l10n.settingsClearCache, style: AppTextStyles.body),
      subtitle: Text(
        l10n.settingsClearCacheSubtitle,
        style: AppTextStyles.caption
            .copyWith(color: AppColors.statusArchived),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.statusArchived),
      onTap: onTap,
    );
  }
}

// ── Navigation tile ───────────────────────────────────────────────────────────

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.statusArchived),
      title: Text(label, style: AppTextStyles.body),
      trailing: const Icon(Icons.chevron_right, color: AppColors.statusArchived),
      onTap: onTap,
    );
  }
}

// ── Info tile ─────────────────────────────────────────────────────────────────

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.statusArchived),
      title: Text(label, style: AppTextStyles.body),
      trailing: Text(
        value,
        style: AppTextStyles.bodySmall
            .copyWith(color: AppColors.statusArchived),
      ),
    );
  }
}
