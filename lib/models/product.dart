/// Domain model representing an egg product (single, dozen, tray, patty).
class Product {
  final String id;
  final String nameEn;
  final String nameUr;
  final double price;
  final int stock;
  final int sold;

  /// Revenue (margin) per unit sold. Used to compute the dashboard
  /// "Revenue Today" total — this is set per-product in the form.
  final double revenuePerUnit;

  /// Units added to stock today (resets each day on the backend).
  final int stockAddedToday;

  /// Device ID of the device that last added stock for this product.
  final String lastStockDevice;

  /// Formatted "d MMM  HH:mm" string of the last Firestore updatedAt timestamp.
  final String updatedAt;

  /// Raw epoch milliseconds of updatedAt — used for sorting only, not persisted.
  final int updatedAtMs;

  const Product({
    required this.id,
    required this.nameEn,
    required this.nameUr,
    required this.price,
    required this.stock,
    required this.sold,
    this.revenuePerUnit = 0,
    this.stockAddedToday = 0,
    this.lastStockDevice = '',
    this.updatedAt = '',
    this.updatedAtMs = 0,
  });

  /// Stock currently available for sale at the shop.
  int get remaining => stock - sold;

  /// Stock level as a percentage (0–100).
  double get stockPercent {
    if (stock == 0) return 0;
    return (remaining / stock) * 100;
  }

  bool get isLowStock => stockPercent < 20;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] as String,
    nameEn: json['nameEn'] as String,
    nameUr: json['nameUr'] as String? ?? '',
    price: (json['price'] as num).toDouble(),
    stock: json['stock'] as int? ?? 0,
    sold: json['sold'] as int? ?? 0,
    revenuePerUnit: (json['revenuePerUnit'] as num?)?.toDouble() ?? 0,
    stockAddedToday: json['stockAddedToday'] as int? ?? 0,
    lastStockDevice: json['lastStockDevice'] as String? ?? '',
    updatedAt: json['updatedAt'] as String? ?? '',
    updatedAtMs: json['updatedAtMs'] as int? ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nameEn': nameEn,
    'nameUr': nameUr,
    'price': price,
    'stock': stock,
    'sold': sold,
    'revenuePerUnit': revenuePerUnit,
    'stockAddedToday': stockAddedToday,
    'lastStockDevice': lastStockDevice,
    'updatedAt': updatedAt,
  };

  Product copyWith({
    String? nameEn,
    String? nameUr,
    double? price,
    int? stock,
    int? sold,
    double? revenuePerUnit,
    int? stockAddedToday,
    String? lastStockDevice,
    String? updatedAt,
  }) => Product(
    id: id,
    nameEn: nameEn ?? this.nameEn,
    nameUr: nameUr ?? this.nameUr,
    price: price ?? this.price,
    stock: stock ?? this.stock,
    sold: sold ?? this.sold,
    revenuePerUnit: revenuePerUnit ?? this.revenuePerUnit,
    stockAddedToday: stockAddedToday ?? this.stockAddedToday,
    lastStockDevice: lastStockDevice ?? this.lastStockDevice,
    updatedAt: updatedAt ?? this.updatedAt,
    updatedAtMs: updatedAtMs,
  );
}
