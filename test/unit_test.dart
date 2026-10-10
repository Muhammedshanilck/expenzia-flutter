import 'package:expenzia/core/utils/formatters.dart';
import 'package:expenzia/core/utils/validators.dart';
import 'package:expenzia/models/expense.dart';
import 'package:expenzia/models/expense_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Formatters', () {
    test('formats rupees with Indian digit grouping', () {
      expect(Formatters.currency(850), '₹ 850.00');
      expect(Formatters.currency(1406), '₹ 1,406.00');
      expect(Formatters.currency(18500), '₹ 18,500.00');
      expect(Formatters.currency(100000), '₹ 1,00,000.00');
      expect(Formatters.currency(12345678.9), '₹ 1,23,45,678.90');
    });

    test('adds + for income and - for expenses', () {
      expect(Formatters.signedCurrency(850, isIncome: true), '+ ₹ 850.00');
      expect(Formatters.signedCurrency(11.99, isIncome: false), '- ₹ 11.99');
    });

    test('shows Today / Yesterday / full date', () {
      final now = DateTime(2026, 2, 22, 15);
      expect(Formatters.relativeDate(DateTime(2026, 2, 22), now: now), 'Today');
      expect(
        Formatters.relativeDate(DateTime(2026, 2, 21), now: now),
        'Yesterday',
      );
      expect(
        Formatters.relativeDate(DateTime(2022, 1, 30), now: now),
        'Jan 30, 2022',
      );
    });

    test('formats the form date like the design', () {
      expect(Formatters.formDate(DateTime(2026, 2, 22)), 'Sun, 22 Feb 2026');
      expect(Formatters.dueDate(DateTime(2026, 12, 10)), '10/12/26');
    });
  });

  group('Validators', () {
    test('requires a name', () {
      expect(Validators.requiredText('', field: 'Name'), 'Name is required');
      expect(Validators.requiredText('   ', field: 'Name'), 'Name is required');
      expect(Validators.requiredText('Netflix', field: 'Name'), isNull);
    });

    test('accepts only positive amounts with up to two decimals', () {
      expect(Validators.amount(''), 'Amount is required');
      expect(Validators.amount('abc'), isNotNull);
      expect(Validators.amount('-5'), isNotNull);
      expect(Validators.amount('0'), 'Amount must be greater than zero');
      expect(Validators.amount('0.00'), 'Amount must be greater than zero');
      expect(Validators.amount('12.345'), isNotNull);
      expect(Validators.amount('1.2.3'), isNotNull);
      expect(Validators.amount('99999999'), 'Amount is too large');
      expect(Validators.amount('48'), isNull);
      expect(Validators.amount('48.5'), isNull);
      expect(Validators.amount('1,406.00'), isNull);
      expect(Validators.parseAmount('1,406.00'), 1406.0);
    });
  });

  group('ExpenseSummary', () {
    final now = DateTime(2026, 2, 22, 12);
    Expense item(double amount, String category, DateTime date) =>
        Expense(title: 't', amount: amount, category: category, date: date);

    test('calculates income, expenses, balance, weekly and daily average', () {
      final summary = ExpenseSummary.fromExpenses([
        item(1000, ExpenseCategory.income, DateTime(2026, 2, 22)),
        item(70, ExpenseCategory.expense, DateTime(2026, 2, 22)),
        item(140, ExpenseCategory.expense, DateTime(2026, 2, 16)), // 6 days ago
        item(90, ExpenseCategory.expense, DateTime(2026, 2, 15)), // 7 days ago
        item(500, ExpenseCategory.expense, DateTime(2025, 1, 1)), // old
      ], now: now);

      expect(summary.totalIncome, 1000);
      expect(summary.totalExpense, 800);
      expect(summary.balance, 200);
      expect(summary.weekly, 210);
      expect(summary.dailyAverage, closeTo(300 / 30, 0.0001));
    });

    test('is all zero without expenses', () {
      final summary = ExpenseSummary.fromExpenses([], now: now);
      expect(summary.balance, 0);
      expect(summary.weekly, 0);
    });
  });
}
