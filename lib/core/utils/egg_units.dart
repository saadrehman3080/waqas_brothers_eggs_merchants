import 'package:waqas_brothers_eggs_merchants/models/product.dart' show Product;

class EggUnits {
  EggUnits._();

  static const int traysPerPatty = 12;
  static const int eggsPerTray = 30;
  static const int eggsPerDozen = 12;

  // Derived
  static const int eggsPerPatty = traysPerPatty * eggsPerTray; // 360
  static const int dozensPerPatty = eggsPerPatty ~/ eggsPerDozen; // 30

  /// Convert [patties] to all units.
  static ({int trays, int dozens, int eggs}) fromPatties(int patties) {
    final trays = patties * traysPerPatty;
    final eggs = trays * eggsPerTray;
    final dozens = eggs ~/ eggsPerDozen;
    return (trays: trays, dozens: dozens, eggs: eggs);
  }

  static ({int? patties, int dozens, int eggs}) fromTrays(int trays) {
    final eggs = trays * eggsPerTray;
    final dozens = eggs ~/ eggsPerDozen;
    final p = trays ~/ traysPerPatty;
    return (patties: p > 0 ? p : null, dozens: dozens, eggs: eggs);
  }

  static ({int? patties, int? trays, int eggs}) fromDozens(int dozens) {
    final eggs = dozens * eggsPerDozen;
    final trays = eggs ~/ eggsPerTray;
    final p = trays ~/ traysPerPatty;
    return (
      patties: p > 0 ? p : null,
      trays: trays > 0 ? trays : null,
      eggs: eggs,
    );
  }

  static ({int? patties, int? trays, int? dozens}) fromEggs(int eggs) {
    final dozens = eggs ~/ eggsPerDozen;
    final trays = eggs ~/ eggsPerTray;
    final p = trays ~/ traysPerPatty;
    return (
      patties: p > 0 ? p : null,
      trays: trays > 0 ? trays : null,
      dozens: dozens > 0 ? dozens : null,
    );
  }

  static int eggsPerUnitForProduct(Product product) {
    return _defaultEggsPerUnit[product.id] ??
        _eggsPerUnitByName[product.nameEn] ??
        0;
  }

  static const Map<String, int> _defaultEggsPerUnit = {
    '1EbOjOKjYu8qUg56QXGd': 30,
    '2pZtQh92vB1mN4xFzLaK': 360,
    '3LfYnG8eRwUa5PvSxQzM': 12,
    '4MxFpJ7cTvRe6ZnUaHsB': 1,
  };

  static const Map<String, int> _eggsPerUnitByName = {
    'Egg Tray': 30,
    'Patty': 360,
    'Egg Dozen': 12,
    'Single Egg': 1,
  };
}
