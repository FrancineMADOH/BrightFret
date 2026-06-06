import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

/// Full-width banner displayed at the top of a screen when the device is offline.
/// Localised via [AppLocalizations.offlineBannerGeneric].
class BfOfflineBanner extends StatelessWidget {
  const BfOfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ColoredBox(
      color: AppColors.statusWarning.withAlpha(30),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.wifi_off_outlined,
                size: 16, color: AppColors.statusWarning),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.offlineBannerGeneric,
                style: AppTextStyles.caption
                    .copyWith(color: AppColors.statusWarning),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
