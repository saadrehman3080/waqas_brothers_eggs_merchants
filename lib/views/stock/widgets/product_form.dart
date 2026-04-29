import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/constants/input_styles.dart';
import '../../../core/theme/color_schemes.dart';
import '../../../core/theme/text_styles.dart';
import '../../../viewmodels/stock_viewmodel.dart';
import '../../widgets/app_button.dart';

class ProductForm extends StatefulWidget {
  final VoidCallback onCancel;
  final Future<void> Function() onSubmit;

  const ProductForm({
    super.key,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final TextEditingController _nameEnCtrl = TextEditingController();
  final TextEditingController _nameUrCtrl = TextEditingController();
  final TextEditingController _priceCtrl = TextEditingController();
  final TextEditingController _revenuePerUnitCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final stock = context.read<StockViewModel>();
    _nameEnCtrl.text = stock.nameEn;
    _nameUrCtrl.text = stock.nameUr;
    _priceCtrl.text = stock.priceText;
    _revenuePerUnitCtrl.text = stock.revenuePerUnitText;
  }

  @override
  void dispose() {
    _nameEnCtrl.dispose();
    _nameUrCtrl.dispose();
    _priceCtrl.dispose();
    _revenuePerUnitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stock = context.watch<StockViewModel>();
    final isEditing = stock.isEditing;
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
          Text(
            isEditing ? 'Edit Product' : 'New Product',
            style: AppTextStyles.bodyLg,
          ),
          const SizedBox(height: 2),
          Text(
            isEditing ? AppStrings.urdEdit : AppStrings.urdNewProduct,
            style: AppTextStyles.urdu(size: 12),
          ),
          const SizedBox(height: 16),
          _label('Name (English)'),
          const SizedBox(height: 5),
          TextField(
            controller: _nameEnCtrl,
            onChanged: stock.setNameEn,
            decoration: InputStyles.field(hint: 'e.g. Egg Dozen'),
            style: const TextStyle(fontSize: 13, color: AppColors.ink900),
          ),
          const SizedBox(height: 11),
          _label('Name (Urdu)'),
          const SizedBox(height: 5),
          TextField(
            controller: _nameUrCtrl,
            onChanged: stock.setNameUr,
            decoration: InputStyles.field(hint: 'مثال: درجن انڈے'),
            style: const TextStyle(fontSize: 13, color: AppColors.ink900),
          ),
          const SizedBox(height: 11),
          _label('Price (Rs)'),
          const SizedBox(height: 5),
          TextField(
            controller: _priceCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: stock.setPriceText,
            decoration: InputStyles.field(hint: 'e.g. 180'),
            style: const TextStyle(fontSize: 13, color: AppColors.ink900),
          ),
          const SizedBox(height: 11),
          _label('Revenue Per Unit (Rs)'),
          const SizedBox(height: 5),
          TextField(
            controller: _revenuePerUnitCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: stock.setRevenuePerUnitText,
            decoration: InputStyles.field(hint: 'e.g. 30'),
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
                  label: isEditing ? 'Save' : 'Add Product',
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

  Widget _label(String label) => Text(
    label.toUpperCase(),
    style: const TextStyle(
      fontSize: 10,
      color: AppColors.ink600,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
    ),
  );
}
