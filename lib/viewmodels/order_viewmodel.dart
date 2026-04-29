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

  // Cart
  final Map<int, int> _cart = {};
  Map<int, int> get cart => Map.unmodifiable(_cart);

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
  int qtyOf(int productId) => _cart[productId] ?? 0;
  bool get hasItems => _cart.values.any((q) => q > 0);

  double get subtotal => _inventory.products.fold(0.0, (sum, p) {
        return sum + qtyOf(p.id) * p.price;
      });

  double get total =>
      (subtotal - _discount).clamp(0, double.infinity).toDouble();

  void increment(int productId) {
    _cart.update(productId, (q) => q + 1, ifAbsent: () => 1);
    notifyListeners();
  }

  void decrement(int productId) {
    final next = (qtyOf(productId)) - 1;
    if (next <= 0) {
      _cart.remove(productId);
    } else {
      _cart[productId] = next;
    }
    notifyListeners();
  }

  void setQty(int productId, int qty) {
    if (qty <= 0) {
      _cart.remove(productId);
    } else {
      _cart[productId] = qty;
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
      cart: Map<int, int>.from(_cart),
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
