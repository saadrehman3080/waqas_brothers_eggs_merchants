/// Domain model for an egg product (Patty, Tray, Dozen, Single Egg).
///
/// Stock and sold counts are no longer stored here — they live in [EggPool].
/// [eggsPerUnit] converts pool eggs into this product's display unit.
class Product {
  final String id;
  final String nameEn;
  final String nameUr;
  final double price;

  /// How many eggs make up one unit of this product.
  /// Patty=360, Egg Tray=30, Egg Dozen=12, Single Egg=1.
  /// 0 means this product is not part of the egg pool.
  final int eggsPerUnit;

  /// Revenue (margin) per unit sold — used by the dashboard.
  final double revenuePerUnit;

  const Product({
    required this.id,
    required this.nameEn,
    required this.nameUr,
    required this.price,
    required this.eggsPerUnit,
    this.revenuePerUnit = 0,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String,
        nameEn: json['nameEn'] as String,
        nameUr: json['nameUr'] as String? ?? '',
        price: (json['price'] as num).toDouble(),
        eggsPerUnit: json['eggsPerUnit'] as int? ?? 0,
        revenuePerUnit: (json['revenuePerUnit'] as num?)?.toDouble() ?? 0,
      );
}
