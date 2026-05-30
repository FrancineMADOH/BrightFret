import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../shared/widgets/bf_bottom_nav.dart';

/// Stub for SettingsScreen — S14.
/// Full implementation in F5.2: language switcher, data clear, about section.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tabSettings),
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: const BfBottomNavBar(currentIndex: 3),
      body: const Center(
        child: Icon(Icons.settings_outlined, size: 64, color: Colors.grey),
      ),
    );
  }
}
