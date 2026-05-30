import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Nunito text style definitions for BrightFret.
/// Use [AppTheme.light] / [AppTheme.dark] to apply these globally;
/// reference these directly only when overriding inside a widget.
abstract class AppTextStyles {
  static final TextStyle heading1 = GoogleFonts.nunito(
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );

  static final TextStyle heading2 = GoogleFonts.nunito(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle body = GoogleFonts.nunito(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static final TextStyle bodySmall = GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  /// Semibold 14 — for labels, badges, button text.
  static final TextStyle label = GoogleFonts.nunito(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle caption = GoogleFonts.nunito(
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );
}
