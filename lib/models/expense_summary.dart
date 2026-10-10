import 'expense.dart';

/// Totals shown on the Home screen, calculated from the saved expenses.
class ExpenseSummary {
  final double totalIncome;
  final double totalExpense;

  /// Expenses of the last 30 days divided by 30.
  final double dailyAverage;

  /// Expenses of the last 7 days (today included).
  final double weekly;

  const ExpenseSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.dailyAverage,
    required this.weekly,
  });

  static const ExpenseSummary empty = ExpenseSummary(
    totalIncome: 0,
    totalExpense: 0,
    dailyAverage: 0,
    weekly: 0,
  );

  double get balance => totalIncome - totalExpense;

  factory ExpenseSummary.fromExpenses(List<Expense> expenses, {DateTime? now}) {
    final today = _startOfDay(now ?? DateTime.now());
    final weekStart = today.subtract(const Duration(days: 6));
    final monthStart = today.subtract(const Duration(days: 29));

    double income = 0;
    double expense = 0;
    double lastWeek = 0;
    double lastMonth = 0;

    for (final item in expenses) {
      if (item.isIncome) {
        income += item.amount;
        continue;
      }
      expense += item.amount;

      final day = _startOfDay(item.date);
      if (!day.isBefore(weekStart) && !day.isAfter(today)) {
        lastWeek += item.amount;
      }
      if (!day.isBefore(monthStart) && !day.isAfter(today)) {
        lastMonth += item.amount;
      }
    }

    return ExpenseSummary(
      totalIncome: income,
      totalExpense: expense,
      dailyAverage: lastMonth / 30,
      weekly: lastWeek,
    );
  }

  static DateTime _startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);
}
