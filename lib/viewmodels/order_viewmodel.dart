import 'package:flutter/foundation.dart';

import '../models/bill.dart';
import '../models/product.dart';
import 'inventory_viewmodel.dart';

enum OrderSubmissionState { idle, submitting, success, error }

/// Drives the Order screen: cart contents, checkout configuration,
/// submission flow.
class OrderViewModel extends ChangeNotifier {
  OrderViewModel(this._inventory);

  final InventoryViewModel _inventory;

  // Cart — keyed by Firestore product ID (String)
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

  // Submission
  OrderSubmissionState _submission = OrderSubmissionState.idle;
  OrderSubmissionState get submission => _submission;
  bool get isSubmitting => _submission == OrderSubmissionState.submitting;

  // ── Cart actions ───────────────────────────────────────────
  int qtyOf(String productId) => _cart[productId] ?? 0;
  bool get hasItems => _cart.values.any((q) => q > 0);

  double get subtotal => _inventory.products.fold(0.0, (sum, p) {
        return sum + qtyOf(p.id) * p.price;
      });

  double get total =>
      (subtotal - _discount).clamp(0, double.infinity).toDouble();

  void increment(String productId) {
    final product = _inventory.productById(productId);
    if (product != null && qtyOf(productId) >= product.remaining) return;
    _cart.update(productId, (q) => q + 1, ifAbsent: () => 1);
    notifyListeners();
  }

  void decrement(String productId) {
    final next = (qtyOf(productId)) - 1;
    if (next <= 0) {
      _cart.remove(productId);
    } else {
      _cart[productId] = next;
    }
    notifyListeners();
  }

  void setQty(String productId, int qty) {
    final product = _inventory.productById(productId);
    final max = product != null ? product.remaining : qty;
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
