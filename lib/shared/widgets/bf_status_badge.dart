import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_enums.dart';
import '../../core/constants/app_text_styles.dart';

/// Coloured rounded badge displaying a shipment status.
/// Uses only semantic colours from [AppColors] — never a raw [Color].
/// TODO(F0.6): replace hardcoded labels with AppLocalizations keys.
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

  String get _label => switch (status) {
        ShipmentStatus.active => 'En transit',
        ShipmentStatus.delivered => 'Livré',
        ShipmentStatus.warning => 'Attention',
        ShipmentStatus.error => 'Problème',
        ShipmentStatus.archived => 'Archivé',
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color),
      ),
      child: Text(
        _label,
        style: AppTextStyles.caption.copyWith(
          color: _color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
