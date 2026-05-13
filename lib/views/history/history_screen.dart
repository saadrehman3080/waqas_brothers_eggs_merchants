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
import 'widgets/deleted_bill_card.dart';
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

  bool _showDeleted = false;
  List<({CashBill bill, DateTime deletedAt})> _deletedBills = const [];
  bool _deletedLoading = false;

  bool get _isToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  Future<void> _pickDate() async {
    DateTime tempDate = _selectedDate;

    final picked = await showDialog<DateTime>(
      context: context,
      barrierColor: AppColors.overlay,
      builder: (dialogContext) => StatefulBuilder(
        builder: (_, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            clipBehavior: Clip.hardEdge,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ──────────────────────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                  color: AppColors.primary,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SELECT DATE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.75),
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        FormatHelpers.headerDate(tempDate),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                // ── Calendar ────────────────────────────
                Theme(
                  data: ThemeData(
                    colorScheme: const ColorScheme.light(
                      primary: AppColors.primary,
                      onPrimary: Colors.white,
                      surface: AppColors.surface,
                      onSurface: AppColors.ink900,
                      onSurfaceVariant: AppColors.ink600,
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
                  child: CalendarDatePicker(
                    initialDate: tempDate,
                    firstDate: DateTime(2024),
                    lastDate: DateTime.now(),
                    onDateChanged: (date) =>
                        setDialogState(() => tempDate = date),
                  ),
                ),
                // ── Divider ─────────────────────────────
                Container(height: 1, color: AppColors.border),
                // ── Actions ─────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.ink600,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                        ),
                        child: Text('Cancel', style: AppTextStyles.buttonSm),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(dialogContext, tempDate),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          backgroundColor: AppColors.primarySoft,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                        ),
                        child: Text('Confirm', style: AppTextStyles.buttonSm),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (picked == null || !mounted) return;

    setState(() {
      _selectedDate = picked;
      _historicalBills = null;
      _expandedId = null;
      _showDeleted = false;
      _deletedBills = const [];
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

  void _resetToToday() {
    setState(() {
      _selectedDate = DateTime.now();
      _historicalBills = null;
      _expandedId = null;
      _showDeleted = false;
      _deletedBills = const [];
    });
  }

  Future<void> _toggleDeletedBills() async {
    if (_showDeleted) {
      setState(() {
        _showDeleted = false;
        _expandedId = null;
      });
      return;
    }

    setState(() {
      _showDeleted = true;
      _deletedLoading = true;
      _expandedId = null;
    });

    final date = FormatHelpers.dateKey(_selectedDate);
    final deleted = await context.read<InventoryViewModel>().fetchDeletedCashBillsForDate(date);
    if (!mounted) return;
    setState(() {
      _deletedBills = deleted;
      _deletedLoading = false;
    });
  }

  Future<void> _deleteBill(BuildContext context, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.overlay,
      builder: (dialogContext) => Dialog(
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
                style: AppTextStyles.screenTitle.copyWith(color: AppColors.danger),
              ),
              const SizedBox(height: 12),
              Text(
                'This bill will be removed from history and archived. This cannot be undone.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySm,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    style: TextButton.styleFrom(foregroundColor: AppColors.ink600),
                    child: Text('Cancel', style: AppTextStyles.buttonSm),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                    child: Text('Delete', style: AppTextStyles.buttonSm),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ) ?? false;

    if (!confirmed || !context.mounted) return;
    final ok = await context.read<InventoryViewModel>().deleteCashBill(id);
    if (!context.mounted) return;
    if (ok) {
      setState(() => _expandedId = null);
      CustomSnackbar.info(context, 'Bill deleted');
    } else {
      CustomSnackbar.error(context, 'Failed to delete bill');
    }
  }

  Future<void> _convertToCredit(BuildContext context, String id) async {
    final inventory = context.read<InventoryViewModel>();

    // Historical bills are not in the live stream — look up from the right source.
    final Bill bill;
    if (_isToday) {
      bill = inventory.bills.firstWhere((b) => b.id == id);
    } else {
      bill = _historicalBills!.firstWhere((b) => b.id == id);
    }

    String? resolvedCustomer;

    final isWalkIn = bill.customer.trim().isEmpty ||
        bill.customer == AppStrings.walkInCustomer;

    if (isWalkIn) {
      if (!context.mounted) return;
      final name = await _showCustomerNameDialog(context);
      if (name == null || name.trim().isEmpty) return;
      resolvedCustomer = name.trim();
    } else {
      if (!context.mounted) return;
      final confirmed = await _showMoveToCrediConfirmationDialog(
        context,
        bill.customer,
      );
      if (!confirmed) return;
    }

    if (!context.mounted) return;
    final ok = await inventory.changeBillType(
      bill,
      BillType.credit,
      customer: resolvedCustomer,
    );
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

    Widget body;
    if (_showDeleted) {
      if (_deletedLoading) {
        body = const Center(child: CircularProgressIndicator());
      } else if (_deletedBills.isEmpty) {
        body = Center(
          child: EmptyState(
            icon: Icons.delete_sweep_outlined,
            message: 'No deleted bills',
            subtitle: 'No bills were deleted on ${FormatHelpers.headerDate(_selectedDate)}.',
          ),
        );
      } else {
        final sorted = [..._deletedBills]
          ..sort((a, b) => b.deletedAt.compareTo(a.deletedAt));
        body = ListView.builder(
          padding: const EdgeInsets.fromLTRB(13, 7, 13, 16),
          itemCount: sorted.length,
          itemBuilder: (_, i) {
            final entry = sorted[i];
            return DeletedBillCard(
              bill: entry.bill,
              deletedAt: entry.deletedAt,
              expanded: _expandedId == entry.bill.id,
              onToggle: () => setState(() {
                _expandedId = _expandedId == entry.bill.id ? null : entry.bill.id;
              }),
              productLookup: inventory.productById,
            );
          },
        );
      }
    } else if (isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (cashBills.isEmpty) {
      body = Center(
        child: EmptyState(
          icon: Icons.receipt_long_outlined,
          message: _isToday
              ? 'No cash sales today'
              : 'No bills on ${FormatHelpers.headerDate(_selectedDate)}',
          subtitle: _isToday
              ? 'Cash bills will appear here once created.'
              : 'No cash sales were recorded for this date.',
        ),
      );
    } else {
      body = ListView.builder(
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
            onConvertToCredit: () => _convertToCredit(context, b.id),
            onReprint: () => CustomSnackbar.info(context, 'Reprint queued'),
            onDelete: _isToday ? () => _deleteBill(context, b.id) : null,
          );
        },
      );
    }

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
                  onTap: _isToday ? _pickDate : _resetToToday,
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
                        if (_isToday) ...[
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 11,
                            color: AppColors.ink600,
                          ),
                          const SizedBox(width: 5),
                        ],
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
                        if (!_isToday) ...[
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.close_rounded,
                            size: 11,
                            color: AppColors.primary,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: _toggleDeletedBills,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _showDeleted
                          ? AppColors.dangerSoft
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _showDeleted
                            ? AppColors.danger
                            : AppColors.border,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.delete_sweep_outlined,
                          size: 11,
                          color: _showDeleted
                              ? AppColors.danger
                              : AppColors.ink600,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Deleted',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _showDeleted
                                ? AppColors.danger
                                : AppColors.ink600,
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
          Expanded(child: body),
        ],
      ),
    );
  }
}
