import 'package:flutter/material.dart';

import '../theme/color_schemes.dart';

/// Reusable [InputDecoration] presets to keep form styling consistent
/// across the app without spreading style code into views.
class InputStyles {
  InputStyles._();

  static InputDecoration field({String? hint}) => InputDecoration(
        hintText: hint,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        filled: true,
        fillColor: AppColors.surface,
        border: _border(AppColors.border),
        enabledBorder: _border(AppColors.border),
        focusedBorder: _border(AppColors.primary, width: 1.4),
        errorBorder: _border(AppColors.danger),
        focusedErrorBorder: _border(AppColors.danger, width: 1.4),
      );

  static OutlineInputBorder _border(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: BorderSide(color: color, width: width),
      );
}
