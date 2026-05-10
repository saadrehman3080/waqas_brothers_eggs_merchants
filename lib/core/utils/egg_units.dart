/// Egg unit conversion constants.
///
/// 1 patty = 24 trays
/// 1 tray  = 24 eggs
/// 1 dozen = 12 eggs
///
/// Derived:
///   1 patty = 576 eggs = 48 dozen = 24 trays
///   1 tray  = 24 eggs  = 2 dozen
class EggUnits {
  EggUnits._();

  static const int traysPerPatty = 24;
  static const int eggsPerTray = 24;
  static const int eggsPerDozen = 12;

  // Derived
  static const int eggsPerPatty = traysPerPatty * eggsPerTray; // 576
  static const int dozensPerPatty = eggsPerPatty ~/ eggsPerDozen; // 48
  static const int dozensPerTray = eggsPerTray ~/ eggsPerDozen; // 2

  /// Convert [patties] to all units. Returns null fields when result < 1.
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
}
