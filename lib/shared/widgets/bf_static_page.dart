import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import 'bf_app_bar.dart';
import 'bf_bottom_nav.dart';

/// One titled paragraph block on a [BfStaticPage].
class BfStaticSection {
  const BfStaticSection({required this.heading, required this.body});

  final String heading;
  final String body;
}

/// Simple scrollable title+paragraphs page — used for "About" and
/// "Terms & conditions" (S14 sub-pages). Keeps a single consistent
/// layout instead of duplicating Scaffold/AppBar/ListView per screen.
class BfStaticPage extends StatelessWidget {
  const BfStaticPage({
    super.key,
    required this.title,
    required this.sections,
    required this.currentNavIndex,
  });

  final String title;
  final List<BfStaticSection> sections;

  /// Tab index for [BfBottomNavBar] — kept persistent on every screen
  /// except splash/onboarding, per product preference.
  final int currentNavIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BfAppBar(title: title),
      bottomNavigationBar: BfBottomNavBar(currentIndex: currentNavIndex),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: sections.length,
        separatorBuilder: (_, __) => const SizedBox(height: 24),
        itemBuilder: (_, i) {
          final section = sections[i];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(section.heading, style: AppTextStyles.heading2),
              const SizedBox(height: 8),
              Text(
                section.body,
                style: AppTextStyles.body
                    .copyWith(color: AppColors.statusArchived, height: 1.4),
              ),
            ],
          );
        },
      ),
    );
  }
}
