/// String constants used across the app. Centralised here so we can swap
/// to a localisation package later without touching the views.
class AppStrings {
  AppStrings._();

  // Branding
  static const String appName = 'Waqas Brothers';
  static const String appNameUrdu = 'وقاص برادرز';
  static const String tagline = 'EGGS MERCHANTS';

  // Tabs
  static const String dashboard = 'Dashboard';
  static const String order = 'Order';
  static const String history = 'History';
  static const String credit = 'Credit';
  static const String stock = 'Stock';

  // Urdu labels
  static const String urdCash = 'نقد فروخت';
  static const String urdCredit = 'ادھار';
  static const String urdStock = 'اسٹاک';
  static const String urdMonthly = 'ماہانہ';
  static const String urdPrinter = 'پرنٹر';
  static const String urdCheckout = 'چیک آؤٹ';
  static const String urdOutstanding = 'کل بقایا';
  static const String urdAddStock = 'اسٹاک شامل کریں';
  static const String urdEdit = 'ترمیم';
  static const String urdNewProduct = 'نئی مصنوع';

  // Misc
  static const String walkInCustomer = 'Walk-in';
  static const String currencySymbol = 'Rs.';
  static const String defaultDeviceId = 'SM-A546';
  static const String noInternetMessage = 'No internet connection';
  static const String noInternetSubtitle =
      'You are offline. Sales will sync once you reconnect.';
}
