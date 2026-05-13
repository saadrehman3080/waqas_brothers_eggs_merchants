import 'package:flutter/foundation.dart';

import '../models/bill.dart';
import '../models/product.dart';
import 'inventory_viewmodel.dart';

enum OrderSubmissionState { idle, submitting, success, error }

/// Drives the Order screen: cart contents, checkout configuration,
/// and submission flow against the unified egg pool.
class OrderViewModel extends ChangeNotifier {
  OrderViewModel(this._inventory);

  final InventoryViewModel _inventory;

  // Cart — keyed by Firestore product ID
  final Map<String, int> _cart = {};
  Map<String, int> get cart => Map.unmodifiable(_cart);

  // Checkout sheet config
  BillType _paymentType = BillType.cash;
  String _customer = '';
  double _discount = 0;
  String _discountText = '';

  BillType get paymentType => _paymentType;
  String get customer => _customer;
  String get discountText => _discountText;

  OrderSubmissionState _submission = OrderSubmissionState.idle;
  OrderSubmissionState get submission => _submission;
  bool get isSubmitting => _submission == OrderSubmissionState.submitting;

  // ── Cart actions ───────────────────────────────────────────
  int qtyOf(String productId) => _cart[productId] ?? 0;
  bool get hasItems => _cart.values.any((q) => q > 0);

  double get subtotal => _inventory.products.fold(0.0, (acc, p) {
        return acc + qtyOf(p.id) * p.price;
      });

  double get total =>
      (subtotal - _discount).clamp(0, double.infinity).toDouble();

  /// Total eggs currently committed to the cart across all products.
  int get cartEggs {
    int total = 0;
    for (final entry in _cart.entries) {
      final product = _inventory.productById(entry.key);
      if (product != null && product.eggsPerUnit > 0) {
        total += entry.value * product.eggsPerUnit;
      }
    }
    return total;
  }

  /// Pool eggs still available after subtracting what's already in the cart.
  int get effectivePoolRemaining => _inventory.poolRemaining - cartEggs;

  void increment(String productId) {
    final product = _inventory.productById(productId);
    if (product == null) return;
    if (product.eggsPerUnit > 0) {
      if (effectivePoolRemaining < product.eggsPerUnit) return;
    }
    _cart.update(productId, (q) => q + 1, ifAbsent: () => 1);
    notifyListeners();
  }

  void decrement(String productId) {
    final next = qtyOf(productId) - 1;
    if (next <= 0) {
      _cart.remove(productId);
    } else {
      _cart[productId] = next;
    }
    notifyListeners();
  }

  void setQty(String productId, int qty) {
    final product = _inventory.productById(productId);
    int max;
    if (product != null && product.eggsPerUnit > 0) {
      // Pool available before this product's current cart contribution
      final poolBeforeThis =
          _inventory.poolRemaining - (cartEggs - qtyOf(productId) * product.eggsPerUnit);
      max = poolBeforeThis ~/ product.eggsPerUnit;
    } else {
      max = qty;
    }
    final clamped = qty.clamp(0, max < 0 ? 0 : max);
    if (clamped <= 0) {
      _cart.remove(productId);
    } else {
      _cart[productId] = clamped;
    }
    notifyListeners();
  }

  void resetCart() {
    _cart.clear();
    _customer = '';
    _discount = 0;
    _discountText = '';
    _paymentType = BillType.cash;
    _submission = OrderSubmissionState.idle;
    notifyListeners();
  }

  List<Product> selectedProducts() => _inventory.products
      .where((p) => qtyOf(p.id) > 0)
      .toList(growable: false);

  // ── Checkout config ────────────────────────────────────────
  void setPaymentType(BillType type) {
    if (_paymentType == type) return;
    _paymentType = type;
    notifyListeners();
  }

  void setCustomer(String value) {
    _customer = value;
    notifyListeners();
  }

  void setDiscountText(String text) {
    _discountText = text;
    _discount = double.tryParse(text) ?? 0;
    notifyListeners();
  }

  // ── Submit ─────────────────────────────────────────────────
  Future<bool> submit() async {
    if (!hasItems) return false;
    _submission = OrderSubmissionState.submitting;
    notifyListeners();
    final ok = await _inventory.createBill(
      cart: Map<String, int>.from(_cart),
      discount: _discount,
      type: _paymentType,
      customer: _customer.trim(),
    );
    if (ok) {
      _submission = OrderSubmissionState.success;
      _cart.clear();
      _customer = '';
      _discount = 0;
      _discountText = '';
      _paymentType = BillType.cash;
    } else {
      _submission = OrderSubmissionState.error;
    }
    notifyListeners();
    return ok;
  }
}
