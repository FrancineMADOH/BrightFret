import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../shared/widgets/bf_static_page.dart';

/// S14 sub-page — short terms & conditions of use.
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BfStaticPage(
      title: l10n.termsTitle,
      sections: [
        BfStaticSection(
            heading: l10n.termsAcceptanceTitle, body: l10n.termsAcceptanceBody),
        BfStaticSection(
            heading: l10n.termsServiceTitle, body: l10n.termsServiceBody),
        BfStaticSection(
            heading: l10n.termsResponsibilityTitle,
            body: l10n.termsResponsibilityBody),
        BfStaticSection(
            heading: l10n.termsLiabilityTitle, body: l10n.termsLiabilityBody),
        BfStaticSection(
            heading: l10n.termsChangesTitle, body: l10n.termsChangesBody),
      ],
    );
  }
}
