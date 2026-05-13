import 'package:cloud_firestore/cloud_firestore.dart';

import 'bill_item.dart';

enum BillType { cash, credit }

abstract class Bill {
  /// Invoice number — millisecondsSinceEpoch as String
  final String id;

  /// Products in this bill
  final List<BillItem> items;

  /// Total before discount
  final double subtotal;

  /// Discount amount
  final double discount;

  /// Final payable amount (subtotal − discount)
  final double total;

  /// Customer name (empty string = walk-in)
  final String customer;

  /// Device that generated the bill
  final String device;

  /// Bill creation timestamp
  final DateTime createdAt;

  const Bill({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.customer,
    required this.device,
    required this.createdAt,
  });

  BillType get type;

  /// Total eggs consumed across all items in this bill.
  int get totalEggs => items.fold(0, (acc, item) => acc + item.totalEggs);

  /// Firestore root collection for cash bills (credit overrides firestorePath directly)
  String get rootCollection => 'daily_sale';

  /// 'Walk-in' fallback when no customer name was entered
  String get displayCustomer =>
      customer.trim().isEmpty ? 'Walk-in' : customer;

  /// yyyy-MM-dd derived from [createdAt]
  String get date {
    final dt = createdAt.toLocal();
    return '${dt.year}'
        '-${dt.month.toString().padLeft(2, '0')}'
        '-${dt.day.toString().padLeft(2, '0')}';
  }

  /// HH:mm derived from [createdAt]
  String get time {
    final dt = createdAt.toLocal();
    return '${dt.hour.toString().padLeft(2, '0')}'
        ':${dt.minute.toString().padLeft(2, '0')}';
  }

  /// Firestore document path. Cash: daily_sale/{date}/records/{id}
  /// Credit overrides this — see CreditBill.firestorePath.
  String get firestorePath => '$rootCollection/$date/records/$id';

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'customer': customer,
        'device': device,
        'subtotal': subtotal,
        'discount': discount,
        'total': total,
        'createdAt': Timestamp.fromDate(createdAt),
        'items': items.map((e) => e.toJson()).toList(),
      };
}

// ── Helpers ────────────────────────────────────────────────────────────────

Bill _fromMap(Map<String, dynamic> json, BillType type) {
  final createdAtRaw = json['createdAt'];
  final createdAt = createdAtRaw is Timestamp
      ? createdAtRaw.toDate()
      : DateTime.fromMillisecondsSinceEpoch(
          int.tryParse(json['id'].toString()) ?? 0,
        );
  final id = json['id'].toString();
  final items = (json['items'] as List<dynamic>)
      .map((e) => BillItem.fromJson(e as Map<String, dynamic>))
      .toList();
  final subtotal = (json['subtotal'] as num?)?.toDouble() ??
      (json['total'] as num).toDouble();
  final discount = (json['discount'] as num?)?.toDouble() ?? 0;
  final total = (json['total'] as num).toDouble();
  final customer = json['customer'] as String? ?? '';
  final device = json['device'] as String? ?? '';

  return switch (type) {
    BillType.cash => CashBill(
        id: id, items: items, subtotal: subtotal, discount: discount,
        total: total, customer: customer, device: device, createdAt: createdAt),
    BillType.credit => CreditBill(
        id: id, items: items, subtotal: subtotal, discount: discount,
        total: total, customer: customer, device: device, createdAt: createdAt),
  };
}

// ── Cash ───────────────────────────────────────────────────────────────────

class CashBill extends Bill {
  const CashBill({
    required super.id,
    required super.items,
    required super.subtotal,
    required super.discount,
    required super.total,
    required super.customer,
    required super.device,
    required super.createdAt,
  });

  factory CashBill.fromMap(Map<String, dynamic> json) =>
      _fromMap(json, BillType.cash) as CashBill;

  @override
  BillType get type => BillType.cash;
}

// ── Credit ─────────────────────────────────────────────────────────────────

class CreditBill extends Bill {
  final DateTime? movedToCreditAt;
  final String? movedToCreditByDevice;

  const CreditBill({
    required super.id,
    required super.items,
    required super.subtotal,
    required super.discount,
    required super.total,
    required super.customer,
    required super.device,
    required super.createdAt,
    this.movedToCreditAt,
    this.movedToCreditByDevice,
  });

  factory CreditBill.fromMap(Map<String, dynamic> json) {
    final createdAtRaw = json['createdAt'];
    final createdAt = createdAtRaw is Timestamp
        ? createdAtRaw.toDate()
        : DateTime.fromMillisecondsSinceEpoch(
            int.tryParse(json['id'].toString()) ?? 0,
          );
    final items = (json['items'] as List<dynamic>)
        .map((e) => BillItem.fromJson(e as Map<String, dynamic>))
        .toList();
    final subtotal =
        (json['subtotal'] as num?)?.toDouble() ?? (json['total'] as num).toDouble();

    final movedAtRaw = json['movedToCreditAt'];
    final movedToCreditAt = movedAtRaw is Timestamp ? movedAtRaw.toDate() : null;
    final rawDevice = json['movedToCreditByDevice'] as String?;
    final movedToCreditByDevice =
        (rawDevice != null && rawDevice.isNotEmpty) ? rawDevice : null;

    return CreditBill(
      id: json['id'].toString(),
      items: items,
      subtotal: subtotal,
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num).toDouble(),
      customer: json['customer'] as String? ?? '',
      device: json['device'] as String? ?? '',
      createdAt: createdAt,
      movedToCreditAt: movedToCreditAt,
      movedToCreditByDevice: movedToCreditByDevice,
    );
  }

  @override
  BillType get type => BillType.credit;

  /// Flat path — all credit bills live in one top-level collection.
  @override
  String get firestorePath => 'credit_bills/$id';
}
