import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/color_schemes.dart';
import '../../viewmodels/inventory_viewmodel.dart';
import 'widgets/collection_hero.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/monthly_summary_card.dart';
import 'widgets/stock_overview_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryViewModel>();

    return Container(
      color: AppColors.background,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 20),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const DashboardHeader(),
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
                StockOverviewCard(
                  products: inventory.products,
                  eggPool: inventory.eggPool,
                ),
                const SizedBox(height: 12),
                MonthlySummaryCard(summary: inventory.monthlySummary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
