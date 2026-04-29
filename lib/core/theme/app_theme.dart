import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'color_schemes.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.primary,
      onSecondary: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.ink900,
      error: AppColors.danger,
      onError: Colors.white,
    ),
    textTheme: GoogleFonts.poppinsTextTheme().apply(
      bodyColor: AppColors.ink900,
      displayColor: AppColors.ink900,
    ),
    dividerColor: AppColors.border,
    splashFactory: InkRipple.splashFactory,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.ink900,
      elevation: 0,
      centerTitle: true,
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      hintStyle: GoogleFonts.poppins(
        fontSize: 13,
        color: AppColors.ink400,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: AppColors.border),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
  );
}
