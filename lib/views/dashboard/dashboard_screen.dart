import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/color_schemes.dart';
import '../../core/utils/custom_snackbar.dart';
import '../../viewmodels/inventory_viewmodel.dart';
import 'widgets/collection_hero.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/monthly_summary_card.dart';
import 'widgets/printer_card.dart';
import 'widgets/stock_overview_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryViewModel>();

    return Container(
      color: AppColors.background,
      child: RefreshIndicator(
        onRefresh: inventory.refresh,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 20),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            DashboardHeader(
              printerOn: inventory.printerOn,
              onTogglePrinter: inventory.togglePrinter,
              onExit: () => CustomSnackbar.info(context, 'Exit pressed'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CollectionHero(
                    cash: inventory.todayCash,
                    credit: inventory.todayCredit,
                    customers: inventory.todayCustomerCount,
                    dozens: inventory.productQtyTodayByName('Egg Dozen'),
                    trays: inventory.productQtyTodayByName('Egg Tray'),
                    patties: inventory.productQtyTodayByName('Patty'),
                    eggs: inventory.productQtyTodayByName('Single Egg'),
                  ),
                  const SizedBox(height: 12),
                  StockOverviewCard(products: inventory.products),
                  const SizedBox(height: 12),
                  MonthlySummaryCard(summary: inventory.monthlySummary),
                  const SizedBox(height: 12),
                  PrinterCard(
                    printers: inventory.printers,
                    onConnect: inventory.togglePrinterAt,
                    onPrintRates: () =>
                        CustomSnackbar.success(context, "Today's rates queued"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
