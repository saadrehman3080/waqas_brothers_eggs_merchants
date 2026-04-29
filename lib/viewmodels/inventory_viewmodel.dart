import 'package:flutter/foundation.dart';

import '../core/constants/app_strings.dart';
import '../models/bill.dart';
import '../models/printer_device.dart';
import '../models/product.dart';
import '../models/stock_entry.dart';
import '../services/data_service.dart';

enum InventoryState { initial, loading, loaded, error }

/// Shared inventory state — products, bills, stock entries — used by every
/// screen. Splitting this back out per-screen would mean reloading the same
/// collections every tab switch, so we keep one source of truth here.
class InventoryViewModel extends ChangeNotifier {
  InventoryViewModel(this._dataService);

  final DataService _dataService;

  InventoryState _state = InventoryState.initial;
  String? _errorMessage;

  List<Product> _products = const [];
  List<Bill> _bills = const [];
  List<StockEntry> _stockEntries = const [];
  List<PrinterDevice> _printers = const [];
  bool _printerOn = false;

  // ── Getters ─────────────────────────────────────────────────
  InventoryState get state => _state;
  bool get isLoading => _state == InventoryState.loading;
  String? get errorMessage => _errorMessage;

  List<Product> get products => List.unmodifiable(_products);
  List<Bill> get bills => List.unmodifiable(_bills);
  List<StockEntry> get stockEntries => List.unmodifiable(_stockEntries);
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
        _dataService.getStockEntries(),
        _dataService.getPairedPrinters(),
      ]);
      _products = results[0] as List<Product>;
      _bills = results[1] as List<Bill>;
      _stockEntries = results[2] as List<StockEntry>;
      _printers = results[3] as List<PrinterDevice>;
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
  Product? productById(int id) {
    for (final p in _products) {
      if (p.id == id) return p;
    }
    return null;
  }

  int get creditCount => _bills.where((b) => b.type == BillType.credit).length;

  // ── Mutations ──────────────────────────────────────────────
  Future<bool> createBill({
    required Map<int, int> cart,
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
        device: AppStrings.defaultDeviceId,
      );
      _bills = [bill, ..._bills];
      // Reflect product sold totals locally
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

  Future<bool> addStockEntry({required int productId, required int qty}) async {
    try {
      final entry = await _dataService.addStockEntry(
        productId: productId,
        qty: qty,
        device: AppStrings.defaultDeviceId,
      );
      _stockEntries = [..._stockEntries, entry];
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
    required int id,
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
    required int id,
    required double revenuePerUnit,
  }) async {
    try {
      final product = _products.firstWhere((p) => p.id == id);
      final updated = product.copyWith(revenuePerUnit: revenuePerUnit);
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
    const today = '2026-04-26'; // Matches the seeded date for the demo data.
    return _bills.where((b) => b.date == today).toList();
  }

  double get todayCash => _todayBills()
      .where((b) => b.type == BillType.cash)
      .fold(0, (s, b) => s + b.total);

  double get todayCredit => _todayBills()
      .where((b) => b.type == BillType.credit)
      .fold(0, (s, b) => s + b.total);

  int get todayCustomerCount => _todayBills().length;

  int productQtyToday(int pid) {
    return _todayBills().fold<int>(0, (sum, b) {
      for (final item in b.items) {
        if (item.productId == pid) return sum + item.qty;
      }
      return sum;
    });
  }

  /// Total margin/revenue earned today, computed from today's bill items
  /// using each product's `revenuePerUnit`.
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
}
