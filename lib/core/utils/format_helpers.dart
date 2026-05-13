import 'package:intl/intl.dart';

import '../constants/app_strings.dart';

/// Number, date, and currency formatting helpers.
class FormatHelpers {
  FormatHelpers._();

  static final NumberFormat _money = NumberFormat('#,##0', 'en_US');

  /// Formats a value as `Rs. 1,234`.
  static String currency(num value) =>
      '${AppStrings.currencySymbol} ${_money.format(value)}';

  /// Formats a value with thousands separators.
  static String number(num value) => _money.format(value);

  /// Today's date as `yyyy-MM-dd` for grouping/lookup keys.
  static String todayKey() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  /// Any [date] as `yyyy-MM-dd`.
  static String dateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  /// Day of week only `Saturday`.
  static String dayOfWeek([DateTime? at]) =>
      DateFormat('EEEE').format(at ?? DateTime.now());

  /// Short date format `Apr 26, 2026`.
  static String headerDate([DateTime? at]) =>
      DateFormat('MMM d, yyyy').format(at ?? DateTime.now());

  /// Month label `April 2026`.
  static String monthLabel([DateTime? at]) =>
      DateFormat('MMMM yyyy').format(at ?? DateTime.now());

  /// Current time in `HH:mm`.
  static String timeNow() => DateFormat('HH:mm').format(DateTime.now());

  /// `Apr 26 · 3:05 PM`
  static String formatDateTime(DateTime dt) {
    final local = dt.toLocal();
    final h = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final mn = local.minute.toString().padLeft(2, '0');
    final ampm = local.hour < 12 ? 'AM' : 'PM';
    return '${DateFormat('MMM d').format(local)} · $h:$mn $ampm';
  }
}
