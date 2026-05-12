import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/bill.dart';
import '../models/bill_item.dart';
import '../models/product.dart';

/// Firestore-backed data service. Every read and write goes directly to
/// Cloud Firestore.
class DataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _products =>
      _db.collection('products');

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
    cart.forEach((pid, qty) {
      if (qty <= 0) return;
      final product = productMap[pid];
      if (product == null) throw StateError('Product $pid not found');
      items.add(BillItem(productId: pid, qty: qty, price: product.price));
      subtotal += product.price * qty;
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
    for (final item in items) {
      batch.update(_products.doc(item.productId), {
        'sold': FieldValue.increment(item.qty),
      });
    }
    await batch.commit();
    return bill;
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
        .map((snap) =>
            snap.docs.map((d) => CashBill.fromMap(d.data())).toList());
  }

  Stream<List<CreditBill>> watchCreditBillsForDate(String date) {
    return _db
        .collection('credit_sale')
        .doc(date)
        .collection('records')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => CreditBill.fromMap(d.data())).toList());
  }

  Future<Bill> changeBillType(Bill bill, BillType newType) async {
    if (bill.type == newType) return bill;
    final updated = switch (newType) {
      BillType.cash => CashBill(
        id: bill.id,
        items: bill.items,
        subtotal: bill.subtotal,
        discount: bill.discount,
        total: bill.total,
        customer: bill.customer,
        device: bill.device,
        createdAt: bill.createdAt,
      ),
      BillType.credit => CreditBill(
        id: bill.id,
        items: bill.items,
        subtotal: bill.subtotal,
        discount: bill.discount,
        total: bill.total,
        customer: bill.customer,
        device: bill.device,
        createdAt: bill.createdAt,
      ),
    };
    final batch = _db.batch();
    batch.delete(_db.doc(bill.firestorePath));
    batch.set(_db.doc(updated.firestorePath), updated.toJson());
    await batch.commit();
    return updated;
  }

  // ── Stock ──────────────────────────────────────────────────
  Future<void> addStockEntry({
    required String productId,
    required int qty,
    required String device,
  }) async {
    await _products.doc(productId).update({
      'stock': FieldValue.increment(qty),
      'stockAddedToday': FieldValue.increment(qty),
      'lastStockDevice': device,
      'stockAddedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Helpers ────────────────────────────────────────────────
  Product _productFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = Map<String, dynamic>.from(doc.data()!);
    data['id'] = doc.id;

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final ts = data['stockAddedAt'];
    if (ts is Timestamp) {
      final dt = ts.toDate().toLocal();
      final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final mn = dt.minute.toString().padLeft(2, '0');
      final ampm = dt.hour < 12 ? 'AM' : 'PM';
      data['stockAddedAt'] = '${dt.day} ${months[dt.month - 1]}  $h:$mn $ampm';
      data['stockAddedAtMs'] = dt.millisecondsSinceEpoch;
    } else {
      data['stockAddedAt'] = '';
      data['stockAddedAtMs'] = 0;
    }
    try {
      return Product.fromJson(data);
    } catch (e) {
      debugPrint('_productFromDoc error on ${doc.id}: $e');
      rethrow;
    }
  }
}
