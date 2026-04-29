import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/color_schemes.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/custom_snackbar.dart';
import '../../models/bill.dart';
import '../../viewmodels/inventory_viewmodel.dart';
import '../widgets/empty_state.dart';
import '../widgets/top_bar.dart';
import 'widgets/history_bill_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int? _expandedId;

  Future<void> _convertToCredit(BuildContext context, int id) async {
    final inventory = context.read<InventoryViewModel>();
    final bill = inventory.bills.firstWhere((b) => b.id == id);

    // Check if customer is "Walk-in" (empty customer field)
    if (bill.customer.isEmpty) {
      if (!context.mounted) return;
      // Show dialog to ask for customer name
      final customerName = await _showCustomerNameDialog(context);
      if (customerName == null || customerName.isEmpty) {
        return; // User cancelled or didn't enter a name
      }
    } else {
      // For named customers, ask for confirmation before moving to credit
      if (!context.mounted) return;
      final confirmed = await _showMoveToCrediConfirmationDialog(
        context,
        bill.customer,
      );
      if (!confirmed) {
        return; // User cancelled the conversion
      }
    }

    // Proceed with converting to credit
    if (!context.mounted) return;
    final ok = await inventory.changeBillType(id, BillType.credit);
    if (!context.mounted) return;
    if (ok) {
      CustomSnackbar.info(context, 'Moved to Credit');
    } else {
      CustomSnackbar.error(context, 'Failed to move bill');
    }
  }

  Future<void> _delete(BuildContext context, int id) async {
    if (!context.mounted) return;

    // Show confirmation dialog
    final confirmed = await _showDeleteConfirmationDialog(context);
    if (!confirmed) {
      return; // User cancelled the deletion
    }

    final ok = await context.read<InventoryViewModel>().deleteBill(id);
    if (!context.mounted) return;
    if (ok) {
      CustomSnackbar.success(context, 'Bill deleted');
    } else {
      CustomSnackbar.error(context, 'Failed to delete');
    }
  }

  Future<String?> _showCustomerNameDialog(BuildContext context) async {
    final controller = TextEditingController();

    return showDialog<String?>(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.overlay,
      builder: (BuildContext dialogContext) {
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
                Text('Enter Customer Name', style: AppTextStyles.screenTitle),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Customer name',
                    hintStyle: AppTextStyles.bodySm,
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
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  style: AppTextStyles.bodyMd,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.ink600,
                      ),
                      child: Text('Cancel', style: AppTextStyles.buttonSm),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: () =>
                          Navigator.pop(dialogContext, controller.text),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                      child: Text('Continue', style: AppTextStyles.buttonSm),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> _showMoveToCrediConfirmationDialog(
    BuildContext context,
    String customerName,
  ) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          barrierColor: AppColors.overlay,
          builder: (BuildContext dialogContext) {
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
                    Text('Move to Credit?', style: AppTextStyles.screenTitle),
                    const SizedBox(height: 12),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: AppTextStyles.bodySm,
                        children: [
                          const TextSpan(text: 'Move this bill for '),
                          TextSpan(
                            text: customerName,
                            style: AppTextStyles.bodySm.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink900,
                            ),
                          ),
                          const TextSpan(text: ' to Credit?'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.ink600,
                          ),
                          child: Text('Cancel', style: AppTextStyles.buttonSm),
                        ),
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                          ),
                          child: Text(
                            'Move to Credit',
                            style: AppTextStyles.buttonSm,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ) ??
        false;
  }

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          barrierColor: AppColors.overlay,
          builder: (BuildContext dialogContext) {
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
                    Text(
                      'Delete Bill?',
                      style: AppTextStyles.screenTitle.copyWith(
                        color: AppColors.danger,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Are you sure you want to delete this bill? This action cannot be undone.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySm,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.ink600,
                          ),
                          child: Text('Cancel', style: AppTextStyles.buttonSm),
                        ),
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.danger,
                          ),
                          child: Text('Delete', style: AppTextStyles.buttonSm),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryViewModel>();
    final cashBills = inventory.bills
        .where((b) => b.type == BillType.cash)
        .toList();

    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          TopBar(
            title: AppStrings.history,
            urdu: AppStrings.urdCash,
            trailing: Text(
              '${cashBills.length} bills',
              style: TextStyle(fontSize: 12, color: AppColors.primary),
            ),
          ),
          Expanded(
            child: cashBills.isEmpty
                ? const Center(
                    child: EmptyState(
                      message: 'No cash sales yet',
                      icon: Icons.receipt_long_outlined,
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: inventory.refresh,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(13, 7, 13, 16),
                      itemCount: cashBills.length,
                      itemBuilder: (_, i) {
                        final b = cashBills[i];
                        return HistoryBillCard(
                          bill: b,
                          expanded: _expandedId == b.id,
                          onToggle: () => setState(() {
                            _expandedId = _expandedId == b.id ? null : b.id;
                          }),
                          productLookup: inventory.productById,
                          onConvertToCredit: () =>
                              _convertToCredit(context, b.id),
                          onReprint: () =>
                              CustomSnackbar.info(context, 'Reprint queued'),
                          onDelete: () => _delete(context, b.id),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
