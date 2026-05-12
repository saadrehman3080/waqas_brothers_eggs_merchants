import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/color_schemes.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/custom_snackbar.dart';
import '../../core/utils/format_helpers.dart';
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
  String? _expandedId;
  DateTime _selectedDate = DateTime.now();
  List<CashBill>? _historicalBills; // null = use today's live stream
  bool _dateLoading = false;

  bool get _isToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: AppColors.surface,
            onSurface: AppColors.ink900,
          ),
          dialogTheme: DialogThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null || !mounted) return;

    setState(() {
      _selectedDate = picked;
      _historicalBills = null;
      _expandedId = null;
    });

    if (_isToday) return; // live stream already has today

    setState(() => _dateLoading = true);
    final date = FormatHelpers.dateKey(_selectedDate);
    final bills = await context.read<InventoryViewModel>().fetchCashBillsForDate(date);
    if (!mounted) return;
    setState(() {
      _historicalBills = bills;
      _dateLoading = false;
    });
  }

  Future<void> _convertToCredit(BuildContext context, String id) async {
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

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryViewModel>();

    final cashBills = (_isToday
            ? inventory.bills.where((b) => b.type == BillType.cash).toList()
            : (_historicalBills ?? <CashBill>[]))
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final isLoading = _isToday ? inventory.cashBillsLoading : _dateLoading;

    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          TopBar(
            title: AppStrings.history,
            urdu: AppStrings.urdCash,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _isToday
                          ? AppColors.background
                          : AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _isToday
                            ? AppColors.border
                            : AppColors.primarySoftBorder,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 11,
                          color: _isToday
                              ? AppColors.ink600
                              : AppColors.primary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _isToday
                              ? 'Today'
                              : FormatHelpers.headerDate(_selectedDate),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _isToday
                                ? AppColors.ink600
                                : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primarySoftBorder),
                  ),
                  child: Text(
                    '${cashBills.length} bills',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : cashBills.isEmpty
                ? Center(
                    child: EmptyState(
                      icon: Icons.receipt_long_outlined,
                      message: _isToday
                          ? 'No cash sales today'
                          : 'No bills on ${FormatHelpers.headerDate(_selectedDate)}',
                      subtitle: _isToday
                          ? 'Cash bills will appear here once created.'
                          : 'No cash sales were recorded for this date.',
                    ),
                  )
                : ListView.builder(
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
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
