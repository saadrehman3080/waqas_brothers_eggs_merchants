import 'package:flutter/material.dart';

import '../theme/color_schemes.dart';
import '../theme/text_styles.dart';

enum SnackbarVariant { success, error, info }

/// Centralised snackbar presenter with success/error/info variants.
class CustomSnackbar {
  CustomSnackbar._();

  static void show(
    BuildContext context,
    String message, {
    SnackbarVariant variant = SnackbarVariant.info,
  }) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: AppTextStyles.bodySm.copyWith(color: Colors.white),
          ),
          backgroundColor: switch (variant) {
            SnackbarVariant.success => AppColors.success,
            SnackbarVariant.error => AppColors.danger,
            SnackbarVariant.info => AppColors.ink900,
          },
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
  }

  static void success(BuildContext context, String message) =>
      show(context, message, variant: SnackbarVariant.success);

  static void error(BuildContext context, String message) =>
      show(context, message, variant: SnackbarVariant.error);

  static void info(BuildContext context, String message) =>
      show(context, message, variant: SnackbarVariant.info);
}
