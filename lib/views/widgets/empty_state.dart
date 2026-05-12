import 'package:flutter/material.dart';

import '../../core/theme/color_schemes.dart';
import '../../core/theme/text_styles.dart';

/// Generic empty/placeholder state used when a list has no rows.
class EmptyState extends StatelessWidget {
  final String message;
  final String? subtitle;
  final IconData icon;

  const EmptyState({
    super.key,
    required this.message,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTextStyles.screenTitle.copyWith(
                color: AppColors.ink900,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle ?? 'Get started by adding new bills',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.ink600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
