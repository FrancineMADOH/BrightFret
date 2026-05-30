import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

/// Standard BrightFret AppBar.
/// Implements [PreferredSizeWidget] so it can be used directly as [Scaffold.appBar].
class BfAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BfAppBar({super.key, required this.title, this.actions});

  final String title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: AppTextStyles.heading2.copyWith(color: AppColors.white),
      ),
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      elevation: 0,
      actions: actions,
    );
  }
}
