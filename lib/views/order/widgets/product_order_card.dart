import 'package:flutter/material.dart';

import '../../../core/theme/color_schemes.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/format_helpers.dart';
import '../../../models/product.dart';

/// Per-product order card with always-visible quantity stepper.
class ProductOrderCard extends StatelessWidget {
  final Product product;
  final int qty;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onTapPriceOrName;

  const ProductOrderCard({
    super.key,
    required this.product,
    required this.qty,
    required this.onIncrement,
    required this.onDecrement,
    required this.onTapPriceOrName,
  });

  @override
  Widget build(BuildContext context) {
    final active = qty > 0;
    final remaining = product.remaining;
    final effectiveRemaining = (remaining - qty).clamp(0, remaining);
    final outOfStock = remaining <= 0;
    final atMax = !outOfStock && qty >= remaining;

    final effectiveEmpty = effectiveRemaining <= 0;
    final effectiveLow = !effectiveEmpty &&
        product.stock > 0 &&
        (effectiveRemaining / product.stock) * 100 < 20;

    final stockColor = outOfStock || effectiveEmpty
        ? AppColors.danger
        : effectiveLow
        ? AppColors.warning
        : AppColors.success;
    final stockSoft = outOfStock || effectiveEmpty
        ? AppColors.dangerSoft
        : effectiveLow
        ? AppColors.warningSoft
        : AppColors.successSoft;
    final stockBorder = outOfStock || effectiveEmpty
        ? AppColors.dangerSoftBorder
        : effectiveLow
        ? AppColors.warningSoftBorder
        : AppColors.successSoftBorder;

    return InkWell(
      onTap: outOfStock ? null : onTapPriceOrName,
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.nameEn, style: AppTextStyles.bodyLg),
                      const SizedBox(height: 1),
                      Text(product.nameUr, style: AppTextStyles.urdu(size: 10)),
                    ],
                  ),
                ),
                _Stepper(
                  qty: qty,
                  active: active,
                  atMax: atMax || outOfStock,
                  onIncrement: onIncrement,
                  onDecrement: onDecrement,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        border: Border.all(color: AppColors.primarySoftBorder),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        FormatHelpers.currency(product.price),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: stockSoft,
                        border: Border.all(color: stockBorder),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Text(
                        outOfStock ? 'Out of stock' : '$effectiveRemaining in stock',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: stockColor,
                        ),
                      ),
                    ),
                  ],
                ),
                if (active)
                  Text(
                    FormatHelpers.currency(qty * product.price),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final int qty;
  final bool active;
  final bool atMax;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _Stepper({
    required this.qty,
    required this.active,
    required this.atMax,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _stepBtn('−', AppColors.danger, onDecrement),
          SizedBox(
            width: 36,
            child: Center(
              child: Text(
                '$qty',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: active ? AppColors.primary : AppColors.ink600,
                ),
              ),
            ),
          ),
          _stepBtn(
            '+',
            atMax ? AppColors.ink400 : AppColors.primary,
            atMax ? null : onIncrement,
          ),
        ],
      ),
    );
  }

  Widget _stepBtn(String label, Color color, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 38,
        height: 38,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ),
    );
  }
}
