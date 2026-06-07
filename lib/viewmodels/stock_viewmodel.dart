import 'package:flutter/foundation.dart';

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

  // ── Add-stock field ────────────────────────────────────────
  String formulaPattyText = '';
  String formulaTrayText = '';

  List<Product> get products => _inventory.products;

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
    revenuePerUnitText = product.revenuePerProductType.toStringAsFixed(0);
    _view = StockView.editProduct;
    notifyListeners();
  }

  // ── Formula field setter ───────────────────────────────────
  void setFormulaPatty(String raw) {
    formulaPattyText = _digits(raw);
    notifyListeners();
  }

  void setFormulaTray(String raw) {
    formulaTrayText = _digits(raw);
    notifyListeners();
  }

  // ── Submission ─────────────────────────────────────────────
  Future<bool> submitAddStock() async {
    final patties = int.tryParse(formulaPattyText) ?? 0;
    final trays = int.tryParse(formulaTrayText) ?? 0;
    if (patties <= 0 && trays <= 0) return false;
    final ok = await _inventory.addStockEntry(patties: patties, trays: trays);
    if (ok) showList();
    return ok;
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
  static String _digits(String s) => s.replaceAll(RegExp(r'[^0-9]'), '');

  void _resetForm() {
    _editingProduct = null;
    nameEn = '';
    nameUr = '';
    priceText = '';
    revenuePerUnitText = '';
    formulaPattyText = '';
    formulaTrayText = '';
  }
}
