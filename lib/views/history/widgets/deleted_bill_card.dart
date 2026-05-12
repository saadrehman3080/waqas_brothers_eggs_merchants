import 'package:flutter/material.dart';

import '../../../core/theme/color_schemes.dart';
import '../../../core/utils/format_helpers.dart';
import '../../../models/bill.dart';
import '../../../models/product.dart';

class DeletedBillCard extends StatelessWidget {
  final CashBill bill;
  final DateTime deletedAt;
  final bool expanded;
  final VoidCallback onToggle;
  final Product? Function(String) productLookup;

  const DeletedBillCard({
    super.key,
    required this.bill,
    required this.deletedAt,
    required this.expanded,
    required this.onToggle,
    required this.productLookup,
  });

  String _formatDeletedAt() {
    final h = deletedAt.hour % 12 == 0 ? 12 : deletedAt.hour % 12;
    final mn = deletedAt.minute.toString().padLeft(2, '0');
    final ampm = deletedAt.hour < 12 ? 'AM' : 'PM';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${deletedAt.day} ${months[deletedAt.month - 1]}  $h:$mn $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.dangerSoftBorder, width: 1.5),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        FormatHelpers.currency(bill.total),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink600,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.dangerSoft,
                          borderRadius: BorderRadius.circular(6),
                          border:
                              Border.all(color: AppColors.dangerSoftBorder),
                        ),
                        child: const Text(
                          'Deleted',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: AppColors.danger,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (expanded) _DeletedBillDetails(
            bill: bill,
            deletedAt: _formatDeletedAt(),
            productLookup: productLookup,
          ),
        ],
      ),
    );
  }
}

class _DeletedBillDetails extends StatelessWidget {
  final CashBill bill;
  final String deletedAt;
  final Product? Function(String) productLookup;

  const _DeletedBillDetails({
    required this.bill,
    required this.deletedAt,
    required this.productLookup,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(height: 1, color: AppColors.dangerSoftBorder),
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
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Deleted by: ',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.ink400,
                                ),
                              ),
                              TextSpan(
                                text: bill.device,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.danger,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'At: $deletedAt',
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
              const SizedBox(height: 9),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: AppColors.borderDark),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: Column(
                    children: [
                      _Row(
                        label: 'Subtotal',
                        value: FormatHelpers.currency(bill.subtotal),
                        color: AppColors.ink600,
                      ),
                      const SizedBox(height: 4),
                      _Row(
                        label: 'Discount',
                        value: '− ${FormatHelpers.currency(bill.discount)}',
                        color: AppColors.danger,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Divider(height: 1, color: AppColors.border),
                      ),
                      _Row(
                        label: 'Total',
                        value: FormatHelpers.currency(bill.total),
                        color: AppColors.ink900,
                        bold: true,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool bold;

  const _Row({
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
