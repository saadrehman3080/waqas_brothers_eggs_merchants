import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

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
  final _nameEnCtrl = TextEditingController();
  final _nameUrCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _revenueCtrl = TextEditingController();

  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final stock = context.read<StockViewModel>();
    _nameEnCtrl.text = stock.nameEn;
    _nameUrCtrl.text = stock.nameUr;
    _priceCtrl.text = stock.priceText;
    _revenueCtrl.text = stock.revenuePerUnitText;
  }

  @override
  void dispose() {
    _nameEnCtrl.dispose();
    _nameUrCtrl.dispose();
    _priceCtrl.dispose();
    _revenueCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      await widget.onSubmit();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stock = context.watch<StockViewModel>();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Edit Product', style: AppTextStyles.bodyLg),
                const SizedBox(height: 1),
                Text(
                  stock.editingProduct?.nameEn ?? '',
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.ink600),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.border),

          // ── Fields ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _label('Name (English)'),
                const SizedBox(height: 5),
                TextField(
                  controller: _nameEnCtrl,
                  readOnly: true,
                  decoration: InputStyles.field().copyWith(
                    fillColor: AppColors.background,
                    // suffixIcon: const Icon(
                    //   Icons.lock_outline_rounded,
                    //   size: 14,
                    //   color: AppColors.ink400,
                    // ),
                  ),
                  style: const TextStyle(fontSize: 13, color: AppColors.ink400),
                ),
                const SizedBox(height: 12),
                _label('Name (Urdu)'),
                const SizedBox(height: 5),
                TextField(
                  controller: _nameUrCtrl,
                  readOnly: true,
                  decoration: InputStyles.field().copyWith(
                    fillColor: AppColors.background,
                    // suffixIcon: const Icon(
                    //   Icons.lock_outline_rounded,
                    //   size: 14,
                    //   color: AppColors.ink400,
                    // ),
                  ),
                  style: const TextStyle(fontSize: 13, color: AppColors.ink400),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Price (Rs)'),
                          const SizedBox(height: 5),
                          TextField(
                            controller: _priceCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: stock.setPriceText,
                            decoration: InputStyles.field(hint: '0'),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.ink900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Revenue / Unit (Rs)'),
                          const SizedBox(height: 5),
                          TextField(
                            controller: _revenueCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: stock.setRevenuePerUnitText,
                            decoration: InputStyles.field(hint: '0'),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.ink900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Cancel',
                        variant: AppButtonVariant.ghost,
                        full: true,
                        onPressed: _submitting ? null : widget.onCancel,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AppButton(
                        label: 'Save',
                        full: true,
                        busy: _submitting,
                        onPressed: _handleSubmit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
    text.toUpperCase(),
    style: const TextStyle(
      fontSize: 9,
      color: AppColors.ink600,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
    ),
  );
}
