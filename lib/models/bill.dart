import 'bill_item.dart';

enum BillType { cash, credit }

/// A finalised sale. Bills are immutable except for [type] (which can flip
/// from credit ↔ cash via the History/Credit screens).
class Bill {
  final int id;
  final String date;
  final String time;
  final List<BillItem> items;
  final double total;
  final BillType type;
  final String customer;
  final String device;

  const Bill({
    required this.id,
    required this.date,
    required this.time,
    required this.items,
    required this.total,
    required this.type,
    required this.customer,
    required this.device,
  });

  String get displayCustomer => customer.isEmpty ? 'Walk-in' : customer;

  factory Bill.fromJson(Map<String, dynamic> json) => Bill(
        id: json['id'] as int,
        date: json['date'] as String,
        time: json['time'] as String,
        items: (json['items'] as List<dynamic>)
            .map((e) => BillItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        total: (json['total'] as num).toDouble(),
        type: BillType.values.firstWhere(
          (t) => t.name == json['type'],
          orElse: () => BillType.cash,
        ),
        customer: json['customer'] as String? ?? '',
        device: json['device'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'time': time,
        'items': items.map((i) => i.toJson()).toList(),
        'total': total,
        'type': type.name,
        'customer': customer,
        'device': device,
      };

  Bill copyWith({BillType? type}) => Bill(
        id: id,
        date: date,
        time: time,
        items: items,
        total: total,
        type: type ?? this.type,
        customer: customer,
        device: device,
      );
}
