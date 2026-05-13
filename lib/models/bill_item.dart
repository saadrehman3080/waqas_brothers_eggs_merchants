/// A single line item on a [Bill].
class BillItem {
  final String productId;
  final int qty;
  final double price;

  /// Eggs consumed per unit of this product — copied from [Product.eggsPerUnit]
  /// at bill-creation time so old bills remain self-contained.
  final int eggsPerUnit;

  const BillItem({
    required this.productId,
    required this.qty,
    required this.price,
    this.eggsPerUnit = 0,
  });

  double get lineTotal => qty * price;

  /// Total eggs consumed by this line item.
  int get totalEggs => qty * eggsPerUnit;

  factory BillItem.fromJson(Map<String, dynamic> json) => BillItem(
        productId: json['productId'] as String,
        qty: json['qty'] as int,
        price: (json['price'] as num).toDouble(),
        eggsPerUnit: json['eggsPerUnit'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'qty': qty,
        'price': price,
        'eggsPerUnit': eggsPerUnit,
      };
}
