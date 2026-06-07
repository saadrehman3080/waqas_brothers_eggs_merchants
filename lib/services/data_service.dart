import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../core/utils/egg_units.dart';
import '../models/bill.dart';
import '../models/bill_item.dart';
import '../models/egg_pool.dart';
import '../models/product.dart';

/// Firestore-backed data service. Every read and write goes directly to
/// Cloud Firestore.
class DataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _products =>
      _db.collection('products');

  DocumentReference<Map<String, dynamic>> get _poolRef =>
      _db.collection('inventory').doc('egg_pool');

  // ── Products ───────────────────────────────────────────────
  Stream<List<Product>> watchProducts() {
    return _products.snapshots().map(
      (snap) => snap.docs.map(_productFromDoc).toList(),
    );
  }

  Future<void> updateProduct({
    required String id,
    required String nameEn,
    required String nameUr,
    required double price,
    double revenuePerUnit = 0,
  }) async {
    await _products.doc(id).update({
      'nameEn': nameEn,
      'nameUr': nameUr,
      'price': price,
      'revenuePerUnit': revenuePerUnit,
    });
  }

  // ── Egg pool ───────────────────────────────────────────────
  Stream<EggPool> watchEggPool() {
    return _poolRef.snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return EggPool.empty;
      return _poolFromDoc(snap.data()!);
    });
  }

  Future<void> addStockEntry({
    required int patties,
    int trays = 0,
    required String device,
  }) async {
    final addedEggs = patties * 360 + trays * 30;
    final data = {
      'stock': FieldValue.increment(addedEggs),
      'pattiesAddedToday': FieldValue.increment(patties),
      'lastStockDevice': device,
      'stockAddedAt': FieldValue.serverTimestamp(),
    };
    if (trays > 0) {
      data['traysAddedToday'] = FieldValue.increment(trays);
    }
    await _poolRef.set(data, SetOptions(merge: true));
  }

  // ── Bills ──────────────────────────────────────────────────
  Future<Bill> createBill({
    required Map<String, int> cart,
    required double discount,
    required BillType type,
    required String customer,
    required String device,
  }) async {
    final productsSnap = await _products.get();
    final productMap = {
      for (final d in productsSnap.docs) d.id: _productFromDoc(d),
    };

    final items = <BillItem>[];
    double subtotal = 0;
    int totalEggs = 0;

    cart.forEach((pid, qty) {
      if (qty <= 0) return;
      final product = productMap[pid];
      if (product == null) throw StateError('Product $pid not found');
      final epu = EggUnits.eggsPerUnitForProduct(product);
      items.add(
        BillItem(
          productId: pid,
          qty: qty,
          price: product.price,
          eggsPerUnit: epu,
        ),
      );
      subtotal += product.price * qty;
      totalEggs += qty * epu;
    });
    if (items.isEmpty) throw StateError('Cannot create an empty bill');

    final now = DateTime.now();
    final total = (subtotal - discount).clamp(0, double.infinity).toDouble();
    final bill = switch (type) {
      BillType.cash => CashBill(
        id: now.millisecondsSinceEpoch.toString(),
        items: items,
        subtotal: subtotal,
        discount: discount,
        total: total,
        customer: customer,
        device: device,
        createdAt: now,
      ),
      BillType.credit => CreditBill(
        id: now.millisecondsSinceEpoch.toString(),
        items: items,
        subtotal: subtotal,
        discount: discount,
        total: total,
        customer: customer,
        device: device,
        createdAt: now,
      ),
    };

    final batch = _db.batch();
    batch.set(_db.doc(bill.firestorePath), bill.toJson());
    if (totalEggs > 0) {
      batch.update(_poolRef, {'sold': FieldValue.increment(totalEggs)});
    }
    await batch.commit();
    return bill;
  }

  Future<List<({CashBill bill, DateTime deletedAt})>>
  fetchDeletedCashBillsForDate(String date) async {
    final snap = await _db
        .collection('deleted_bills')
        .doc('cash_records')
        .collection(date)
        .get();
    return snap.docs.map((d) {
      final data = d.data();
      final bill = CashBill.fromMap(data);
      final ts = data['deletedAt'];
      final deletedAt = ts is Timestamp ? ts.toDate() : DateTime.now();
      return (bill: bill, deletedAt: deletedAt);
    }).toList();
  }

  Future<List<CashBill>> fetchCashBillsForDate(String date) async {
    final snap = await _db
        .collection('daily_sale')
        .doc(date)
        .collection('records')
        .get();
    return snap.docs.map((d) => CashBill.fromMap(d.data())).toList();
  }

  Stream<List<CashBill>> watchCashBillsForDate(String date) {
    return _db
        .collection('daily_sale')
        .doc(date)
        .collection('records')
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => CashBill.fromMap(d.data())).toList(),
        );
  }

  Stream<List<CreditBill>> watchCreditBills() {
    return _db
        .collection('credit_bills')
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => CreditBill.fromMap(d.data())).toList(),
        );
  }

  Future<void> deleteCashBill(CashBill bill) async {
    final archive = _db
        .collection('deleted_bills')
        .doc('cash_records')
        .collection(bill.date)
        .doc(bill.id);
    final batch = _db.batch();
    batch.set(archive, {
      ...bill.toJson(),
      'deletedAt': FieldValue.serverTimestamp(),
    });
    batch.delete(_db.doc(bill.firestorePath));
    if (bill.totalEggs > 0) {
      batch.update(_poolRef, {'sold': FieldValue.increment(-bill.totalEggs)});
    }
    await batch.commit();
  }

  Future<void> deleteCreditBill(
    CreditBill bill, {
    String? deletedByDevice,
  }) async {
    final archive = _db.collection('deleted_credit_bills').doc(bill.id);
    final batch = _db.batch();
    batch.set(archive, {
      ...bill.toJson(),
      'deletedAt': FieldValue.serverTimestamp(),
      'deletedByDevice': deletedByDevice ?? '',
    });
    batch.delete(_db.doc(bill.firestorePath));
    if (bill.totalEggs > 0) {
      batch.update(_poolRef, {'sold': FieldValue.increment(-bill.totalEggs)});
    }
    await batch.commit();
  }

  Future<Bill> changeBillType(
    Bill bill,
    BillType newType, {
    String? overrideCustomer,
    String? movingDevice,
  }) async {
    if (bill.type == newType) return bill;
    final customer = (overrideCustomer?.trim().isNotEmpty == true)
        ? overrideCustomer!
        : bill.customer;
    final updated = switch (newType) {
      BillType.cash => CashBill(
        id: bill.id,
        items: bill.items,
        subtotal: bill.subtotal,
        discount: bill.discount,
        total: bill.total,
        customer: customer,
        device: bill.device,
        createdAt: bill.createdAt,
      ),
      BillType.credit => CreditBill(
        id: bill.id,
        items: bill.items,
        subtotal: bill.subtotal,
        discount: bill.discount,
        total: bill.total,
        customer: customer,
        device: bill.device,
        createdAt: bill.createdAt,
      ),
    };
    final data = updated.toJson();
    if (newType == BillType.credit) {
      data['movedToCreditAt'] = FieldValue.serverTimestamp();
      data['movedToCreditByDevice'] = movingDevice ?? '';
    }
    final batch = _db.batch();
    batch.delete(_db.doc(bill.firestorePath));
    batch.set(_db.doc(updated.firestorePath), data);
    await batch.commit();
    return updated;
  }

  Future<List<({CreditBill bill, DateTime deletedAt, String deletedByDevice})>>
  fetchDeletedCreditBills() async {
    final snap = await _db
        .collection('deleted_credit_bills')
        .orderBy('deletedAt', descending: true)
        .limit(14)
        .get();
    return snap.docs.map((d) {
      final data = d.data();
      final bill = CreditBill.fromMap(data);
      final ts = data['deletedAt'];
      final deletedAt = ts is Timestamp ? ts.toDate() : DateTime.now();
      final deletedByDevice = data['deletedByDevice'] as String? ?? '';
      return (
        bill: bill,
        deletedAt: deletedAt,
        deletedByDevice: deletedByDevice,
      );
    }).toList();
  }

  // ── Helpers ────────────────────────────────────────────────
  Product _productFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = Map<String, dynamic>.from(doc.data()!);
    data['id'] = doc.id;
    try {
      return Product.fromJson(data);
    } catch (e) {
      debugPrint('_productFromDoc error on ${doc.id}: $e');
      rethrow;
    }
  }

  EggPool _poolFromDoc(Map<String, dynamic> data) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final ts = data['stockAddedAt'];
    String formattedAt = '';

    if (ts is Timestamp) {
      final dt = ts.toDate().toLocal();
      final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final mn = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour < 12 ? 'AM' : 'PM';
      formattedAt = '${dt.day} ${months[dt.month - 1]}  $h:$mn $ampm';
    }
    return EggPool.fromMap(data, formattedAt: formattedAt);
  }
}
