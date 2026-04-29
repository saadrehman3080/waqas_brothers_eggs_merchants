import 'package:flutter/material.dart';

import '../../../core/theme/color_schemes.dart';
import '../../../core/utils/format_helpers.dart';
import '../../../models/bill.dart';
import '../../../models/product.dart';
import '../../widgets/app_button.dart';

class CreditBillDetail extends StatelessWidget {
  final Bill bill;
  final Product? Function(int) productLookup;
  final VoidCallback onMarkPaid;
  final VoidCallback onReprint;

  const CreditBillDetail({
    super.key,
    required this.bill,
    required this.productLookup,
    required this.onMarkPaid,
    required this.onReprint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(height: 1, color: AppColors.border),
        Container(
          color: AppColors.background,
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bill #${bill.id}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink900,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          '${bill.date} · ${bill.time}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.ink600,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'Device: ${bill.device}',
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.ink400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    FormatHelpers.currency(bill.total),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.danger,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: List.generate(bill.items.length, (i) {
                    final it = bill.items[i];
                    final p = productLookup(it.productId);
                    final isLast = i == bill.items.length - 1;
                    return Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: isLast
                              ? BorderSide.none
                              : const BorderSide(color: AppColors.border),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${p?.nameEn ?? '—'} × ${it.qty}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.ink600,
                            ),
                          ),
                          Text(
                            FormatHelpers.currency(it.lineTotal),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink900,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  AppButton(
                    label: 'Mark Paid',
                    small: true,
                    variant: AppButtonVariant.success,
                    icon: Icons.check_rounded,
                    onPressed: onMarkPaid,
                  ),
                  const SizedBox(width: 7),
                  AppButton(
                    label: 'Reprint',
                    small: true,
                    variant: AppButtonVariant.ghost,
                    icon: Icons.print_outlined,
                    onPressed: onReprint,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
