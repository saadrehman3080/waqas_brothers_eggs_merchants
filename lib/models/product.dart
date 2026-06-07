/// Domain model for an egg product (Patty, Tray, Dozen, Single Egg).
class Product {
  final String id;
  final String nameEn;
  final String nameUr;
  final int price;
  final double revenuePerProductType;

  const Product({
    required this.id,
    required this.nameEn,
    required this.nameUr,
    required this.price,
    this.revenuePerProductType = 0,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] as String,
    nameEn: json['nameEn'] as String,
    nameUr: json['nameUr'] as String? ?? '',
    price: (json['price'] as num).toInt(),
    revenuePerProductType:
        (json['revenuePerProductType'] as num?)?.toDouble() ?? 0,
  );
}
