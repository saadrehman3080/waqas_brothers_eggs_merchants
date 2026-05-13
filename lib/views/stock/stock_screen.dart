import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/color_schemes.dart';
import '../../core/utils/custom_snackbar.dart';
import '../../viewmodels/inventory_viewmodel.dart';
import '../../viewmodels/stock_viewmodel.dart';
import '../widgets/app_button.dart';
import '../widgets/empty_state.dart';
import '../widgets/top_bar.dart';
import 'widgets/add_stock_form.dart';
import 'widgets/product_form.dart';
import 'widgets/product_stock_card.dart';

class StockScreen extends StatelessWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<StockViewModel>(
      create: (ctx) => StockViewModel(ctx.read<InventoryViewModel>()),
      child: const _StockView(),
    );
  }
}

class _StockView extends StatelessWidget {
  const _StockView();

  Future<void> _submitProduct(BuildContext context) async {
    final stock = context.read<StockViewModel>();
    final ok = await stock.submitProduct();
    if (!context.mounted) return;
    if (ok) {
      CustomSnackbar.success(context, 'Product updated');
    } else {
      CustomSnackbar.error(context, 'Please enter a valid price');
    }
  }

  Future<void> _submitAddStock(BuildContext context) async {
    final stock = context.read<StockViewModel>();
    final ok = await stock.submitAddStock();
    if (!context.mounted) return;
    if (ok) {
      CustomSnackbar.success(context, 'Stock added');
    } else {
      CustomSnackbar.error(
        context,
        'Enter a quantity for at least one product',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryViewModel>();
    final stock = context.watch<StockViewModel>();
    final products = inventory.products;

    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          TopBar(
            title: 'Stock & Products',
            urdu: AppStrings.urdStock,
            trailing: stock.view == StockView.list
                ? AppButton(
                    label: '+Stock',
                    small: true,
                    variant: AppButtonVariant.soft,
                    onPressed: stock.showAddStock,
                  )
                : null,
          ),
          Expanded(
            child: switch (stock.view) {
              StockView.list => () {
                if (products.isEmpty) {
                  return const EmptyState(
                    message: 'No products yet',
                    icon: Icons.inventory_2_outlined,
                  );
                }
                final pool = inventory.eggPool;
                final showBanner =
                    pool.stockAddedAt.isNotEmpty ||
                    pool.lastStockDevice.isNotEmpty;
                final now = DateTime.now();
                final lastUpdate = pool.stockAddedAtMs > 0
                    ? DateTime.fromMillisecondsSinceEpoch(pool.stockAddedAtMs)
                    : null;
                final isToday = lastUpdate != null &&
                    lastUpdate.year == now.year &&
                    lastUpdate.month == now.month &&
                    lastUpdate.day == now.day;
                // 360 eggs per patty
                final pattiesAddedToday =
                    isToday ? pool.stockAddedToday ~/ 360 : 0;
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(13, 11, 13, 16),
                  itemCount: products.length + (showBanner ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (showBanner && i == 0) {
                      return _LastUpdatedBanner(
                        updatedAt: pool.stockAddedAt,
                        device: pool.lastStockDevice,
                        pattiesAddedToday: pattiesAddedToday,
                      );
                    }
                    final p = products[showBanner ? i - 1 : i];
                    return ProductStockCard(
                      product: p,
                      eggPool: pool,
                      onEdit: () => stock.showEditProduct(p),
                    );
                  },
                );
              }(),
              StockView.addStock => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(13, 11, 13, 16),
                child: AddStockForm(
                  onCancel: stock.showList,
                  onSubmit: () => _submitAddStock(context),
                ),
              ),
              StockView.editProduct => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(13, 11, 13, 16),
                child: ProductForm(
                  onCancel: stock.showList,
                  onSubmit: () => _submitProduct(context),
                ),
              ),
            },
          ),
        ],
      ),
    );
  }
}

// ── Last-updated banner ────────────────────────────────────────────────────

class _LastUpdatedBanner extends StatelessWidget {
  final String updatedAt;
  final String device;
  final int pattiesAddedToday;

  const _LastUpdatedBanner({
    required this.updatedAt,
    required this.device,
    required this.pattiesAddedToday,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.09),
            AppColors.primary.withValues(alpha: 0.03),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          // ── Icon circle ──
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.13),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cloud_done_rounded,
              size: 19,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),

          // ── Text info ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'LAST STOCK UPDATE',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                if (updatedAt.isNotEmpty)
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 11,
                        color: AppColors.ink400,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        updatedAt,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink900,
                        ),
                      ),
                    ],
                  ),
                if (device.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone_android_rounded,
                        size: 11,
                        color: AppColors.ink400,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          device,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.ink600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // ── Patties count ──
          if (pattiesAddedToday > 0) ...[
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '+$pattiesAddedToday',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    height: 1,
                  ),
                ),
                const Text(
                  'patties today',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink400,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
