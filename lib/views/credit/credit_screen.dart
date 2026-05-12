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

class CreditScreen extends StatefulWidget {
  const CreditScreen({super.key});

  @override
  State<CreditScreen> createState() => _CreditScreenState();
}

class _CreditScreenState extends State<CreditScreen> {
  String? _expanded;

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

  Future<void> _markPaid(BuildContext context, String id) async {
    if (!context.mounted) return;

    // Show confirmation dialog
    final confirmed = await _showMarkPaidConfirmationDialog(context);
    if (!confirmed) {
      return; // User cancelled
    }

    final ok = await context.read<InventoryViewModel>().changeBillType(
      id,
      BillType.cash,
    );
    if (!context.mounted) return;
    if (ok) {
      CustomSnackbar.success(context, 'Marked as paid');
    } else {
      CustomSnackbar.error(context, 'Failed to mark paid');
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
    final groups = _groupBills(creditBills);
    final grandTotal = groups.fold<double>(0, (s, g) => s + g.total);

    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          TopBar(
            title: AppStrings.credit,
            urdu: AppStrings.urdCredit,
            trailing: Text(
              '${creditBills.length} bills',
              style: TextStyle(fontSize: 12, color: AppColors.danger),
            ),
          ),
          Expanded(
            child: inventory.creditBillsLoading
                ? const Center(child: CircularProgressIndicator())
                : groups.isEmpty
                ? const Center(
                    child: EmptyState(
                      message: 'No credit transactions',
                      icon: Icons.credit_card_off_outlined,
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(13, 12, 13, 16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      if (grandTotal > 0) _OutstandingHero(total: grandTotal),
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
                          onMarkPaid: (bill) => _markPaid(context, bill.id),
                          onReprint: (bill) =>
                              CustomSnackbar.info(context, 'Reprint queued'),
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
