import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import 'bf_primary_button.dart';

/// A label + tap handler pair used as a CTA in [BfErrorScreen].
class BfErrorAction {
  const BfErrorAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;
}

/// Generic error content widget reused by S15 (unknown forwarder),
/// S16 (shipment not found), and S17 (offline / no cache).
/// Does NOT include a Scaffold — wrap in one at the screen level.
class BfErrorScreen extends StatelessWidget {
  const BfErrorScreen({
    super.key,
    required this.title,
    required this.body,
    this.actions = const [],
    this.icon = Icons.error_outline,
  });

  final String title;
  final String body;
  final List<BfErrorAction> actions;

  /// Icon shown in the illustration placeholder. Override per error type.
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _illustration(),
            const SizedBox(height: 24),
            Text(title, style: AppTextStyles.heading2, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(
              body,
              style: AppTextStyles.body.copyWith(color: AppColors.statusArchived),
              textAlign: TextAlign.center,
            ),
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 24),
              ...actions.map(
                (a) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: BfPrimaryButton(label: a.label, onPressed: a.onTap),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _illustration() => Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: AppColors.divider,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 48, color: AppColors.statusArchived),
      );
}
