import 'package:flutter/material.dart';

/// Central colour palette for BrightFret, aligned with bw_base_branding.
/// All widgets must reference these constants — no raw hex literals in widget code.
abstract class AppColors {
  // ── Brand ──────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF002868);
  static const Color accent = Color(0xFFBF0A30);
  static const Color white = Color(0xFFFFFFFF);

  // ── Shipment status (semantic) ─────────────────────────────────────────────
  static const Color statusActive = Color(0xFF1565C0);
  static const Color statusDelivered = Color(0xFF2E7D32);
  static const Color statusWarning = Color(0xFFE65100);
  static const Color statusError = Color(0xFFC62828);
  static const Color statusArchived = Color(0xFF757575);

  // ── Surfaces ───────────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFEEEEEE);
}
