import 'package:waqas_brothers_eggs_merchants/models/product.dart';

/// Unified egg inventory pool.
///
/// All egg products (Patty, Tray, Dozen, Single) draw from this single counter.
/// [stock] = current available eggs in inventory.
/// Per-product availability is derived by dividing [stock] by eggsPerUnit.
class EggPool {
  final int stock;
  final int pattiesAddedToday;
  final String lastStockDevice;
  final String stockAddedAt;
  final List<Product> products;

  const EggPool({
    required this.stock,
    this.pattiesAddedToday = 0,
    this.lastStockDevice = '',
    this.stockAddedAt = '',
    this.products = const [],
  });

  static const EggPool empty = EggPool(stock: 0);

  int get remaining => stock.clamp(0, stock);

  /// How many whole units of [eggsPerUnit] fit in [remaining].
  int remainingAs(int eggsPerUnit) =>
      eggsPerUnit > 0 ? remaining ~/ eggsPerUnit : 0;

  /// How many whole units of [eggsPerUnit] fit in total [stock].
  int totalAs(int eggsPerUnit) => eggsPerUnit > 0 ? stock ~/ eggsPerUnit : 0;

  factory EggPool.fromMap(
    Map<String, dynamic> data, {
    String formattedAt = '',
  }) {
    return EggPool(
      stock: data['stock'] as int? ?? 0,
      pattiesAddedToday: data['pattiesAddedToday'] as int? ?? 0,
      lastStockDevice: data['lastStockDevice'] as String? ?? '',
      stockAddedAt: formattedAt,
      products: (data['products'] as List<dynamic>? ?? [])
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
