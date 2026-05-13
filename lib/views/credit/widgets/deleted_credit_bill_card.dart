import 'package:flutter/material.dart';

import '../../../core/theme/color_schemes.dart';
import '../../../core/utils/format_helpers.dart';
import '../../../models/bill.dart';
import '../../../models/product.dart';

class DeletedCreditBillCard extends StatelessWidget {
  final CreditBill bill;
  final DateTime deletedAt;
  final String deletedByDevice;
  final bool expanded;
  final VoidCallback onToggle;
  final Product? Function(String) productLookup;

  const DeletedCreditBillCard({
    super.key,
    required this.bill,
    required this.deletedAt,
    required this.deletedByDevice,
    required this.expanded,
    required this.onToggle,
    required this.productLookup,
  });

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
                      const SizedBox(height: 2),
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
          if (expanded) _Details(
            bill: bill,
            deletedAt: deletedAt,
            deletedByDevice: deletedByDevice,
            productLookup: productLookup,
          ),
        ],
      ),
    );
  }
}

class _Details extends StatelessWidget {
  final CreditBill bill;
  final DateTime deletedAt;
  final String deletedByDevice;
  final Product? Function(String) productLookup;

  const _Details({
    required this.bill,
    required this.deletedAt,
    required this.deletedByDevice,
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
              // ── Original bill info ────────────────────
              _InfoBlock(
                label: 'Bill #${bill.id}',
                labelBold: true,
                labelColor: AppColors.ink600,
              ),
              const SizedBox(height: 3),
              _InfoRow(
                  prefix: 'Created: ', value: '${bill.date} · ${bill.time}'),
              _DeviceRow(prefix: 'Created by: ', device: bill.device,
                  color: AppColors.ink900),
              // ── Moved-to-credit info (if applicable) ──
              if (bill.movedToCreditByDevice != null) ...[
                const SizedBox(height: 6),
                Container(height: 1, color: AppColors.border),
                const SizedBox(height: 6),
                _DeviceRow(
                  prefix: 'Moved to credit by: ',
                  device: bill.movedToCreditByDevice!,
                  color: AppColors.primary,
                ),
                if (bill.movedToCreditAt != null)
                  _InfoRow(
                    prefix: 'Moved at: ',
                    value: FormatHelpers.formatDateTime(bill.movedToCreditAt!),
                  ),
              ],
              // ── Deletion info ─────────────────────────
              const SizedBox(height: 6),
              Container(height: 1, color: AppColors.border),
              const SizedBox(height: 6),
              _DeviceRow(
                prefix: 'Deleted by: ',
                device: deletedByDevice.isEmpty ? '—' : deletedByDevice,
                color: AppColors.danger,
              ),
              _InfoRow(
                prefix: 'Deleted at: ',
                value: FormatHelpers.formatDateTime(deletedAt),
              ),
              const SizedBox(height: 9),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 11, vertical: 8),
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

class _InfoBlock extends StatelessWidget {
  final String label;
  final bool labelBold;
  final Color labelColor;

  const _InfoBlock({
    required this.label,
    this.labelBold = false,
    this.labelColor = AppColors.ink600,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: labelBold ? FontWeight.w600 : FontWeight.w400,
        color: labelColor,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String prefix;
  final String value;

  const _InfoRow({required this.prefix, required this.value});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: prefix,
            style: const TextStyle(fontSize: 10, color: AppColors.ink400),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(fontSize: 10, color: AppColors.ink600),
          ),
        ],
      ),
    );
  }
}

class _DeviceRow extends StatelessWidget {
  final String prefix;
  final String device;
  final Color color;

  const _DeviceRow({
    required this.prefix,
    required this.device,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: prefix,
            style: const TextStyle(fontSize: 10, color: AppColors.ink400),
          ),
          TextSpan(
            text: device,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
