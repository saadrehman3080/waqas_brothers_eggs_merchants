import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/color_schemes.dart';
import '../../core/utils/custom_snackbar.dart';
import '../../core/utils/egg_units.dart';
import '../../viewmodels/inventory_viewmodel.dart';
import '../../viewmodels/order_viewmodel.dart';
import '../widgets/empty_state.dart';
import 'widgets/checkout_bottom_sheet.dart';
import 'widgets/order_header.dart';
import 'widgets/product_order_card.dart';
import 'widgets/quantity_dialog.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<OrderViewModel>(
      create: (ctx) => OrderViewModel(ctx.read<InventoryViewModel>()),
      child: const _OrderView(),
    );
  }
}

class _OrderView extends StatelessWidget {
  const _OrderView();

  Future<void> _openCheckout(BuildContext context) async {
    final result = await CheckoutBottomSheet.show(context);
    if (result == true && context.mounted) {
      CustomSnackbar.success(context, 'Bill saved');
    }
  }

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryViewModel>();
    final order = context.watch<OrderViewModel>();

    final products = inventory.products;
    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          OrderHeader(
            subtotal: order.subtotal,
            hasItems: order.hasItems,
            onReset: order.resetCart,
            onCheckout: () => _openCheckout(context),
          ),
          Expanded(
            child: products.isEmpty
                ? const EmptyState(
                    message: 'No products yet',
                    icon: Icons.inventory_2_outlined,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 10,
                    ),
                    itemCount: products.length,
                    itemBuilder: (_, i) {
                      final p = products[i];
                      final q = order.qtyOf(p.id);
                      return ProductOrderCard(
                        product: p,
                        qty: q,
                        poolStock: inventory.eggPool.stock,
                        effectivePoolRemaining: order.effectivePoolRemaining,
                        onIncrement: () => order.increment(p.id),
                        onDecrement: () => order.decrement(p.id),
                        onTapPriceOrName: () async {
                          final epu = EggUnits.eggsPerUnitForProduct(p);
                          final effRemaining = epu > 0
                              ? order.effectivePoolRemaining ~/ epu + q
                              : 0;
                          final result = await QuantityDialog.show(
                            context,
                            product: p,
                            effectiveRemaining: effRemaining,
                            currentQty: q,
                          );
                          if (result != null) order.setQty(p.id, result);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
