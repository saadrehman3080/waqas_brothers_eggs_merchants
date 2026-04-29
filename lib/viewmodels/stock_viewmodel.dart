import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../models/stock_entry.dart';
import 'inventory_viewmodel.dart';

enum StockView { list, addStock, editProduct }

/// Drives the Stock & Products screen — controls which sub-view is shown
/// (list / add stock / edit product) and exposes form state.
class StockViewModel extends ChangeNotifier {
  StockViewModel(this._inventory);

  final InventoryViewModel _inventory;

  StockView _view = StockView.list;
  StockView get view => _view;

  Product? _editingProduct;
  Product? get editingProduct => _editingProduct;
  bool get isEditing => _editingProduct != null;

  // Add-stock form
  int? selectedProductId;
  String stockQtyText = '';
  String addStockRevenuePerUnitText = '';

  // Product form
  String nameEn = '';
  String nameUr = '';
  String priceText = '';
  String revenuePerUnitText = '';

  List<Product> get products => _inventory.products;

  List<StockEntry> entriesFor(int productId) =>
      _inventory.stockEntries.where((e) => e.productId == productId).toList();

  // ── View transitions ───────────────────────────────────────
  void showList() {
    _view = StockView.list;
    _resetForm();
    notifyListeners();
  }

  void showAddStock() {
    _resetForm();
    _view = StockView.addStock;
    addStockRevenuePerUnitText = '';
    notifyListeners();
  }

  void showNewProduct() {
    _resetForm();
    _view = StockView.editProduct;
    notifyListeners();
  }

  void showEditProduct(Product product) {
    _editingProduct = product;
    nameEn = product.nameEn;
    nameUr = product.nameUr;
    priceText = product.price.toStringAsFixed(0);
    revenuePerUnitText = product.revenuePerUnit.toStringAsFixed(0);
    selectedProductId = null;
    stockQtyText = '';
    _view = StockView.editProduct;
    notifyListeners();
  }

  // ── Field setters ──────────────────────────────────────────
  void setSelectedProductId(int? id) {
    selectedProductId = id;
    notifyListeners();
  }

  void setStockQtyText(String value) {
    stockQtyText = value;
  }

  void setAddStockRevenuePerUnitText(String value) {
    addStockRevenuePerUnitText = value;
  }

  void setNameEn(String value) => nameEn = value;
  void setNameUr(String value) => nameUr = value;
  void setPriceText(String value) => priceText = value;
  void setRevenuePerUnitText(String value) => revenuePerUnitText = value;

  // ── Submission ─────────────────────────────────────────────
  Future<bool> submitAddStock() async {
    final pid = selectedProductId;
    final qty = int.tryParse(stockQtyText);
    if (pid == null || qty == null || qty <= 0) return false;

    // Update revenuePerUnit if provided
    if (addStockRevenuePerUnitText.isNotEmpty) {
      final revenuePerUnit = double.tryParse(addStockRevenuePerUnitText);
      if (revenuePerUnit != null) {
        await _inventory.updateProductRevenuePerUnit(
          id: pid,
          revenuePerUnit: revenuePerUnit,
        );
      }
    }

    final ok = await _inventory.addStockEntry(productId: pid, qty: qty);
    if (ok) showList();
    return ok;
  }

  Future<bool> submitProduct() async {
    final price = double.tryParse(priceText);
    final revenuePerUnit = double.tryParse(revenuePerUnitText);
    if (nameEn.trim().isEmpty || price == null) return false;

    final editing = _editingProduct;
    final ok = editing != null
        ? await _inventory.updateProduct(
            id: editing.id,
            nameEn: nameEn.trim(),
            nameUr: nameUr.trim(),
            price: price,
            revenuePerUnit: revenuePerUnit ?? 0,
          )
        : await _inventory.addProduct(
            nameEn: nameEn.trim(),
            nameUr: nameUr.trim(),
            price: price,
            revenuePerUnit: revenuePerUnit ?? 0,
          );

    if (ok) showList();
    return ok;
  }

  // ── Internals ──────────────────────────────────────────────
  void _resetForm() {
    _editingProduct = null;
    selectedProductId = null;
    stockQtyText = '';
    addStockRevenuePerUnitText = '';
    nameEn = '';
    nameUr = '';
    priceText = '';
    revenuePerUnitText = '';
  }
}
