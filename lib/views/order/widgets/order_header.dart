import 'package:flutter/material.dart';

import '../../../core/theme/color_schemes.dart';
import '../../../core/utils/format_helpers.dart';

/// Sticky header for the order screen — total + reset + checkout actions.
class OrderHeader extends StatelessWidget {
  final double subtotal;
  final bool hasItems;
  final VoidCallback onReset;
  final VoidCallback onCheckout;

  const OrderHeader({
    super.key,
    required this.subtotal,
    required this.hasItems,
    required this.onReset,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      height: 64,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'TOTAL',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.ink600,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.4,
                  ),
                ),
                Text(
                  hasItems ? FormatHelpers.currency(subtotal) : 'Rs. 0',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: hasItems ? AppColors.primary : AppColors.ink400,
                    letterSpacing: -1,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          _OutlineButton(
            label: 'Reset',
            color: AppColors.danger,
            onPressed: onReset,
          ),
          const SizedBox(width: 7),
          InkWell(
            onTap: hasItems ? onCheckout : null,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
              decoration: BoxDecoration(
                color: hasItems ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: hasItems ? AppColors.primary : AppColors.border,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Checkout →',
                style: TextStyle(
                  color: hasItems ? Colors.white : AppColors.ink400,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _OutlineButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
