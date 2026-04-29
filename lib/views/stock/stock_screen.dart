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

  Future<void> _submitAddStock(BuildContext context) async {
    final stock = context.read<StockViewModel>();
    final ok = await stock.submitAddStock();
    if (!context.mounted) return;
    if (ok) {
      CustomSnackbar.success(context, 'Stock added');
    } else {
      CustomSnackbar.error(context, 'Please select a product and quantity');
    }
  }

  Future<void> _submitProduct(BuildContext context) async {
    final stock = context.read<StockViewModel>();
    final isEditing = stock.isEditing;
    final ok = await stock.submitProduct();
    if (!context.mounted) return;
    if (ok) {
      CustomSnackbar.success(context, isEditing ? 'Product updated' : 'Product added');
    } else {
      CustomSnackbar.error(context, 'Please enter name and price');
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
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppButton(
                        label: '+Stock',
                        small: true,
                        variant: AppButtonVariant.soft,
                        onPressed: stock.showAddStock,
                      ),
                      const SizedBox(width: 5),
                      AppButton(
                        label: '+Item',
                        small: true,
                        onPressed: stock.showNewProduct,
                      ),
                    ],
                  )
                : null,
          ),
          Expanded(
            child: switch (stock.view) {
              StockView.list => products.isEmpty
                  ? const EmptyState(
                      message: 'No products yet',
                      icon: Icons.inventory_2_outlined,
                    )
                  : RefreshIndicator(
                      onRefresh: inventory.refresh,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(13, 11, 13, 16),
                        itemCount: products.length,
                        itemBuilder: (_, i) {
                          final p = products[i];
                          return ProductStockCard(
                            product: p,
                            entries: stock.entriesFor(p.id),
                            onEdit: () => stock.showEditProduct(p),
                          );
                        },
                      ),
                    ),
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
