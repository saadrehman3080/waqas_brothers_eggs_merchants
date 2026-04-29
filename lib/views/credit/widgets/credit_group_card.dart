import 'package:flutter/material.dart';

import '../../../core/theme/color_schemes.dart';
import '../../../core/utils/format_helpers.dart';
import '../../../core/utils/string_helpers.dart';
import '../../../models/bill.dart';
import '../../../models/product.dart';
import 'credit_bill_detail.dart';

/// Customer-grouped outstanding credit card.
class CreditGroup {
  final String name;
  final List<Bill> bills;
  final double total;

  const CreditGroup({
    required this.name,
    required this.bills,
    required this.total,
  });
}

class CreditGroupCard extends StatelessWidget {
  final CreditGroup group;
  final bool expanded;
  final VoidCallback onToggle;
  final Product? Function(int) productLookup;
  final void Function(Bill) onMarkPaid;
  final void Function(Bill) onReprint;

  const CreditGroupCard({
    super.key,
    required this.group,
    required this.expanded,
    required this.onToggle,
    required this.productLookup,
    required this.onMarkPaid,
    required this.onReprint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(13),
            onTap: onToggle,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      border: Border.all(color: AppColors.primarySoftBorder),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      StringHelpers.initial(group.name),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink900,
                          ),
                        ),
                        Text(
                          '${group.bills.length} unpaid bill${group.bills.length > 1 ? 's' : ''}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.ink600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        FormatHelpers.currency(group.total),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.danger,
                        ),
                      ),
                      const Text(
                        'outstanding',
                        style: TextStyle(
                          fontSize: 9,
                          color: AppColors.ink400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            for (final bill in group.bills)
              CreditBillDetail(
                bill: bill,
                productLookup: productLookup,
                onMarkPaid: () => onMarkPaid(bill),
                onReprint: () => onReprint(bill),
              ),
        ],
      ),
    );
  }
}
