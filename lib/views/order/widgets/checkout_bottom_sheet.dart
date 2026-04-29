import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/constants/input_styles.dart';
import '../../../core/theme/color_schemes.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/format_helpers.dart';
import '../../../models/bill.dart';
import '../../../models/product.dart';
import '../../../viewmodels/inventory_viewmodel.dart';
import '../../../viewmodels/order_viewmodel.dart';
import '../../widgets/app_button.dart';

class CheckoutBottomSheet extends StatefulWidget {
  const CheckoutBottomSheet({super.key});

  static Future<bool?> show(BuildContext context) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.overlay,
      builder: (sheetContext) => ChangeNotifierProvider.value(
        value: context.read<OrderViewModel>(),
        child: const CheckoutBottomSheet(),
      ),
    );
  }

  @override
  State<CheckoutBottomSheet> createState() => _CheckoutBottomSheetState();
}

class _CheckoutBottomSheetState extends State<CheckoutBottomSheet> {
  final TextEditingController _customerCtrl = TextEditingController();
  final TextEditingController _discountCtrl = TextEditingController();
  static const List<String> _quickCustomers = [
    'Walk-in',
    'Ahmed Store',
    'Bilal Mart',
    'Tariq',
  ];

  @override
  void initState() {
    super.initState();
    final order = context.read<OrderViewModel>();
    _customerCtrl.text = order.customer;
    _discountCtrl.text = order.discountText;
  }

  @override
  void dispose() {
    _customerCtrl.dispose();
    _discountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final order = context.read<OrderViewModel>();
    final ok = await order.submit();
    if (!mounted) return;
    Navigator.of(context).pop(ok);
  }

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderViewModel>();
    final inventory = context.watch<InventoryViewModel>();
    final selected = order.selectedProducts();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(onClose: () => Navigator.of(context).pop()),
            const SizedBox(height: 14),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ItemList(items: selected, qtyOf: order.qtyOf),
                    const SizedBox(height: 14),
                    _SectionLabel('Payment Type'),
                    const SizedBox(height: 7),
                    _PaymentToggle(
                      selected: order.paymentType,
                      onChanged: order.setPaymentType,
                    ),
                    const SizedBox(height: 13),
                    _SectionLabel('Customer'),
                    const SizedBox(height: 7),
                    _CustomerChips(
                      customers: _quickCustomers,
                      selected: order.customer,
                      onSelect: (c) {
                        final value = c == AppStrings.walkInCustomer ? '' : c;
                        order.setCustomer(value);
                        _customerCtrl.text = value;
                        _customerCtrl.selection = TextSelection.collapsed(
                          offset: value.length,
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _customerCtrl,
                      onChanged: order.setCustomer,
                      decoration: InputStyles.field(hint: 'Or type name…'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.ink900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SectionLabel('Discount (Rs.)'),
                    const SizedBox(height: 7),
                    TextField(
                      controller: _discountCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: order.setDiscountText,
                      decoration: InputStyles.field(hint: '0'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.ink900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _TotalCard(total: order.total),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Save',
                    variant: AppButtonVariant.ghost,
                    full: true,
                    busy: order.isSubmitting,
                    onPressed: inventory.isLoading || order.isSubmitting
                        ? null
                        : _submit,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppButton(
                    label: 'Print Bill',
                    full: true,
                    icon: Icons.print_outlined,
                    busy: order.isSubmitting,
                    onPressed: inventory.isLoading || order.isSubmitting
                        ? null
                        : _submit,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onClose;
  const _Header({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text(
              'Checkout ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.ink900,
              ),
            ),
            Text(AppStrings.urdCheckout, style: AppTextStyles.urdu(size: 9)),
          ],
        ),
        InkWell(
          onTap: onClose,
          borderRadius: BorderRadius.circular(7),
          child: Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Icon(Icons.close, size: 14, color: AppColors.ink600),
          ),
        ),
      ],
    );
  }
}

class _ItemList extends StatelessWidget {
  final List<Product> items;
  final int Function(int) qtyOf;

  const _ItemList({required this.items, required this.qtyOf});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final p = items[i];
          final q = qtyOf(p.id);
          final isLast = i == items.length - 1;
          final radius = i == 0
              ? const BorderRadius.vertical(top: Radius.circular(10))
              : isLast
              ? const BorderRadius.vertical(bottom: Radius.circular(10))
              : BorderRadius.zero;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
            decoration: BoxDecoration(
              color: i.isEven ? AppColors.surface : AppColors.background,
              borderRadius: radius,
              border: Border(
                bottom: isLast
                    ? BorderSide.none
                    : const BorderSide(color: AppColors.border),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.nameEn, style: AppTextStyles.bodyMd),
                      Text(
                        '$q × ${FormatHelpers.currency(p.price)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.ink600,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  FormatHelpers.currency(q * p.price),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink900,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _PaymentToggle extends StatelessWidget {
  final BillType selected;
  final ValueChanged<BillType> onChanged;

  const _PaymentToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: BillType.values.map((type) {
        final active = selected == type;
        final isLast = type == BillType.values.last;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(9),
              onTap: () => onChanged(type),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 11),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active ? AppColors.primarySoft : AppColors.background,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: active ? AppColors.primary : AppColors.border,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  type == BillType.cash ? 'Cash' : 'Credit',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: active ? AppColors.primary : AppColors.ink600,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CustomerChips extends StatelessWidget {
  final List<String> customers;
  final String selected;
  final ValueChanged<String> onSelect;

  const _CustomerChips({
    required this.customers,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: customers.map((c) {
        final value = c == AppStrings.walkInCustomer ? '' : c;
        final active = selected == value;
        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => onSelect(c),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: active ? AppColors.primarySoft : AppColors.background,
              border: Border.all(
                color: active ? AppColors.primary : AppColors.border,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              c,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: active ? AppColors.primary : AppColors.ink600,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _TotalCard extends StatelessWidget {
  final double total;
  const _TotalCard({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            FormatHelpers.currency(total),
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 10,
        color: AppColors.ink600,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
  }
}
