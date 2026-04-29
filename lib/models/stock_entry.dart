/// A single append-only stock receipt at the shop.
///
/// Stock entries can never be deleted or edited once recorded — this
/// is enforced both by the UI (no delete button) and by the
/// [DataService] (no remove API).
class StockEntry {
  final int id;
  final int productId;
  final int qty;
  final String date;
  final String time;
  final String device;

  const StockEntry({
    required this.id,
    required this.productId,
    required this.qty,
    required this.date,
    required this.time,
    required this.device,
  });

  factory StockEntry.fromJson(Map<String, dynamic> json) => StockEntry(
        id: json['id'] as int,
        productId: json['productId'] as int,
        qty: json['qty'] as int,
        date: json['date'] as String,
        time: json['time'] as String,
        device: json['device'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'productId': productId,
        'qty': qty,
        'date': date,
        'time': time,
        'device': device,
      };
}
