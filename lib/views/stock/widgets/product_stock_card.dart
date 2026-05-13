import 'package:flutter/material.dart';

import '../../../core/theme/color_schemes.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/egg_pool.dart';
import '../../../models/product.dart';

class ProductStockCard extends StatelessWidget {
  final Product product;
  final EggPool eggPool;
  final VoidCallback onEdit;

  const ProductStockCard({
    super.key,
    required this.product,
    required this.eggPool,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final epu = product.eggsPerUnit;
    final totalUnits = eggPool.totalAs(epu);
    final remainingUnits = eggPool.remainingAs(epu);
    final soldUnits = eggPool.soldAs(epu);
    final addedTodayUnits =
        epu > 0 ? eggPool.stockAddedToday ~/ epu : 0;

    final topTiles = <_StatTileData>[
      _StatTileData(
        label: 'Total',
        value: '$totalUnits',
        suffix: 'in stock',
        color: AppColors.ink900,
      ),
      _StatTileData(
        label: 'Available',
        value: '$remainingUnits',
        suffix: 'remaining',
        color: AppColors.success,
      ),
      _StatTileData(
        label: 'Sold',
        value: '$soldUnits',
        suffix: 'units',
        color: AppColors.primary,
      ),
    ];

    final bottomTiles = <_StatTileData>[
      _StatTileData(
        label: 'Price',
        value: 'Rs.${product.price.toStringAsFixed(0)}',
        suffix: 'per unit',
        color: AppColors.ink600,
      ),
      _StatTileData(
        label: 'Revenue / Unit',
        value: 'Rs.${product.revenuePerUnit.toStringAsFixed(0)}',
        suffix: 'margin',
        color: const Color(0xFF059669),
      ),
      _StatTileData(
        label: 'Eggs / Unit',
        value: epu > 0 ? '$epu' : '—',
        suffix: 'eggs',
        color: AppColors.ink600,
      ),
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: _Header(product: product, onEdit: onEdit),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: List.generate(topTiles.length, (i) {
                final isLast = i == topTiles.length - 1;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: isLast ? 0 : 5),
                    child: _StatTile(data: topTiles[i]),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: List.generate(bottomTiles.length, (i) {
                final isLast = i == bottomTiles.length - 1;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: isLast ? 0 : 5),
                    child: _StatTile(data: bottomTiles[i]),
                  ),
                );
              }),
            ),
          ),
          if (addedTodayUnits > 0 && _isToday(eggPool.stockAddedAtMs)) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _TodayStockBadge(units: addedTodayUnits),
            ),
          ],
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  const _Header({required this.product, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Row(
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
        InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(7),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderDark, width: 1.5),
              borderRadius: BorderRadius.circular(7),
              color: AppColors.surface,
            ),
            child: const Text(
              'Edit',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.ink900,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatTileData {
  final String label;
  final String value;
  final String suffix;
  final Color color;
  _StatTileData({
    required this.label,
    required this.value,
    required this.suffix,
    required this.color,
  });
}

class _StatTile extends StatelessWidget {
  final _StatTileData data;
  const _StatTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.label.toUpperCase(),
            style: const TextStyle(
              fontSize: 7,
              color: AppColors.ink400,
              letterSpacing: 0.3,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            data.value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: data.color,
            ),
          ),
          Text(
            data.suffix,
            style: const TextStyle(fontSize: 7, color: AppColors.ink400),
          ),
        ],
      ),
    );
  }
}

class _TodayStockBadge extends StatelessWidget {
  final int units;
  const _TodayStockBadge({required this.units});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.primary.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.trending_up_rounded,
              size: 14,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ADDED TODAY',
                  style: TextStyle(
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '+$units units',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

bool _isToday(int ms) {
  if (ms == 0) return false;
  final d = DateTime.fromMillisecondsSinceEpoch(ms);
  final now = DateTime.now();
  return d.year == now.year && d.month == now.month && d.day == now.day;
}
