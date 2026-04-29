/// Domain model representing an egg product (single, dozen, tray, patty).
class Product {
  final int id;
  final String nameEn;
  final String nameUr;
  final double price;
  final int stock;
  final int sold;

  /// Revenue (margin) per unit sold. Used to compute the dashboard
  /// "Revenue Today" total — this is set per-product in the form.
  final double revenuePerUnit;

  const Product({
    required this.id,
    required this.nameEn,
    required this.nameUr,
    required this.price,
    required this.stock,
    required this.sold,
    this.revenuePerUnit = 0,
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
    id: json['id'] as int,
    nameEn: json['nameEn'] as String,
    nameUr: json['nameUr'] as String? ?? '',
    price: (json['price'] as num).toDouble(),
    stock: json['stock'] as int? ?? 0,
    sold: json['sold'] as int? ?? 0,
    revenuePerUnit: (json['revenuePerUnit'] as num?)?.toDouble() ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nameEn': nameEn,
    'nameUr': nameUr,
    'price': price,
    'stock': stock,
    'sold': sold,
    'revenuePerUnit': revenuePerUnit,
  };

  Product copyWith({
    String? nameEn,
    String? nameUr,
    double? price,
    int? stock,
    int? sold,
    double? revenuePerUnit,
  }) => Product(
    id: id,
    nameEn: nameEn ?? this.nameEn,
    nameUr: nameUr ?? this.nameUr,
    price: price ?? this.price,
    stock: stock ?? this.stock,
    sold: sold ?? this.sold,
    revenuePerUnit: revenuePerUnit ?? this.revenuePerUnit,
  );
}
