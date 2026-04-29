import 'package:flutter/material.dart';

import '../../core/theme/color_schemes.dart';

enum TagColor { blue, green, red, amber }

/// Small uppercase pill used for status indicators (Cash / Credit / etc.).
class TagPill extends StatelessWidget {
  final String label;
  final TagColor color;

  const TagPill({super.key, required this.label, this.color = TagColor.blue});

  ({Color background, Color foreground}) get _palette {
    switch (color) {
      case TagColor.green:
        return (
          background: AppColors.successSoft,
          foreground: AppColors.success,
        );
      case TagColor.red:
        return (background: AppColors.dangerSoft, foreground: AppColors.danger);
      case TagColor.amber:
        return (
          background: AppColors.warningSoft,
          foreground: AppColors.warning,
        );
      case TagColor.blue:
        return (
          background: AppColors.primarySoft,
          foreground: AppColors.primary,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = _palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: palette.foreground,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
