import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/color_schemes.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/format_helpers.dart';
import '../../widgets/section_card.dart';

class MonthlySummaryCard extends StatelessWidget {
  final Map<String, String> summary;

  const MonthlySummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final stats = [
      _Stat(
        label: 'Revenue',
        value: summary['revenue'] ?? '—',
        icon: Icons.trending_up,
      ),
      _Stat(
        label: 'Orders',
        value: summary['orders'] ?? '—',
        icon: Icons.receipt_long,
      ),
      _Stat(
        label: 'Margin',
        value: summary['credit'] ?? '—',
        icon: Icons.savings,
      ),
      _Stat(label: 'Cash', value: summary['cash'] ?? '—', icon: Icons.payments),
      _Stat(
        label: 'Customers',
        value: summary['customers'] ?? '—',
        icon: Icons.group,
      ),
      _Stat(
        label: 'Avg Order',
        value: summary['avgOrder'] ?? '—',
        icon: Icons.calculate,
      ),
    ];
    return SectionCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  FormatHelpers.monthLabel(),
                  style: AppTextStyles.sectionTitle,
                ),
                Text(
                  AppStrings.urdMonthly,
                  style: AppTextStyles.urdu(size: 11),
                ),
              ],
            ),
          ),
          const CardDivider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              children: [
                Row(
                  children: List.generate(3, (i) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: i == 2 ? 0 : 8),
                        child: _StatTile(stat: stats[i]),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 10),
                Row(
                  children: List.generate(3, (i) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: i == 2 ? 0 : 8),
                        child: _StatTile(stat: stats[i + 3]),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat {
  final String label;
  final String value;
  final IconData icon;
  _Stat({required this.label, required this.value, required this.icon});
}

class _StatTile extends StatelessWidget {
  final _Stat stat;
  const _StatTile({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(stat.icon, size: 14, color: AppColors.primary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  stat.label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 8,
                    color: AppColors.ink400,
                    letterSpacing: 0.3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            stat.value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.ink600,
            ),
          ),
        ],
      ),
    );
  }
}
