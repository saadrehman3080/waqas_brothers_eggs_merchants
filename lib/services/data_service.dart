import '../core/constants/app_strings.dart';
import '../core/utils/format_helpers.dart';
import '../models/bill.dart';
import '../models/bill_item.dart';
import '../models/printer_device.dart';
import '../models/product.dart';
import '../models/stock_entry.dart';

/// In-memory backend that mirrors the public API of the Firestore service
/// in the reference project. Swap this implementation for a real
/// Firestore/HTTP client without changing the viewmodels.
class DataService {
  DataService() {
    _seed();
  }

  // ── Stores ─────────────────────────────────────────────────
  final List<Product> _products = [];
  final List<Bill> _bills = [];
  final List<StockEntry> _stockEntries = [];

  // ── Products ───────────────────────────────────────────────
  Future<List<Product>> getProducts() async {
    await _simulateLatency();
    final out = List<Product>.from(_products);
    out.sort((a, b) => a.id.compareTo(b.id));
    return out;
  }

  Future<Product> addProduct({
    required String nameEn,
    required String nameUr,
    required double price,
    double revenuePerUnit = 0,
  }) async {
    await _simulateLatency();
    final product = Product(
      id: DateTime.now().millisecondsSinceEpoch,
      nameEn: nameEn,
      nameUr: nameUr,
      price: price,
      stock: 0,
      sold: 0,
      revenuePerUnit: revenuePerUnit,
    );
    _products.add(product);
    return product;
  }

  Future<Product> updateProduct({
    required int id,
    required String nameEn,
    required String nameUr,
    required double price,
    double revenuePerUnit = 0,
  }) async {
    await _simulateLatency();
    final index = _products.indexWhere((p) => p.id == id);
    if (index == -1) {
      throw StateError('Product $id not found');
    }
    final updated = _products[index].copyWith(
      nameEn: nameEn,
      nameUr: nameUr,
      price: price,
      revenuePerUnit: revenuePerUnit,
    );
    _products[index] = updated;
    return updated;
  }

  // ── Bills ──────────────────────────────────────────────────
  Future<List<Bill>> getBills() async {
    await _simulateLatency();
    final out = List<Bill>.from(_bills);
    out.sort((a, b) => b.id.compareTo(a.id));
    return out;
  }

  Future<Bill> createBill({
    required Map<int, int> cart,
    required double discount,
    required BillType type,
    required String customer,
    required String device,
  }) async {
    await _simulateLatency();
    final items = <BillItem>[];
    double subtotal = 0;
    cart.forEach((pid, qty) {
      if (qty <= 0) return;
      final product = _products.firstWhere(
        (p) => p.id == pid,
        orElse: () => throw StateError('Product $pid not found'),
      );
      items.add(BillItem(productId: pid, qty: qty, price: product.price));
      subtotal += product.price * qty;
    });
    if (items.isEmpty) {
      throw StateError('Cannot create an empty bill');
    }
    final total = (subtotal - discount).clamp(0, double.infinity).toDouble();

    final bill = Bill(
      id: DateTime.now().millisecondsSinceEpoch,
      date: FormatHelpers.todayKey(),
      time: FormatHelpers.timeNow(),
      items: items,
      total: total,
      type: type,
      customer: customer,
      device: device,
    );
    _bills.insert(0, bill);

    // Apply sold counts
    for (final item in items) {
      final i = _products.indexWhere((p) => p.id == item.productId);
      if (i != -1) {
        _products[i] = _products[i].copyWith(
          sold: _products[i].sold + item.qty,
        );
      }
    }

    return bill;
  }

  Future<void> deleteBill(int id) async {
    await _simulateLatency();
    _bills.removeWhere((b) => b.id == id);
  }

  Future<Bill> changeBillType(int id, BillType type) async {
    await _simulateLatency();
    final index = _bills.indexWhere((b) => b.id == id);
    if (index == -1) {
      throw StateError('Bill $id not found');
    }
    final updated = _bills[index].copyWith(type: type);
    _bills[index] = updated;
    return updated;
  }

  // ── Stock entries ──────────────────────────────────────────
  Future<List<StockEntry>> getStockEntries() async {
    await _simulateLatency();
    return List<StockEntry>.from(_stockEntries);
  }

  Future<StockEntry> addStockEntry({
    required int productId,
    required int qty,
    required String device,
  }) async {
    await _simulateLatency();
    final entry = StockEntry(
      id: DateTime.now().millisecondsSinceEpoch,
      productId: productId,
      qty: qty,
      date: FormatHelpers.todayKey(),
      time: FormatHelpers.timeNow(),
      device: device,
    );
    _stockEntries.add(entry);

    final i = _products.indexWhere((p) => p.id == productId);
    if (i != -1) {
      _products[i] = _products[i].copyWith(stock: _products[i].stock + qty);
    }
    return entry;
  }

  // ── Printer ────────────────────────────────────────────────
  Future<List<PrinterDevice>> getPairedPrinters() async {
    await _simulateLatency();
    return const [
      PrinterDevice(
        name: 'BT Printer ESC-58',
        address: '00:11:22:33:44:55',
        description: '58mm thermal',
      ),
      PrinterDevice(
        name: 'Generic BT Device',
        address: '66:77:88:99:AA:BB',
        description: '58mm thermal',
      ),
    ];
  }

  // ── Static aggregates returned for the dashboard ─────────────
  Map<String, String> getMonthlySummary() => const {
    'revenue': 'Rs 41,200',
    'orders': '38',
    'credit': 'Rs 8,244',
    'cash': 'Rs 32,956',
    'customers': '36',
    'avgOrder': 'Rs 1,088',
  };

  // ── Helpers ────────────────────────────────────────────────
  Future<void> _simulateLatency() =>
      Future<void>.delayed(const Duration(milliseconds: 80));

  void _seed() {
    _products.addAll(const [
      Product(
        id: 1,
        nameEn: 'Single Egg',
        nameUr: 'انڈا',
        price: 25,
        stock: 5400,
        sold: 50,
        revenuePerUnit: 2,
      ),
      Product(
        id: 2,
        nameEn: 'Egg Dozen',
        nameUr: 'درجن انڈے',
        price: 250,
        stock: 450,
        sold: 120,
        revenuePerUnit: 30,
      ),
      Product(
        id: 3,
        nameEn: 'Egg Tray',
        nameUr: 'انڈوں کی ٹرے',
        price: 610,
        stock: 60,
        sold: 18,
        revenuePerUnit: 72,
      ),
      Product(
        id: 4,
        nameEn: 'Patty',
        nameUr: 'پیٹی',
        price: 7260,
        stock: 10,
        sold: 2,
        revenuePerUnit: 864,
      ),
    ]);

    const device = AppStrings.defaultDeviceId;
    _bills.addAll([
      Bill(
        id: 101,
        date: '2026-04-26',
        time: '09:14',
        items: [
          BillItem(productId: 1, qty: 10, price: 180),
          BillItem(productId: 2, qty: 2, price: 432),
        ],
        total: 2664,
        type: BillType.cash,
        customer: 'Ahmed Store',
        device: device,
      ),
      Bill(
        id: 102,
        date: '2026-04-26',
        time: '10:30',
        items: [BillItem(productId: 1, qty: 5, price: 180)],
        total: 900,
        type: BillType.credit,
        customer: 'Bilal Mart',
        device: device,
      ),
      Bill(
        id: 105,
        date: '2026-04-26',
        time: '11:00',
        items: [BillItem(productId: 4, qty: 10, price: 16)],
        total: 160,
        type: BillType.cash,
        customer: '',
        device: device,
      ),
      Bill(
        id: 103,
        date: '2026-04-25',
        time: '14:20',
        items: [BillItem(productId: 3, qty: 1, price: 5184)],
        total: 5184,
        type: BillType.cash,
        customer: '',
        device: 'SM-A225',
      ),
      Bill(
        id: 104,
        date: '2026-04-25',
        time: '16:05',
        items: [BillItem(productId: 2, qty: 5, price: 432)],
        total: 2160,
        type: BillType.credit,
        customer: 'Tariq Wholesale',
        device: 'SM-A225',
      ),
    ]);

    _stockEntries.addAll(const [
      StockEntry(
        id: 1,
        productId: 1,
        qty: 570,
        date: '2026-04-24',
        time: '07:00',
        device: device,
      ),
      StockEntry(
        id: 2,
        productId: 2,
        qty: 78,
        date: '2026-04-24',
        time: '07:00',
        device: device,
      ),
      StockEntry(
        id: 3,
        productId: 3,
        qty: 12,
        date: '2026-04-24',
        time: '07:00',
        device: device,
      ),
      StockEntry(
        id: 4,
        productId: 4,
        qty: 5450,
        date: '2026-04-24',
        time: '07:00',
        device: device,
      ),
    ]);
  }
}
