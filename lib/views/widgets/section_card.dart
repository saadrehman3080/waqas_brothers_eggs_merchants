import 'package:flutter/material.dart';

import '../../core/theme/color_schemes.dart';

/// White, rounded, hairline-bordered container used for grouped content.
class SectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final Color? background;
  final Color? borderColor;

  const SectionCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.radius = 14,
    this.background,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: background ?? AppColors.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? AppColors.border),
      ),
      child: child,
    );
  }
}

/// Hairline divider used inside [SectionCard]s.
class CardDivider extends StatelessWidget {
  const CardDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: AppColors.border);
  }
}
