import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/color_schemes.dart';
import '../../../core/theme/text_styles.dart';
import '../../../models/product.dart';
import '../../../viewmodels/stock_viewmodel.dart';
import '../../widgets/app_button.dart';

const _kFormulaNames = {'Patty', 'Egg Tray', 'Egg Dozen', 'Single Egg'};

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
  final Map<String, TextEditingController> _controllers = {};

  final TextEditingController _pattyCtrl = TextEditingController();
  final TextEditingController _trayCtrl = TextEditingController();
  final TextEditingController _dozenCtrl = TextEditingController();
  final TextEditingController _singleCtrl = TextEditingController();

  bool _submitting = false;
  StockViewModel? _stockRef;

  Future<void> _handleSubmit() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      await widget.onSubmit();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  TextEditingController _controllerFor(String productId) =>
      _controllers.putIfAbsent(productId, () => TextEditingController());

  TextEditingController _formulaCtrlFor(String nameEn) {
    switch (nameEn) {
      case 'Patty':
        return _pattyCtrl;
      case 'Egg Tray':
        return _trayCtrl;
      case 'Egg Dozen':
        return _dozenCtrl;
      case 'Single Egg':
        return _singleCtrl;
      default:
        return _pattyCtrl;
    }
  }

  ValueChanged<String> _formulaOnChangedFor(
    StockViewModel stock,
    String nameEn,
  ) {
    switch (nameEn) {
      case 'Patty':
        return stock.setFormulaPatty;
      case 'Egg Tray':
        return stock.setFormulaTray;
      case 'Egg Dozen':
        return stock.setFormulaDozen;
      case 'Single Egg':
        return stock.setFormulaSingle;
      default:
        return stock.setFormulaPatty;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_stockRef == null) {
      _stockRef = context.read<StockViewModel>();
      _stockRef!.addListener(_onViewModelChanged);
    }
  }

  void _onViewModelChanged() {
    if (!mounted) return;
    final s = _stockRef!;
    _syncCtrl(_pattyCtrl, s.formulaPattyText);
    _syncCtrl(_trayCtrl, s.formulaTrayText);
    _syncCtrl(_dozenCtrl, s.formulaDozenText);
    _syncCtrl(_singleCtrl, s.formulaSingleText);
    for (final p in s.products) {
      final ctrl = _controllers[p.id];
      if (ctrl != null) {
        _syncCtrl(ctrl, s.stockQtyTextFor(p.id));
      }
    }
  }

  void _syncCtrl(TextEditingController ctrl, String value) {
    if (ctrl.text != value) {
      ctrl.value = TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    }
  }

  @override
  void dispose() {
    _stockRef?.removeListener(_onViewModelChanged);
    _pattyCtrl.dispose();
    _trayCtrl.dispose();
    _dozenCtrl.dispose();
    _singleCtrl.dispose();
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stock = context.watch<StockViewModel>();
    final products = stock.products;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Product list card ──
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Add Stock', style: AppTextStyles.bodyLg),
                    const SizedBox(height: 1),
                    Text(
                      AppStrings.urdAddStock,
                      style: AppTextStyles.urdu(size: 11),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1, color: AppColors.border),
              // ── Formula reference strip ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                color: AppColors.primarySoft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    _FormulaUnit(value: '1', label: 'PATTY'),
                    _FormulaEq(),
                    _FormulaUnit(value: '24', label: 'TRAYS'),
                    _FormulaEq(),
                    _FormulaUnit(value: '48', label: 'DOZENS'),
                    _FormulaEq(),
                    _FormulaUnit(value: '576', label: 'SINGLES'),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1, color: AppColors.border),
              for (int i = 0; i < products.length; i++) ...[
                () {
                  final p = products[i];
                  final isFormula = _kFormulaNames.contains(p.nameEn);
                  return _ProductRow(
                    product: p,
                    controller: isFormula
                        ? _formulaCtrlFor(p.nameEn)
                        : _controllerFor(p.id),
                    onChanged: isFormula
                        ? _formulaOnChangedFor(stock, p.nameEn)
                        : (text) => stock.setStockQtyText(p.id, text),
                    isLast: i == products.length - 1,
                  );
                }(),
              ],
            ],
          ),
        ),

        const SizedBox(height: 10),

        // ── Actions ──
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
                label: 'Add Stock',
                full: true,
                busy: _submitting,
                onPressed: _handleSubmit,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Product row ────────────────────────────────────────────────────────────

class _ProductRow extends StatelessWidget {
  final Product product;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool isLast;

  const _ProductRow({
    required this.product,
    required this.controller,
    required this.onChanged,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : const BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          // Container(
          //   width: 36,
          //   height: 36,
          //   alignment: Alignment.center,
          //   decoration: BoxDecoration(
          //     color: AppColors.primarySoft,
          //     shape: BoxShape.circle,
          //     border: Border.all(color: AppColors.primarySoftBorder),
          //   ),
          //   child: Text(
          //     product.nameEn[0].toUpperCase(),
          //     style: const TextStyle(
          //       fontSize: 14,
          //       fontWeight: FontWeight.w800,
          //       color: AppColors.primary,
          //     ),
          //   ),
          // ),
          //const SizedBox(width: 10),
          // Names
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.nameEn, style: AppTextStyles.bodyMd),
                Text(product.nameUr, style: AppTextStyles.urdu(size: 10)),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Qty field — editable for all products; formula-driven ones cross-update
          SizedBox(
            width: 92,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: onChanged,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 9,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
                filled: true,
                fillColor: AppColors.background,
              ),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.ink900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Formula strip helpers ──────────────────────────────────────────────────

class _FormulaUnit extends StatelessWidget {
  final String value;
  final String label;

  const _FormulaUnit({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w600,
            color: AppColors.ink600,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

class _FormulaEq extends StatelessWidget {
  const _FormulaEq();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Text(
        '=',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.ink400,
        ),
      ),
    );
  }
}
