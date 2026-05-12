import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/input_styles.dart';
import '../../../core/theme/color_schemes.dart';
import '../../../models/product.dart';
import '../../widgets/app_button.dart';

/// Modal that lets the user pick a preset quantity or type a custom value.
/// Returns the chosen quantity, or null if cancelled.
class QuantityDialog extends StatefulWidget {
  final Product product;
  final int currentQty;

  const QuantityDialog({super.key, required this.product, this.currentQty = 0});

  static Future<int?> show(
    BuildContext context, {
    required Product product,
    int currentQty = 0,
  }) {
    return showDialog<int>(
      context: context,
      barrierColor: AppColors.overlay,
      builder: (_) => QuantityDialog(product: product, currentQty: currentQty),
    );
  }

  @override
  State<QuantityDialog> createState() => _QuantityDialogState();
}

class _QuantityDialogState extends State<QuantityDialog> {
  late final int? _selected = widget.currentQty > 0 ? widget.currentQty : null;
  final TextEditingController _customController = TextEditingController();

  static const List<int> _presets = [5, 10, 15, 25];

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  void _commit(int qty) => Navigator.of(context).pop(qty);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Quantity',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.ink900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.product.nameEn,
              style: const TextStyle(fontSize: 12, color: AppColors.ink600),
            ),
            const SizedBox(height: 6),
            Text(
              '${widget.product.remaining} in stock',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: widget.product.remaining <= 0
                    ? AppColors.danger
                    : widget.product.isLowStock
                    ? AppColors.warning
                    : AppColors.success,
              ),
            ),
            const SizedBox(height: 14),
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2.4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: _presets.map((q) {
                final enabled = q <= widget.product.remaining;
                return _PresetTile(
                  qty: q,
                  selected: _selected == q,
                  enabled: enabled,
                  onTap: enabled ? () => _commit(q) : () {},
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            _PresetTile(
              qty: 100,
              selected: _selected == 100,
              enabled: 100 <= widget.product.remaining,
              fullWidth: true,
              onTap: 100 <= widget.product.remaining
                  ? () => _commit(100)
                  : () {},
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _customController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputStyles.field(hint: 'Custom…'),
                  ),
                ),
                const SizedBox(width: 8),
                AppButton(
                  label: 'Set',
                  onPressed: () {
                    final q = int.tryParse(_customController.text);
                    if (q != null && q > 0) {
                      if (q > widget.product.remaining) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Maximum available: ${widget.product.remaining}',
                            ),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        _commit(widget.product.remaining);
                      } else {
                        _commit(q);
                      }
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            AppButton(
              label: 'Cancel',
              variant: AppButtonVariant.ghost,
              full: true,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _PresetTile extends StatelessWidget {
  final int qty;
  final bool selected;
  final bool enabled;
  final bool fullWidth;
  final VoidCallback onTap;

  const _PresetTile({
    required this.qty,
    required this.selected,
    required this.onTap,
    this.enabled = true,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final tile = InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: !enabled
              ? AppColors.background
              : selected
              ? AppColors.primarySoft
              : AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: !enabled
                ? AppColors.border
                : selected
                ? AppColors.primary
                : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Text(
          '$qty',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: !enabled
                ? AppColors.ink400
                : selected
                ? AppColors.primary
                : AppColors.ink900,
          ),
        ),
      ),
    );
    return fullWidth ? SizedBox(width: double.infinity, child: tile) : tile;
  }
}
