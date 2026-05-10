import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../core/utils/format_helpers.dart';
import '../models/bill.dart';
import '../models/bill_item.dart';
import '../models/printer_device.dart';
import '../models/product.dart';
/// Firestore-backed data service. All reads and writes go directly to
/// Cloud Firestore — no local state is kept here.
class DataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _products =>
      _db.collection('products');
  CollectionReference<Map<String, dynamic>> get _bills =>
      _db.collection('bills');

  // ── Products ───────────────────────────────────────────────
  Future<List<Product>> getProducts() async {
    final snap = await _products.get();
    return snap.docs.map((d) => _productFromDoc(d)).toList();
  }

  Future<Product> addProduct({
    required String nameEn,
    required String nameUr,
    required double price,
    double revenuePerUnit = 0,
  }) async {
    final ref = _products.doc(); // Firestore auto-generated ID
    final product = Product(
      id: ref.id,
      nameEn: nameEn,
      nameUr: nameUr,
      price: price,
      stock: 0,
      sold: 0,
      revenuePerUnit: revenuePerUnit,
    );
    await ref.set({
      ...product.toJson(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return product;
  }

  Future<Product> updateProduct({
    required String id,
    required String nameEn,
    required String nameUr,
    required double price,
    double revenuePerUnit = 0,
  }) async {
    final ref = _products.doc(id);
    final snap = await ref.get();
    if (!snap.exists) throw StateError('Product $id not found');
    final current = _productFromDoc(snap);
    final updated = current.copyWith(
      nameEn: nameEn,
      nameUr: nameUr,
      price: price,
      revenuePerUnit: revenuePerUnit,
    );
    await ref.update({
      ...updated.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return updated;
  }

  Future<Product> updateProductRevenuePerUnit({
    required String id,
    required double revenuePerUnit,
  }) async {
    final ref = _products.doc(id);
    final snap = await ref.get();
    if (!snap.exists) throw StateError('Product $id not found');
    final updated =
        _productFromDoc(snap).copyWith(revenuePerUnit: revenuePerUnit);
    await ref.update({
      'revenuePerUnit': revenuePerUnit,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return updated;
  }

  // ── Bills ──────────────────────────────────────────────────
  Future<List<Bill>> getBills() async {
    final snap = await _bills.orderBy('id', descending: true).get();
    return snap.docs.map((d) => Bill.fromJson(d.data())).toList();
  }

  Future<Bill> createBill({
    required Map<String, int> cart,
    required double discount,
    required BillType type,
    required String customer,
    required String device,
  }) async {
    final products = await getProducts();
    final productMap = {for (final p in products) p.id: p};

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

    final total = (subtotal - discount).clamp(0, double.infinity).toDouble();
    final id = DateTime.now().millisecondsSinceEpoch;
    final bill = Bill(
      id: id,
      date: FormatHelpers.todayKey(),
      time: FormatHelpers.timeNow(),
      items: items,
      total: total,
      type: type,
      customer: customer,
      device: device,
    );

    final batch = _db.batch();
    batch.set(_bills.doc(id.toString()), {
      ...bill.toJson(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    for (final item in items) {
      batch.update(_products.doc(item.productId), {
        'sold': FieldValue.increment(item.qty),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
    return bill;
  }

  Future<void> deleteBill(int id) async {
    await _bills.doc(id.toString()).delete();
  }

  Future<Bill> changeBillType(int id, BillType type) async {
    final ref = _bills.doc(id.toString());
    final snap = await ref.get();
    if (!snap.exists) throw StateError('Bill $id not found');
    final updated = Bill.fromJson(snap.data()!).copyWith(type: type);
    await ref.update({
      'type': type.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
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
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Printers ───────────────────────────────────────────────
  Future<List<PrinterDevice>> getPairedPrinters() async => const [];

  // ── Helpers ────────────────────────────────────────────────
  Product _productFromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = Map<String, dynamic>.from(doc.data()!);
    if (!data.containsKey('id')) data['id'] = doc.id;
    final ts = data['updatedAt'];
    if (ts is Timestamp) {
      final dt = ts.toDate().toLocal();
      const months = [
        'Jan','Feb','Mar','Apr','May','Jun',
        'Jul','Aug','Sep','Oct','Nov','Dec',
      ];
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final m = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour < 12 ? 'AM' : 'PM';
      data['updatedAt'] = '${dt.day} ${months[dt.month - 1]}  $hour:$m $period';
      data['updatedAtMs'] = dt.millisecondsSinceEpoch;
    } else {
      data['updatedAt'] = '';
      data['updatedAtMs'] = 0;
    }
    try {
      return Product.fromJson(data);
    } catch (e) {
      debugPrint('_productFromDoc error on ${doc.id}: $e');
      rethrow;
    }
  }
}
