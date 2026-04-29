import 'package:flutter/material.dart';

import '../../../core/theme/color_schemes.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/format_helpers.dart';
import 'unit_tiles.dart';

/// Blue hero card showing today's collection, credit out, customer count, and unit breakdown.
class CollectionHero extends StatelessWidget {
  final double cash;
  final double credit;
  final int customers;
  final int dozens;
  final int trays;
  final int patties;
  final int eggs;

  const CollectionHero({
    super.key,
    required this.cash,
    required this.credit,
    required this.customers,
    required this.dozens,
    required this.trays,
    required this.patties,
    required this.eggs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "TODAY'S COLLECTION",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white.withValues(alpha: 0.85),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            FormatHelpers.currency(cash),
            style: AppTextStyles.heroAmount.copyWith(
              fontSize: 32,
              letterSpacing: -1.2,
            ),
          ),
          // const SizedBox(height: 16),
          // Container(
          //   height: 1,
          //   decoration: BoxDecoration(
          //     gradient: LinearGradient(
          //       colors: [
          //         Colors.white.withValues(alpha: 0.3),
          //         Colors.white.withValues(alpha: 0),
          //       ],
          //     ),
          //   ),
          // ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _HeroStat(
                  label: 'Credit Out',
                  value: FormatHelpers.currency(credit),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _HeroStat(label: 'Customers', value: '$customers'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'UNITS SOLD',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.65),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              UnitTiles(
                dozens: dozens,
                trays: trays,
                patties: patties,
                eggs: eggs,
                isDark: false,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final String value;

  const _HeroStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: Colors.white.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
