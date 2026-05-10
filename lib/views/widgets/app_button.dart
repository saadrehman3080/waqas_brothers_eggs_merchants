import 'package:flutter/material.dart';

import '../../core/theme/color_schemes.dart';
import '../../core/theme/text_styles.dart';

enum AppButtonVariant { primary, success, danger, ghost, soft }

/// Reusable button matching the Waqas Brothers design system.
class AppButton extends StatelessWidget {
  final String label;
  final AppButtonVariant variant;
  final bool small;
  final bool full;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool busy;

  const AppButton({
    super.key,
    required this.label,
    this.variant = AppButtonVariant.primary,
    this.small = false,
    this.full = false,
    this.icon,
    this.onPressed,
    this.busy = false,
  });

  _ButtonStyle _resolveStyle() {
    switch (variant) {
      case AppButtonVariant.primary:
        return _ButtonStyle(
          background: AppColors.primary,
          foreground: Colors.white,
        );
      case AppButtonVariant.success:
        return _ButtonStyle(
          background: AppColors.success,
          foreground: Colors.white,
        );
      case AppButtonVariant.danger:
        return _ButtonStyle(
          background: AppColors.danger,
          foreground: Colors.white,
        );
      case AppButtonVariant.ghost:
        return _ButtonStyle(
          background: AppColors.surface,
          foreground: AppColors.ink900,
          border: Border.all(color: AppColors.borderDark, width: 1.5),
        );
      case AppButtonVariant.soft:
        return _ButtonStyle(
          background: AppColors.primarySoft,
          foreground: AppColors.primary,
          border: Border.all(color: AppColors.primarySoftBorder),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _resolveStyle();
    final padding = small
        ? const EdgeInsets.symmetric(horizontal: 13, vertical: 6)
        : const EdgeInsets.symmetric(horizontal: 18, vertical: 11);
    final textStyle = (small ? AppTextStyles.buttonSm : AppTextStyles.buttonLg)
        .copyWith(color: style.foreground);

    final disabled = busy || onPressed == null;

    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: full ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (busy)
          SizedBox(
            width: small ? 13 : 15,
            height: small ? 13 : 15,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(style.foreground),
            ),
          )
        else if (icon != null) ...[
          Icon(icon, size: small ? 14 : 16, color: style.foreground),
          const SizedBox(width: 6),
        ],
        if (!busy)
          Text(
            label,
            style: textStyle,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );

    final button = Material(
      color: style.background,
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        onTap: disabled ? null : onPressed,
        borderRadius: BorderRadius.circular(9),
        child: Opacity(
          opacity: disabled ? 0.5 : 1,
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              border: style.border,
            ),
            child: child,
          ),
        ),
      ),
    );

    return full ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class _ButtonStyle {
  final Color background;
  final Color foreground;
  final BoxBorder? border;
  _ButtonStyle({
    required this.background,
    required this.foreground,
    this.border,
  });
}
