import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../shared/widgets/bf_bottom_nav.dart';

/// Stub for UpdatesScreen — S13.
/// Full implementation in F3.2: in-app delta notifications from Hive `updates` box.
class UpdatesScreen extends StatelessWidget {
  const UpdatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tabUpdates),
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: const BfBottomNavBar(currentIndex: 2),
      body: const Center(
        child: Icon(Icons.notifications_outlined, size: 64, color: Colors.grey),
      ),
    );
  }
}
