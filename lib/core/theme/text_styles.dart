import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'color_schemes.dart';

/// Reusable text styles. Poppins for Latin, Noto Nastaliq Urdu for Urdu.
class AppTextStyles {
  AppTextStyles._();

  // ─── Display ──────────────────────────────────────────────────
  static TextStyle heroAmount = GoogleFonts.poppins(
    fontSize: 34,
    fontWeight: FontWeight.w800,
    color: Colors.white,
    letterSpacing: -1.5,
    height: 1,
  );

  static TextStyle pageTitle = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.ink900,
    letterSpacing: -0.3,
  );

  static TextStyle screenTitle = GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.ink900,
  );

  // ─── Sections ────────────────────────────────────────────────
  static TextStyle sectionTitle = GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.ink900,
  );

  static TextStyle sectionLabel = GoogleFonts.poppins(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.ink600,
    letterSpacing: 0.5,
  );

  // ─── Body ────────────────────────────────────────────────────
  static TextStyle bodyLg = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.ink900,
  );

  static TextStyle bodyMd = GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.ink900,
  );

  static TextStyle bodySm = GoogleFonts.poppins(
    fontSize: 12,
    color: AppColors.ink600,
  );

  static TextStyle caption = GoogleFonts.poppins(
    fontSize: 10,
    color: AppColors.ink600,
  );

  static TextStyle micro = GoogleFonts.poppins(
    fontSize: 9,
    color: AppColors.ink400,
  );

  // ─── Buttons ─────────────────────────────────────────────────
  static TextStyle buttonLg = GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );

  static TextStyle buttonSm = GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w600,
  );

  // ─── Urdu ────────────────────────────────────────────────────
  static TextStyle urdu({double size = 10, FontWeight? weight, Color? color}) {
    return GoogleFonts.notoNastaliqUrdu(
      fontSize: size,
      fontWeight: weight ?? FontWeight.w400,
      color: color ?? AppColors.ink600,
      height: 1.5,
    );
  }
}
