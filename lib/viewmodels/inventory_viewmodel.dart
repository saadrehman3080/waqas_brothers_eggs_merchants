import 'package:flutter/foundation.dart';

import '../core/constants/app_strings.dart';
import '../core/utils/device_name.dart';
import '../core/utils/format_helpers.dart';
import '../models/bill.dart';
import '../models/printer_device.dart';
import '../models/product.dart';
import '../services/data_service.dart';

enum InventoryState { initial, loading, loaded, error }

/// Shared inventory state — products, bills, stock entries — used by every
/// screen. Splitting this back out per-screen would mean reloading the same
/// collections every tab switch, so we keep one source of truth here.
class InventoryViewModel extends ChangeNotifier {
  InventoryViewModel(this._dataService);

  final DataService _dataService;

  String? _cachedDeviceName;
  Future<String> _deviceName() async =>
      _cachedDeviceName ??= await resolveDeviceName();

  InventoryState _state = InventoryState.initial;
  String? _errorMessage;

  List<Product> _products = const [];
  List<Bill> _bills = const [];
  List<PrinterDevice> _printers = const [];
  bool _printerOn = false;

  // ── Getters ────────────────────────────────────────────────
  InventoryState get state => _state;
  bool get isLoading => _state == InventoryState.loading;
  String? get errorMessage => _errorMessage;

  List<Product> get products => List.unmodifiable(_products);
  List<Bill> get bills => List.unmodifiable(_bills);
  List<PrinterDevice> get printers => List.unmodifiable(_printers);
  bool get printerOn => _printerOn;

  // ── Loading ────────────────────────────────────────────────
  Future<void> load() async {
    _state = InventoryState.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _dataService.getProducts(),
        _dataService.getBills(),
        _dataService.getPairedPrinters(),
      ]);
      _products = results[0] as List<Product>;
      _bills = results[1] as List<Bill>;
      _printers = results[2] as List<PrinterDevice>;
      _state = InventoryState.loaded;
    } catch (e) {
      _state = InventoryState.error;
      _errorMessage = e.toString();
      debugPrint('InventoryViewModel.load failed: $e');
    }
    notifyListeners();
  }

  Future<void> refresh() => load();

  // ── Lookups ────────────────────────────────────────────────
  Product? productById(String id) {
    for (final p in _products) {
      if (p.id == id) return p;
    }
    return null;
  }

  int get creditCount => _bills.where((b) => b.type == BillType.credit).length;

  // ── Mutations ──────────────────────────────────────────────
  Future<bool> createBill({
    required Map<String, int> cart,
    required double discount,
    required BillType type,
    required String customer,
  }) async {
    try {
      final bill = await _dataService.createBill(
        cart: cart,
        discount: discount,
        type: type,
        customer: customer.isEmpty ? AppStrings.walkInCustomer : customer,
        device: await _deviceName(),
      );
      _bills = [bill, ..._bills];
      _products = await _dataService.getProducts();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('createBill failed: $e');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteBill(int id) async {
    try {
      await _dataService.deleteBill(id);
      _bills = _bills.where((b) => b.id != id).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> changeBillType(int id, BillType type) async {
    try {
      final updated = await _dataService.changeBillType(id, type);
      _bills = _bills.map((b) => b.id == id ? updated : b).toList();
      notifyListeners();
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
      _products = await _dataService.getProducts();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> addProduct({
    required String nameEn,
    required String nameUr,
    required double price,
    double revenuePerUnit = 0,
  }) async {
    try {
      final product = await _dataService.addProduct(
        nameEn: nameEn,
        nameUr: nameUr,
        price: price,
        revenuePerUnit: revenuePerUnit,
      );
      _products = [..._products, product];
      notifyListeners();
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
      final product = await _dataService.updateProduct(
        id: id,
        nameEn: nameEn,
        nameUr: nameUr,
        price: price,
        revenuePerUnit: revenuePerUnit,
      );
      _products = _products.map((p) => p.id == id ? product : p).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProductRevenuePerUnit({
    required String id,
    required double revenuePerUnit,
  }) async {
    try {
      final updated = await _dataService.updateProductRevenuePerUnit(
        id: id,
        revenuePerUnit: revenuePerUnit,
      );
      _products = _products.map((p) => p.id == id ? updated : p).toList();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void togglePrinterAt(int index) {
    if (index < 0 || index >= _printers.length) return;
    final updated = List<PrinterDevice>.from(_printers);
    final wasConnected = updated[index].isConnected;
    for (var i = 0; i < updated.length; i++) {
      updated[i] = updated[i].copyWith(isConnected: false);
    }
    updated[index] = updated[index].copyWith(isConnected: !wasConnected);
    _printers = updated;
    _printerOn = !wasConnected;
    notifyListeners();
  }

  void togglePrinter() {
    if (_printers.isEmpty) {
      _printerOn = !_printerOn;
      notifyListeners();
      return;
    }
    togglePrinterAt(0);
  }

  // ── Aggregates ─────────────────────────────────────────────
  List<Bill> _todayBills() {
    final today = FormatHelpers.todayKey();
    return _bills.where((b) => b.date == today).toList();
  }

  List<Bill> _currentMonthBills() {
    final now = DateTime.now();
    final prefix =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}';
    return _bills.where((b) => b.date.startsWith(prefix)).toList();
  }

  double get todayCash => _todayBills()
      .where((b) => b.type == BillType.cash)
      .fold(0, (s, b) => s + b.total);

  double get todayCredit => _todayBills()
      .where((b) => b.type == BillType.credit)
      .fold(0, (s, b) => s + b.total);

  int get todayCustomerCount => _todayBills().length;

  /// Units of [productId] sold today.
  int productQtyToday(String productId) {
    return _todayBills().fold<int>(0, (sum, b) {
      for (final item in b.items) {
        if (item.productId == productId) return sum + item.qty;
      }
      return sum;
    });
  }

  /// Units sold today for the product whose [nameEn] matches. Used by the
  /// dashboard which knows product names but not Firestore-generated IDs.
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

  /// Monthly aggregates computed from Firestore-loaded bills.
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
