import 'package:flutter/material.dart';

import '../../../core/theme/color_schemes.dart';
import '../../../core/utils/format_helpers.dart';
import '../../../models/bill.dart';
import '../../../models/product.dart';
import '../../widgets/app_button.dart';

class CreditBillDetail extends StatelessWidget {
  final Bill bill;
  final Product? Function(String) productLookup;
  final VoidCallback onMarkPaid;
  final VoidCallback onReprint;
  final VoidCallback onDelete;

  const CreditBillDetail({
    super.key,
    required this.bill,
    required this.productLookup,
    required this.onMarkPaid,
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
                        if (bill case final CreditBill cb
                            when cb.movedToCreditByDevice != null) ...[
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(7),
                              border:
                                  Border.all(color: AppColors.primarySoftBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      const TextSpan(
                                        text: 'Moved by: ',
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: AppColors.ink600,
                                        ),
                                      ),
                                      TextSpan(
                                        text: cb.movedToCreditByDevice,
                                        style: const TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (cb.movedToCreditAt != null)
                                  Text(
                                    'At: ${FormatHelpers.formatDateTime(cb.movedToCreditAt!)}',
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: AppColors.ink400,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
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
              if (bill.discount > 0) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 11, vertical: 9),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: Column(
                    children: [
                      _SummaryRow(
                        label: 'Subtotal',
                        value: FormatHelpers.currency(bill.subtotal),
                        color: AppColors.ink600,
                      ),
                      const SizedBox(height: 4),
                      _SummaryRow(
                        label: 'Discount',
                        value: '− ${FormatHelpers.currency(bill.discount)}',
                        color: AppColors.danger,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Divider(height: 1, color: AppColors.border),
                      ),
                      _SummaryRow(
                        label: 'Total',
                        value: FormatHelpers.currency(bill.total),
                        color: AppColors.ink900,
                        bold: true,
                      ),
                    ],
                  ),
                ),
              ],
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
                  const SizedBox(width: 7),
                  AppButton(
                    label: 'Delete',
                    small: true,
                    variant: AppButtonVariant.danger,
                    icon: Icons.delete_outline_rounded,
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

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool bold;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.color,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: bold ? AppColors.ink900 : AppColors.ink600,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
