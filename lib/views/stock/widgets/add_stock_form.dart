import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_strings.dart';
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
  final TextEditingController _pattyCtrl = TextEditingController();
  final TextEditingController _trayCtrl = TextEditingController();
  bool _submitting = false;

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
  void dispose() {
    _pattyCtrl.dispose();
    _trayCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stock = context.watch<StockViewModel>();
    final patties = int.tryParse(stock.formulaPattyText) ?? 0;
    final traysInput = int.tryParse(stock.formulaTrayText) ?? 0;
    final trays = patties * 12 + traysInput;
    final eggs = patties * 360 + traysInput * 30;

    // Keep controllers in sync with viewmodel
    if (_pattyCtrl.text != stock.formulaPattyText) {
      _pattyCtrl.value = TextEditingValue(
        text: stock.formulaPattyText,
        selection: TextSelection.collapsed(
          offset: stock.formulaPattyText.length,
        ),
      );
    }
    if (_trayCtrl.text != stock.formulaTrayText) {
      _trayCtrl.value = TextEditingValue(
        text: stock.formulaTrayText,
        selection: TextSelection.collapsed(
          offset: stock.formulaTrayText.length,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Card ──
        Container(
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
                  vertical: 11,
                ),
                decoration: const BoxDecoration(color: AppColors.primarySoft),
                child: const Row(
                  children: [
                    Expanded(
                      child: _FormulaUnit(value: '1', label: 'PATTY'),
                    ),
                    _FormulaDivider(),
                    Expanded(
                      child: _FormulaUnit(value: '12', label: 'TRAYS'),
                    ),
                    _FormulaDivider(),
                    Expanded(
                      child: _FormulaUnit(value: '30', label: 'EGGS / TRAY'),
                    ),
                    _FormulaDivider(),
                    Expanded(
                      child: _FormulaUnit(value: '360', label: 'TOTAL EGGS'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 1, color: AppColors.border),

              // ── Patty input ──
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Patties Received',
                                style: AppTextStyles.bodyMd,
                              ),
                              Text('پٹی', style: AppTextStyles.urdu(size: 10)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 110,
                          child: TextField(
                            controller: _pattyCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: stock.setFormulaPatty,
                            textAlign: TextAlign.center,
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: '0',
                              suffixText: 'patties',
                              suffixStyle: const TextStyle(
                                fontSize: 11,
                                color: AppColors.ink400,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 11,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: AppColors.border,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: AppColors.border,
                                ),
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
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ── Trays input ──
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Trays Received',
                                style: AppTextStyles.bodyMd,
                              ),
                              Text('ٹریز', style: AppTextStyles.urdu(size: 10)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 110,
                          child: TextField(
                            controller: _trayCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: stock.setFormulaTray,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: '0',
                              suffixText: 'trays',
                              suffixStyle: const TextStyle(
                                fontSize: 11,
                                color: AppColors.ink400,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 11,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: AppColors.border,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: AppColors.border,
                                ),
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
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ── Auto-calculated summary ──
                    if (patties > 0 || traysInput > 0)
                      Row(
                        children: [
                          _SummaryChip(value: '$trays', label: 'trays'),
                          const SizedBox(width: 8),
                          _SummaryChip(
                            value: '$eggs',
                            label: 'eggs',
                            highlight: true,
                          ),
                        ],
                      )
                    else
                      Text(
                        'Enter the number of patties or trays received',
                        style: TextStyle(fontSize: 11, color: AppColors.ink400),
                      ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
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

// ── Summary chip ───────────────────────────────────────────────────────────

class _SummaryChip extends StatelessWidget {
  final String value;
  final String label;
  final bool highlight;

  const _SummaryChip({
    required this.value,
    required this.label,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.primary.withValues(alpha: 0.08)
            : AppColors.primarySoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: highlight
              ? AppColors.primary.withValues(alpha: 0.25)
              : AppColors.primarySoftBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: highlight ? AppColors.primary : AppColors.ink900,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.ink600),
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

class _FormulaDivider extends StatelessWidget {
  const _FormulaDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        '=',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.primarySoftBorder,
        ),
      ),
    );
  }
}
