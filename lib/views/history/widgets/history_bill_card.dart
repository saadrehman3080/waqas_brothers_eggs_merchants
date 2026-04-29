import 'package:flutter/material.dart';

import '../../../core/theme/color_schemes.dart';
import '../../../core/utils/format_helpers.dart';
import '../../../models/bill.dart';
import '../../../models/product.dart';
import '../../widgets/app_button.dart';

class HistoryBillCard extends StatelessWidget {
  final Bill bill;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onConvertToCredit;
  final VoidCallback onReprint;
  final VoidCallback onDelete;
  final Product? Function(int) productLookup;

  const HistoryBillCard({
    super.key,
    required this.bill,
    required this.expanded,
    required this.onToggle,
    required this.onConvertToCredit,
    required this.onReprint,
    required this.onDelete,
    required this.productLookup,
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
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bill.displayCustomer,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink900,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1),
                        Text(
                          '${bill.date} · ${bill.time}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.ink600,
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
                      color: AppColors.ink900,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            _ExpandedActions(
              bill: bill,
              productLookup: productLookup,
              onConvertToCredit: onConvertToCredit,
              onReprint: onReprint,
              onDelete: onDelete,
            ),
        ],
      ),
    );
  }
}

class _ExpandedActions extends StatelessWidget {
  final Bill bill;
  final Product? Function(int) productLookup;
  final VoidCallback onConvertToCredit;
  final VoidCallback onReprint;
  final VoidCallback onDelete;

  const _ExpandedActions({
    required this.bill,
    required this.productLookup,
    required this.onConvertToCredit,
    required this.onReprint,
    required this.onDelete,
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
                      color: AppColors.ink900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 8,
                ),
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppButton(
                    label: '→ Credit',
                    small: true,
                    variant: AppButtonVariant.soft,
                    onPressed: onConvertToCredit,
                  ),
                  const SizedBox(width: 7),
                  AppButton(
                    label: 'Reprint',
                    small: true,
                    variant: AppButtonVariant.ghost,
                    icon: Icons.print_outlined,
                    onPressed: onReprint,
                  ),
                  const SizedBox(width: 7),
                  AppButton(
                    label: 'Delete',
                    small: true,
                    variant: AppButtonVariant.danger,
                    icon: Icons.delete_outline,
                    onPressed: onDelete,
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
