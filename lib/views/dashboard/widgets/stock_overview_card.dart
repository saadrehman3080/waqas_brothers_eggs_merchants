import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/color_schemes.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/product.dart';
import '../../widgets/section_card.dart';

class StockOverviewCard extends StatelessWidget {
  final List<Product> products;

  const StockOverviewCard({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Stock Overview', style: AppTextStyles.sectionTitle),
                Text(AppStrings.urdStock, style: AppTextStyles.urdu(size: 10)),
              ],
            ),
          ),
          for (var i = 0; i < products.length; i++) ...[
            if (i > 0) const CardDivider(),
            _StockRow(product: products[i]),
          ],
        ],
      ),
    );
  }
}

class _StockRow extends StatelessWidget {
  final Product product;
  const _StockRow({required this.product});

  @override
  Widget build(BuildContext context) {
    final pct = product.stockPercent.clamp(0, 100);
    final isLow = product.isLowStock;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      product.nameEn,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink900,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '· ${product.nameUr}',
                      style: AppTextStyles.urdu(size: 9),
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${product.remaining}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isLow ? AppColors.danger : AppColors.ink900,
                      ),
                    ),
                    TextSpan(
                      text: '/${product.stock}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.ink400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 4,
              color: AppColors.background,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (pct / 100).clamp(0.0, 1.0),
                child: Container(
                  color: isLow ? AppColors.danger : AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
