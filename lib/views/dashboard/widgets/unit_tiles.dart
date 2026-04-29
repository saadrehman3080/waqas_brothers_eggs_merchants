import 'package:flutter/material.dart';

import '../../../core/theme/color_schemes.dart';
import '../../../core/theme/text_styles.dart';

class UnitTiles extends StatelessWidget {
  final int dozens;
  final int trays;
  final int patties;
  final int eggs;
  final bool isDark;

  const UnitTiles({
    super.key,
    required this.dozens,
    required this.trays,
    required this.patties,
    required this.eggs,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    final entries = <_UnitData>[
      _UnitData('Dozens', 'درجن', dozens),
      _UnitData('Trays', 'ٹرے', trays),
      _UnitData('Patties', 'پیٹی', patties),
      _UnitData('Eggs', 'انڈے', eggs),
    ];
    return Row(
      children: List.generate(entries.length, (i) {
        final isLast = i == entries.length - 1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 8),
            child: _UnitTile(data: entries[i], isDark: isDark),
          ),
        );
      }),
    );
  }
}

class _UnitData {
  final String en;
  final String ur;
  final int value;
  _UnitData(this.en, this.ur, this.value);
}

class _UnitTile extends StatelessWidget {
  final _UnitData data;
  final bool isDark;

  const _UnitTile({required this.data, this.isDark = true});

  @override
  Widget build(BuildContext context) {
    if (isDark) {
      // Light background version (standalone on dashboard)
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.ink900.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              '${data.value}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.ink900,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              data.en,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.ink600,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              data.ur,
              style: AppTextStyles.urdu(size: 11, color: AppColors.ink400),
            ),
          ],
        ),
      );
    } else {
      // Dark background version (inside hero card)
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              '${data.value}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              data.en,
              style: TextStyle(
                fontSize: 9,
                color: Colors.white.withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              data.ur,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }
  }
}
