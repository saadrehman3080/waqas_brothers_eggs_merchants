import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/constants/input_styles.dart';
import '../../../core/theme/color_schemes.dart';
import '../../../core/theme/text_styles.dart';
import '../../../viewmodels/stock_viewmodel.dart';
import '../../widgets/app_button.dart';

class AddStockForm extends StatefulWidget {
  final VoidCallback onCancel;
  final Future<void> Function() onSubmit;

  const AddStockForm({
    super.key,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  State<AddStockForm> createState() => _AddStockFormState();
}

class _AddStockFormState extends State<AddStockForm> {
  final TextEditingController _qtyCtrl = TextEditingController();
  final TextEditingController _revenuePerUnitCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final stock = context.read<StockViewModel>();
    _qtyCtrl.text = stock.stockQtyText;
    _revenuePerUnitCtrl.text = stock.addStockRevenuePerUnitText;
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _revenuePerUnitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stock = context.watch<StockViewModel>();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Add Stock', style: AppTextStyles.bodyLg),
          const SizedBox(height: 2),
          Text(AppStrings.urdAddStock, style: AppTextStyles.urdu(size: 12)),
          const SizedBox(height: 16),
          _Label('Product'),
          const SizedBox(height: 5),
          DropdownButtonFormField<int>(
            initialValue: stock.selectedProductId,
            decoration: InputStyles.field(),
            hint: const Text(
              'Select product…',
              style: TextStyle(fontSize: 13, color: AppColors.ink600),
            ),
            items: stock.products
                .map(
                  (p) => DropdownMenuItem(
                    value: p.id,
                    child: Text(p.nameEn, style: const TextStyle(fontSize: 13)),
                  ),
                )
                .toList(),
            onChanged: stock.setSelectedProductId,
          ),
          const SizedBox(height: 11),
          _Label('Quantity'),
          const SizedBox(height: 5),
          TextField(
            controller: _qtyCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: stock.setStockQtyText,
            decoration: InputStyles.field(hint: 'e.g. 100'),
            style: const TextStyle(fontSize: 13, color: AppColors.ink900),
          ),
          const SizedBox(height: 11),
          _Label('Revenue Per Unit (Rs)'),
          const SizedBox(height: 5),
          TextField(
            controller: _revenuePerUnitCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: stock.setAddStockRevenuePerUnitText,
            decoration: InputStyles.field(hint: 'e.g. 30 (optional)'),
            style: const TextStyle(fontSize: 13, color: AppColors.ink900),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Cancel',
                  variant: AppButtonVariant.ghost,
                  full: true,
                  onPressed: widget.onCancel,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppButton(
                  label: 'Add Stock',
                  full: true,
                  onPressed: widget.onSubmit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String label;
  // ignore: unused_element_parameter
  const _Label(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 10,
        color: AppColors.ink600,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );
  }
}
