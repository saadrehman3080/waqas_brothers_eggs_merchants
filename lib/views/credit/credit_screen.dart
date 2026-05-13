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
import 'widgets/credit_group_card.dart';
import 'widgets/deleted_credit_bill_card.dart';

class CreditScreen extends StatefulWidget {
  const CreditScreen({super.key});

  @override
  State<CreditScreen> createState() => _CreditScreenState();
}

class _CreditScreenState extends State<CreditScreen> {
  String? _expanded;

  bool _showDeleted = false;
  List<({CreditBill bill, DateTime deletedAt, String deletedByDevice})>
      _deletedBills = const [];
  bool _deletedLoading = false;
  String? _expandedDeletedId;

  Future<void> _toggleDeletedBills() async {
    if (_showDeleted) {
      setState(() {
        _showDeleted = false;
        _expandedDeletedId = null;
      });
      return;
    }
    setState(() {
      _showDeleted = true;
      _deletedLoading = true;
      _expandedDeletedId = null;
    });
    final results =
        await context.read<InventoryViewModel>().fetchDeletedCreditBills();
    if (!mounted) return;
    setState(() {
      _deletedBills = results;
      _deletedLoading = false;
    });
  }

  List<CreditGroup> _groupBills(List<Bill> bills) {
    final map = <String, _MutableGroup>{};
    for (final b in bills) {
      final key = b.displayCustomer;
      final group = map.putIfAbsent(key, () => _MutableGroup(key));
      group.bills.add(b);
      group.total += b.total;
    }
    return map.values
        .map((g) => CreditGroup(name: g.name, bills: g.bills, total: g.total))
        .toList();
  }

  Future<void> _markPaid(BuildContext context, Bill bill) async {
    if (!context.mounted) return;

    // Show confirmation dialog
    final confirmed = await _showMarkPaidConfirmationDialog(context);
    if (!confirmed) {
      return; // User cancelled
    }

    final ok = await context.read<InventoryViewModel>().changeBillType(
      bill,
      BillType.cash,
    );
    if (!context.mounted) return;
    if (ok) {
      CustomSnackbar.success(context, 'Marked as paid');
    } else {
      CustomSnackbar.error(context, 'Failed to mark paid');
    }
  }

  Future<void> _deleteBill(BuildContext context, Bill bill) async {
    if (bill is! CreditBill) return;
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
                style: AppTextStyles.screenTitle.copyWith(
                    color: AppColors.danger),
              ),
              const SizedBox(height: 12),
              Text(
                'This bill will be removed from credit and archived. This cannot be undone.',
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
                        foregroundColor: AppColors.ink600),
                    child: Text('Cancel', style: AppTextStyles.buttonSm),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.danger),
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
    final ok = await context.read<InventoryViewModel>().deleteCreditBill(bill);
    if (!context.mounted) return;
    if (ok) {
      CustomSnackbar.info(context, 'Bill deleted');
    } else {
      CustomSnackbar.error(context, 'Failed to delete bill');
    }
  }

  Future<bool> _showMarkPaidConfirmationDialog(BuildContext context) async {
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
                      'Mark as Paid?',
                      style: AppTextStyles.screenTitle.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Are you sure this bill has been paid?',
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
                            foregroundColor: AppColors.success,
                          ),
                          child: Text(
                            'Mark as Paid',
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
    final creditBills = inventory.bills
        .where((b) => b.type == BillType.credit)
        .toList();
    final groups = _groupBills(creditBills)
      ..sort((a, b) {
        final aLatest = a.bills.map((b) => b.createdAt).reduce(
            (x, y) => x.isAfter(y) ? x : y);
        final bLatest = b.bills.map((b) => b.createdAt).reduce(
            (x, y) => x.isAfter(y) ? x : y);
        return bLatest.compareTo(aLatest);
      });
    final grandTotal = groups.fold<double>(0, (s, g) => s + g.total);

    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          TopBar(
            title: AppStrings.credit,
            urdu: AppStrings.urdCredit,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.dangerSoft,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.dangerSoftBorder),
                  ),
                  child: Text(
                    '${creditBills.length} bills',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.danger,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _showDeleted
                ? _deletedLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _deletedBills.isEmpty
                        ? const Center(
                            child: EmptyState(
                              icon: Icons.delete_sweep_outlined,
                              message: 'No deleted credit bills',
                              subtitle:
                                  'Deleted credit bills will appear here.',
                            ),
                          )
                        : ListView.builder(
                            padding:
                                const EdgeInsets.fromLTRB(13, 7, 13, 16),
                            itemCount: _deletedBills.length,
                            itemBuilder: (_, i) {
                              final entry = _deletedBills[i];
                              return DeletedCreditBillCard(
                                bill: entry.bill,
                                deletedAt: entry.deletedAt,
                                deletedByDevice: entry.deletedByDevice,
                                expanded: _expandedDeletedId == entry.bill.id,
                                onToggle: () => setState(() {
                                  _expandedDeletedId =
                                      _expandedDeletedId == entry.bill.id
                                          ? null
                                          : entry.bill.id;
                                }),
                                productLookup: inventory.productById,
                              );
                            },
                          )
                : inventory.creditBillsLoading
                    ? const Center(child: CircularProgressIndicator())
                    : groups.isEmpty
                        ? const Center(
                            child: EmptyState(
                              message: 'No credit transactions',
                              icon: Icons.credit_card_off_outlined,
                            ),
                          )
                        : ListView(
                            padding:
                                const EdgeInsets.fromLTRB(13, 12, 13, 16),
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              if (grandTotal > 0)
                                _OutstandingHero(total: grandTotal),
                              const SizedBox(height: 12),
                              for (final group in groups)
                                CreditGroupCard(
                                  group: group,
                                  expanded: _expanded == group.name,
                                  onToggle: () => setState(() {
                                    _expanded = _expanded == group.name
                                        ? null
                                        : group.name;
                                  }),
                                  productLookup: inventory.productById,
                                  onMarkPaid: (bill) =>
                                      _markPaid(context, bill),
                                  onReprint: (bill) => CustomSnackbar.info(
                                      context, 'Reprint queued'),
                                  onDelete: (bill) =>
                                      _deleteBill(context, bill),
                                ),
                            ],
                          ),
          ),
        ],
      ),
    );
  }
}

class _OutstandingHero extends StatelessWidget {
  final double total;
  const _OutstandingHero({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OUTSTANDING',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  AppStrings.urdOutstanding,
                  style: AppTextStyles.urdu(
                    size: 11,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),
              ],
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

class _MutableGroup {
  final String name;
  final List<Bill> bills = [];
  double total = 0;
  _MutableGroup(this.name);
}
