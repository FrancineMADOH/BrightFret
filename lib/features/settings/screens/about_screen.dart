import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../shared/widgets/bf_static_page.dart';

/// S14 sub-page — short presentation of the app and the BrightFret service.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BfStaticPage(
      title: l10n.aboutTitle,
      currentNavIndex: 3,
      sections: [
        BfStaticSection(heading: l10n.aboutWhatTitle, body: l10n.aboutWhatBody),
        BfStaticSection(heading: l10n.aboutHowTitle, body: l10n.aboutHowBody),
        BfStaticSection(
          heading: l10n.aboutBrightwillTitle,
          body: l10n.aboutBrightwillBody,
          linkLabel: l10n.aboutBrightwillLink,
          linkUrl: 'https://www.brightwill.org/fret',
        ),
        BfStaticSection(
            heading: l10n.aboutVersionTitle, body: l10n.aboutVersionBody),
      ],
    );
  }
}
