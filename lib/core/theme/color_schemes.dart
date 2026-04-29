import 'package:flutter/material.dart';

/// Centralised color tokens for the app.
///
/// Names mirror the design tokens from the Waqas Brothers design bundle —
/// a clean, light, minimal palette with a single blue accent.
class AppColors {
  AppColors._();

  // Surfaces
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);

  // Borders
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderDark = Color(0xFFD1D5DB);

  // Brand / accent — single blue used sparingly
  static const Color primary = Color(0xFF2563EB);
  static const Color primarySoft = Color(0xFFEFF6FF);
  static const Color primarySoftBorder = Color(0xFFBFDBFE);

  // Status — cash / paid
  static const Color success = Color(0xFF16A34A);
  static const Color successSoft = Color(0xFFF0FDF4);
  static const Color successSoftBorder = Color(0xFFBBF7D0);

  // Status — destructive / outstanding
  static const Color danger = Color(0xFFDC2626);
  static const Color dangerSoft = Color(0xFFFEF2F2);
  static const Color dangerSoftBorder = Color(0xFFFECACA);

  // Status — warnings
  static const Color warning = Color(0xFFD97706);
  static const Color warningSoft = Color(0xFFFFFBEB);
  static const Color warningSoftBorder = Color(0xFFFDE68A);

  // Ink scale
  static const Color ink900 = Color(0xFF111827);
  static const Color ink600 = Color(0xFF6B7280);
  static const Color ink400 = Color(0xFF9CA3AF);
  static const Color ink200 = Color(0xFFE5E7EB);

  // Misc
  static const Color overlay = Color(0x66000000);
}
