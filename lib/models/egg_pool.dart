/// Unified egg inventory pool.
///
/// All egg products (Patty, Tray, Dozen, Single) draw from this single counter.
/// [stock] = total eggs ever added. [sold] = total eggs ever sold.
/// Per-product availability is derived by dividing [remaining] by eggsPerUnit.
class EggPool {
  final int stock;
  final int sold;
  final int stockAddedToday;
  final String lastStockDevice;
  final String stockAddedAt;   // formatted "13 May  3:05 PM"
  final int stockAddedAtMs;    // epoch ms — used for today-check in UI

  const EggPool({
    required this.stock,
    required this.sold,
    this.stockAddedToday = 0,
    this.lastStockDevice = '',
    this.stockAddedAt = '',
    this.stockAddedAtMs = 0,
  });

  static const EggPool empty = EggPool(stock: 0, sold: 0);

  int get remaining => (stock - sold).clamp(0, stock);

  /// How many whole units of [eggsPerUnit] fit in [remaining].
  int remainingAs(int eggsPerUnit) =>
      eggsPerUnit > 0 ? remaining ~/ eggsPerUnit : 0;

  /// How many whole units of [eggsPerUnit] fit in total [stock].
  int totalAs(int eggsPerUnit) =>
      eggsPerUnit > 0 ? stock ~/ eggsPerUnit : 0;

  /// How many whole units of [eggsPerUnit] have been sold.
  int soldAs(int eggsPerUnit) =>
      eggsPerUnit > 0 ? sold ~/ eggsPerUnit : 0;

  factory EggPool.fromMap(
    Map<String, dynamic> data, {
    String formattedAt = '',
    int atMs = 0,
  }) {
    return EggPool(
      stock: data['stock'] as int? ?? 0,
      sold: data['sold'] as int? ?? 0,
      stockAddedToday: data['stockAddedToday'] as int? ?? 0,
      lastStockDevice: data['lastStockDevice'] as String? ?? '',
      stockAddedAt: formattedAt,
      stockAddedAtMs: atMs,
    );
  }
}
