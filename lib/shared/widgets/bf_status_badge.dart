import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_enums.dart';
import '../../core/constants/app_text_styles.dart';

/// Coloured rounded badge displaying a shipment status.
/// Uses only semantic colours from [AppColors] — never a raw [Color].
/// Labels are localised via [AppLocalizations].
class BfStatusBadge extends StatelessWidget {
  const BfStatusBadge({super.key, required this.status});

  final ShipmentStatus status;

  Color get _color => switch (status) {
        ShipmentStatus.active => AppColors.statusActive,
        ShipmentStatus.delivered => AppColors.statusDelivered,
        ShipmentStatus.warning => AppColors.statusWarning,
        ShipmentStatus.error => AppColors.statusError,
        ShipmentStatus.archived => AppColors.statusArchived,
      };

  String _localizedLabel(AppLocalizations l10n) => switch (status) {
        ShipmentStatus.active => l10n.statusActive,
        ShipmentStatus.delivered => l10n.statusDelivered,
        ShipmentStatus.warning => l10n.statusWarning,
        ShipmentStatus.error => l10n.statusError,
        ShipmentStatus.archived => l10n.statusArchived,
      };

  @override
  Widget build(BuildContext context) {
    final label = _localizedLabel(AppLocalizations.of(context)!);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: _color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
