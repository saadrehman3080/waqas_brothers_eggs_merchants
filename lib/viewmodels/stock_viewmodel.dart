import 'package:flutter/foundation.dart';

import '../core/utils/egg_units.dart';
import '../models/product.dart';
import 'inventory_viewmodel.dart';

enum StockView { list, addStock, editProduct }

class StockViewModel extends ChangeNotifier {
  StockViewModel(this._inventory);

  final InventoryViewModel _inventory;

  StockView _view = StockView.list;
  StockView get view => _view;

  // ── Edit-product form state ────────────────────────────────
  Product? _editingProduct;
  Product? get editingProduct => _editingProduct;
  bool get isEditing => _editingProduct != null;

  String nameEn = '';
  String nameUr = '';
  String priceText = '';
  String revenuePerUnitText = '';

  void setNameEn(String v) => nameEn = v;
  void setNameUr(String v) => nameUr = v;
  void setPriceText(String v) => priceText = v;
  void setRevenuePerUnitText(String v) => revenuePerUnitText = v;

  // ── Add-stock form: productId → raw qty text ───────────────
  final Map<String, String> _stockQtyMap = {};

  // Formula converter fields (display state; drives _stockQtyMap for egg products)
  String formulaPattyText = '';
  String formulaTrayText = '';
  String formulaDozenText = '';
  String formulaSingleText = '';

  List<Product> get products => _inventory.products;

  String stockQtyTextFor(String productId) => _stockQtyMap[productId] ?? '';

  // ── View transitions ───────────────────────────────────────
  void showList() {
    _view = StockView.list;
    _resetForm();
    notifyListeners();
  }

  void showAddStock() {
    _resetForm();
    _view = StockView.addStock;
    notifyListeners();
  }

  void showEditProduct(Product product) {
    _resetForm();
    _editingProduct = product;
    nameEn = product.nameEn;
    nameUr = product.nameUr;
    priceText = product.price.toStringAsFixed(0);
    revenuePerUnitText = product.revenuePerUnit.toStringAsFixed(0);
    _view = StockView.editProduct;
    notifyListeners();
  }

  // ── Stock qty field setters ────────────────────────────────
  void setStockQtyText(String productId, String text) {
    _stockQtyMap[productId] = _digits(text);
  }

  // ── Formula field setters ──────────────────────────────────
  void setFormulaPatty(String raw) {
    formulaPattyText = _digits(raw);
    final n = int.tryParse(formulaPattyText) ?? 0;
    if (n > 0) {
      final r = EggUnits.fromPatties(n);
      formulaTrayText = '${r.trays}';
      formulaDozenText = '${r.dozens}';
      formulaSingleText = '${r.eggs}';
    } else {
      formulaTrayText = formulaDozenText = formulaSingleText = '';
    }
    _applyFormulaToProducts();
    notifyListeners();
  }

  void setFormulaTray(String raw) {
    formulaTrayText = _digits(raw);
    final n = int.tryParse(formulaTrayText) ?? 0;
    if (n > 0) {
      final r = EggUnits.fromTrays(n);
      formulaPattyText = r.patties != null ? '${r.patties}' : '';
      formulaDozenText = '${r.dozens}';
      formulaSingleText = '${r.eggs}';
    } else {
      formulaPattyText = formulaDozenText = formulaSingleText = '';
    }
    _applyFormulaToProducts();
    notifyListeners();
  }

  void setFormulaDozen(String raw) {
    formulaDozenText = _digits(raw);
    final n = int.tryParse(formulaDozenText) ?? 0;
    if (n > 0) {
      final r = EggUnits.fromDozens(n);
      formulaPattyText = r.patties != null ? '${r.patties}' : '';
      formulaTrayText = r.trays != null ? '${r.trays}' : '';
      formulaSingleText = '${r.eggs}';
    } else {
      formulaPattyText = formulaTrayText = formulaSingleText = '';
    }
    _applyFormulaToProducts();
    notifyListeners();
  }

  void setFormulaSingle(String raw) {
    formulaSingleText = _digits(raw);
    final n = int.tryParse(formulaSingleText) ?? 0;
    if (n > 0) {
      final r = EggUnits.fromEggs(n);
      formulaPattyText = r.patties != null ? '${r.patties}' : '';
      formulaTrayText = r.trays != null ? '${r.trays}' : '';
      formulaDozenText = r.dozens != null ? '${r.dozens}' : '';
    } else {
      formulaPattyText = formulaTrayText = formulaDozenText = '';
    }
    _applyFormulaToProducts();
    notifyListeners();
  }

  // ── Submission ─────────────────────────────────────────────
  Future<bool> submitAddStock() async {
    final toSubmit = <String, int>{};
    for (final entry in _stockQtyMap.entries) {
      final qty = int.tryParse(entry.value);
      if (qty != null && qty > 0) toSubmit[entry.key] = qty;
    }
    if (toSubmit.isEmpty) return false;

    bool anyOk = false;
    for (final entry in toSubmit.entries) {
      final ok =
          await _inventory.addStockEntry(productId: entry.key, qty: entry.value);
      if (ok) anyOk = true;
    }
    if (anyOk) showList();
    return anyOk;
  }

  Future<bool> submitProduct() async {
    final price = double.tryParse(priceText);
    final revenuePerUnit = double.tryParse(revenuePerUnitText) ?? 0;
    final editing = _editingProduct;
    if (editing == null || price == null) return false;

    final ok = await _inventory.updateProduct(
      id: editing.id,
      nameEn: nameEn.trim(),
      nameUr: nameUr.trim(),
      price: price,
      revenuePerUnit: revenuePerUnit,
    );
    if (ok) showList();
    return ok;
  }

  // ── Internals ──────────────────────────────────────────────
  void _applyFormulaToProducts() {
    final nameToQty = {
      'Patty': formulaPattyText,
      'Egg Tray': formulaTrayText,
      'Egg Dozen': formulaDozenText,
      'Single Egg': formulaSingleText,
    };
    for (final p in products) {
      final qty = nameToQty[p.nameEn];
      if (qty == null) continue;
      if (qty.isNotEmpty) {
        _stockQtyMap[p.id] = qty;
      } else {
        _stockQtyMap.remove(p.id);
      }
    }
  }

  static String _digits(String s) => s.replaceAll(RegExp(r'[^0-9]'), '');

  void _resetForm() {
    _editingProduct = null;
    nameEn = '';
    nameUr = '';
    priceText = '';
    revenuePerUnitText = '';
    _stockQtyMap.clear();
    formulaPattyText = '';
    formulaTrayText = '';
    formulaDozenText = '';
    formulaSingleText = '';
  }
}
