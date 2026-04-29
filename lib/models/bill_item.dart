/// A single line item on a [Bill].
class BillItem {
  final int productId;
  final int qty;
  final double price;

  const BillItem({
    required this.productId,
    required this.qty,
    required this.price,
  });

  double get lineTotal => qty * price;

  factory BillItem.fromJson(Map<String, dynamic> json) => BillItem(
        productId: json['productId'] as int,
        qty: json['qty'] as int,
        price: (json['price'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'qty': qty,
        'price': price,
      };
}
