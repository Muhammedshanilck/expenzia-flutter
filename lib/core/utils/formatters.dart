import 'package:intl/intl.dart';

/// Indian Rupee and date formatting used across the app.
class Formatters {
  Formatters._();

  // Indian digit grouping: 1,00,000.00
  static final NumberFormat _rupee = NumberFormat('#,##,##0.00', 'en_IN');
  static final DateFormat _formDate = DateFormat('EEE, d MMM yyyy');
  static final DateFormat _listDate = DateFormat('MMM d, yyyy');
  static final DateFormat _dueDate = DateFormat('dd/MM/yy');

  /// 1406 -> "₹ 1,406.00"
  static String currency(double amount) => '₹ ${_rupee.format(amount)}';

  /// "+ ₹ 850.00" for income, "- ₹ 85.00" for expenses.
  static String signedCurrency(double amount, {required bool isIncome}) =>
      '${isIncome ? '+' : '-'} ${currency(amount)}';

  /// Plain number for the amount text field: 1406.5 -> "1406.50"
  static String amountInput(double amount) => amount.toStringAsFixed(2);

  /// "Tue, 22 Feb 2026"
  static String formDate(DateTime date) => _formDate.format(date);

  /// "Today", "Yesterday" or "Jan 30, 2022"
  static String relativeDate(DateTime date, {DateTime? now}) {
    final difference = _daysBetween(date, now ?? DateTime.now());
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    return _listDate.format(date);
  }

  /// True when [date] is today or already in the past.
  static bool isDueTodayOrOverdue(DateTime date, {DateTime? now}) =>
      _daysBetween(date, now ?? DateTime.now()) >= 0;

  /// "10/12/26"
  static String dueDate(DateTime date) => _dueDate.format(date);

  static int _daysBetween(DateTime date, DateTime now) {
    final a = DateTime(date.year, date.month, date.day);
    final b = DateTime(now.year, now.month, now.day);
    return b.difference(a).inDays;
  }

  /// "Good morning," / "Good afternoon," / "Good evening,"
  static String greeting({DateTime? now}) {
    final hour = (now ?? DateTime.now()).hour;
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
  }
}
