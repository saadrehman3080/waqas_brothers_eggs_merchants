import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/constants/app_strings.dart';
import '../core/utils/device_name.dart';
import '../core/utils/format_helpers.dart';
import '../models/bill.dart';
import '../models/product.dart';
import '../services/data_service.dart';

enum InventoryState { initial, loading, loaded, error }

/// Shared inventory state. All product and bill data flows in through live
/// Firestore snapshot streams — subscribed once on startup and kept open
/// for the lifetime of the viewmodel. Screens read reactive getters; they
/// never trigger their own loads.
class InventoryViewModel extends ChangeNotifier {
  InventoryViewModel(this._dataService);

  final DataService _dataService;

  StreamSubscription<List<Product>>? _productsSub;
  StreamSubscription<List<CashBill>>? _cashBillsSub;
  StreamSubscription<List<CreditBill>>? _creditBillsSub;

  String? _cachedDeviceName;
  Future<String> _deviceName() async =>
      _cachedDeviceName ??= await resolveDeviceName();

  InventoryState _state = InventoryState.initial;
  String? _errorMessage;

  List<Product> _products = const [];
  List<CashBill> _cashBills = const [];
  List<CreditBill> _creditBills = const [];

  bool _cashBillsLoaded = false;
  bool _creditBillsLoaded = false;

  // ── Getters ────────────────────────────────────────────────
  InventoryState get state => _state;
  bool get isLoading => _state == InventoryState.loading;
  String? get errorMessage => _errorMessage;

  List<Product> get products => List.unmodifiable(_products);
  List<Bill> get bills => [..._cashBills, ..._creditBills];

  /// True until the cash-bills stream emits its first snapshot.
  bool get cashBillsLoading => !_cashBillsLoaded;

  /// True until the credit-bills stream emits its first snapshot.
  bool get creditBillsLoading => !_creditBillsLoaded;

  int get creditCount => _creditBills.length;

  // ── Loading ────────────────────────────────────────────────
  Future<void> load() async {
    _state = InventoryState.loading;
    _errorMessage = null;
    notifyListeners();

    await _productsSub?.cancel();
    _productsSub = _dataService.watchProducts().listen(
      (products) {
        _products = products;
        if (_state != InventoryState.loaded) {
          _state = InventoryState.loaded;
        }
        notifyListeners();
      },
      onError: (e) {
        _state = InventoryState.error;
        _errorMessage = e.toString();
        debugPrint('watchProducts error: $e');
        notifyListeners();
      },
    );

    _subscribeTodayBills();
  }

  void _subscribeTodayBills() {
    final today = FormatHelpers.todayKey();

    _cashBillsSub?.cancel();
    _cashBillsSub = _dataService.watchCashBillsForDate(today).listen(
      (bills) {
        _cashBills = bills;
        _cashBillsLoaded = true;
        notifyListeners();
      },
      onError: (e) => debugPrint('watchCashBills error: $e'),
    );

    _creditBillsSub?.cancel();
    _creditBillsSub = _dataService.watchCreditBillsForDate(today).listen(
      (bills) {
        _creditBills = bills;
        _creditBillsLoaded = true;
        notifyListeners();
      },
      onError: (e) => debugPrint('watchCreditBills error: $e'),
    );
  }

  @override
  void dispose() {
    _productsSub?.cancel();
    _cashBillsSub?.cancel();
    _creditBillsSub?.cancel();
    super.dispose();
  }

  // ── Lookups ────────────────────────────────────────────────
  Product? productById(String id) {
    for (final p in _products) {
      if (p.id == id) return p;
    }
    return null;
  }

  // ── Mutations ──────────────────────────────────────────────
  Future<bool> createBill({
    required Map<String, int> cart,
    required double discount,
    required BillType type,
    required String customer,
  }) async {
    try {
      await _dataService.createBill(
        cart: cart,
        discount: discount,
        type: type,
        customer: customer.isEmpty ? AppStrings.walkInCustomer : customer,
        device: await _deviceName(),
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('createBill failed: $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> changeBillType(String id, BillType type) async {
    try {
      final bill = bills.firstWhere((b) => b.id == id);
      await _dataService.changeBillType(bill, type);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<List<CashBill>> fetchCashBillsForDate(String date) =>
      _dataService.fetchCashBillsForDate(date);

  Future<List<({CashBill bill, DateTime deletedAt})>> fetchDeletedCashBillsForDate(
          String date) =>
      _dataService.fetchDeletedCashBillsForDate(date);

  Future<bool> deleteCashBill(String id) async {
    try {
      final bill = _cashBills.firstWhere((b) => b.id == id);
      await _dataService.deleteCashBill(bill);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> addStockEntry({
    required String productId,
    required int qty,
  }) async {
    try {
      await _dataService.addStockEntry(
        productId: productId,
        qty: qty,
        device: await _deviceName(),
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduct({
    required String id,
    required String nameEn,
    required String nameUr,
    required double price,
    double revenuePerUnit = 0,
  }) async {
    try {
      await _dataService.updateProduct(
        id: id,
        nameEn: nameEn,
        nameUr: nameUr,
        price: price,
        revenuePerUnit: revenuePerUnit,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ── Aggregates ─────────────────────────────────────────────
  List<Bill> _todayBills() {
    final today = FormatHelpers.todayKey();
    return bills.where((b) => b.date == today).toList();
  }

  List<Bill> _currentMonthBills() {
    final now = DateTime.now();
    final prefix =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}';
    return bills.where((b) => b.date.startsWith(prefix)).toList();
  }

  double get todayCash => _todayBills()
      .where((b) => b.type == BillType.cash)
      .fold(0, (s, b) => s + b.total);

  double get todayCredit => _todayBills()
      .where((b) => b.type == BillType.credit)
      .fold(0, (s, b) => s + b.total);

  int get todayCustomerCount => _todayBills().length;

  int productQtyToday(String productId) {
    return _todayBills().fold<int>(0, (sum, b) {
      for (final item in b.items) {
        if (item.productId == productId) return sum + item.qty;
      }
      return sum;
    });
  }

  int productQtyTodayByName(String nameEn) {
    final product = _products.firstWhere(
      (p) => p.nameEn == nameEn,
      orElse: () => const Product(
        id: '', nameEn: '', nameUr: '', price: 0, stock: 0, sold: 0,
      ),
    );
    if (product.id.isEmpty) return 0;
    return productQtyToday(product.id);
  }

  double get todayRevenue {
    double total = 0;
    for (final bill in _todayBills()) {
      for (final item in bill.items) {
        final product = productById(item.productId);
        if (product == null) continue;
        total += item.qty * product.revenuePerUnit;
      }
    }
    return total;
  }

  Map<String, String> get monthlySummary {
    final monthBills = _currentMonthBills();
    if (monthBills.isEmpty) {
      return {
        'revenue': FormatHelpers.currency(0),
        'orders': '0',
        'margin': FormatHelpers.currency(0),
        'cash': FormatHelpers.currency(0),
        'customers': '0',
        'avgOrder': FormatHelpers.currency(0),
      };
    }

    double revenue = 0;
    double cash = 0;
    double margin = 0;
    final customers = <String>{};

    for (final bill in monthBills) {
      revenue += bill.total;
      if (bill.type == BillType.cash) cash += bill.total;
      if (bill.customer.isNotEmpty) customers.add(bill.customer);
      for (final item in bill.items) {
        final product = productById(item.productId);
        if (product == null) continue;
        margin += item.qty * product.revenuePerUnit;
      }
    }

    final orders = monthBills.length;
    final avgOrder = orders == 0 ? 0.0 : revenue / orders;

    return {
      'revenue': FormatHelpers.currency(revenue),
      'orders': orders.toString(),
      'margin': FormatHelpers.currency(margin),
      'cash': FormatHelpers.currency(cash),
      'customers': customers.length.toString(),
      'avgOrder': FormatHelpers.currency(avgOrder),
    };
  }
}
