import 'package:flutter/material.dart';

import '../../core/theme/color_schemes.dart';
import '../../core/theme/text_styles.dart';

/// Top app bar with optional Urdu subtitle and trailing action.
///
/// Uses a `leading | Expanded(title) | trailing` row so the title shrinks
/// to whatever space is left after the action widgets — no more overflows
/// when both `+Stock` and `+Item` are docked on the right.
class TopBar extends StatelessWidget {
  final String title;
  final String? urdu;
  final Widget? leading;
  final Widget? trailing;

  const TopBar({
    super.key,
    required this.title,
    this.urdu,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 56,
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 8)],
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppTextStyles.screenTitle,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                if (urdu != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    urdu!,
                    style: AppTextStyles.urdu(size: 11),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
  }
}
