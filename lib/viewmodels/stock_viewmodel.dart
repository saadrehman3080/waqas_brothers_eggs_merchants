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
  String eggsPerUnitText = '';

  void setNameEn(String v) => nameEn = v;
  void setNameUr(String v) => nameUr = v;
  void setPriceText(String v) => priceText = v;
  void setRevenuePerUnitText(String v) => revenuePerUnitText = v;
  void setEggsPerUnitText(String v) => eggsPerUnitText = v;

  // ── Add-stock formula fields ───────────────────────────────
  // Cross-fill display state — the single-egg count is the canonical value.
  String formulaPattyText = '';
  String formulaTrayText = '';
  String formulaDozenText = '';
  String formulaSingleText = '';

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
    revenuePerUnitText = product.revenuePerUnit.toStringAsFixed(0);
    eggsPerUnitText = product.eggsPerUnit > 0 ? '${product.eggsPerUnit}' : '';
    _view = StockView.editProduct;
    notifyListeners();
  }

  // ── Formula field setters (cross-fill using EggUnits) ─────
  void setFormulaPatty(String raw) {
    formulaPattyText = _digits(raw);
    final n = int.tryParse(formulaPattyText) ?? 0;
    if (n > 0) {
      final trays = n * 12;
      final eggs = trays * 30;
      final dozens = eggs ~/ 12;
      formulaTrayText = '$trays';
      formulaDozenText = '$dozens';
      formulaSingleText = '$eggs';
    } else {
      formulaTrayText = formulaDozenText = formulaSingleText = '';
    }
    notifyListeners();
  }

  void setFormulaTray(String raw) {
    formulaTrayText = _digits(raw);
    final n = int.tryParse(formulaTrayText) ?? 0;
    if (n > 0) {
      final eggs = n * 30;
      final dozens = eggs ~/ 12;
      final patties = n ~/ 12;
      formulaPattyText = patties > 0 ? '$patties' : '';
      formulaDozenText = '$dozens';
      formulaSingleText = '$eggs';
    } else {
      formulaPattyText = formulaDozenText = formulaSingleText = '';
    }
    notifyListeners();
  }

  void setFormulaDozen(String raw) {
    formulaDozenText = _digits(raw);
    final n = int.tryParse(formulaDozenText) ?? 0;
    if (n > 0) {
      final eggs = n * 12;
      final trays = eggs ~/ 30;
      final patties = trays ~/ 12;
      formulaPattyText = patties > 0 ? '$patties' : '';
      formulaTrayText = trays > 0 ? '$trays' : '';
      formulaSingleText = '$eggs';
    } else {
      formulaPattyText = formulaTrayText = formulaSingleText = '';
    }
    notifyListeners();
  }

  void setFormulaSingle(String raw) {
    formulaSingleText = _digits(raw);
    final n = int.tryParse(formulaSingleText) ?? 0;
    if (n > 0) {
      final dozens = n ~/ 12;
      final trays = n ~/ 30;
      final patties = trays ~/ 12;
      formulaPattyText = patties > 0 ? '$patties' : '';
      formulaTrayText = trays > 0 ? '$trays' : '';
      formulaDozenText = dozens > 0 ? '$dozens' : '';
    } else {
      formulaPattyText = formulaTrayText = formulaDozenText = '';
    }
    notifyListeners();
  }

  // ── Submission ─────────────────────────────────────────────
  Future<bool> submitAddStock() async {
    final totalEggs = int.tryParse(formulaSingleText) ?? 0;
    if (totalEggs <= 0) return false;
    final ok = await _inventory.addStockEntry(totalEggs: totalEggs);
    if (ok) showList();
    return ok;
  }

  Future<bool> submitProduct() async {
    final price = double.tryParse(priceText);
    final revenuePerUnit = double.tryParse(revenuePerUnitText) ?? 0;
    final eggsPerUnit = int.tryParse(eggsPerUnitText) ?? 0;
    final editing = _editingProduct;
    if (editing == null || price == null) return false;

    final ok = await _inventory.updateProduct(
      id: editing.id,
      nameEn: nameEn.trim(),
      nameUr: nameUr.trim(),
      price: price,
      eggsPerUnit: eggsPerUnit,
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
    eggsPerUnitText = '';
    formulaPattyText = '';
    formulaTrayText = '';
    formulaDozenText = '';
    formulaSingleText = '';
  }
}
