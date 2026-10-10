// Renders every screen at the Figma frame size (414 x 896). A normal
// `flutter test` run only checks that each screen renders without errors.
// To regenerate the PNGs in screenshots/app/ run:
//   flutter test test/screenshots_test.dart --dart-define=UPDATE_SCREENSHOTS=true
//
// The rows inserted below are test fixtures that copy the Figma example
// content. The real app starts with an empty database.

import 'package:expenzia/database/app_database.dart';
import 'package:expenzia/models/credit.dart';
import 'package:expenzia/models/expense.dart';
import 'package:expenzia/screens/main_shell.dart';
import 'package:expenzia/screens/onboarding_screen.dart';
import 'package:expenzia/screens/splash_screen.dart';
import 'package:expenzia/screens/transaction_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'helpers.dart';

const _out = 'screenshots/app';

void main() {
  late TestApp app;

  setUpAll(() async {
    useFfiDatabase();
    await loadAppFonts();
  });

  setUp(() async {
    final database = AppDatabase(path: inMemoryDatabasePath);
    app = TestApp(database);
  });

  tearDown(() => app.database.close());

  Future<void> seed(WidgetTester tester) async {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    await tester.runAsync(() async {
      for (final e in [
        Expense(
          title: 'Youtube',
          amount: 11.99,
          category: ExpenseCategory.expense,
          date: DateTime(2022, 1, 16),
        ),
        Expense(
          title: 'Paypal',
          amount: 1406,
          category: ExpenseCategory.income,
          date: DateTime(2022, 1, 30),
        ),
        Expense(
          title: 'Transfer',
          amount: 85,
          category: ExpenseCategory.expense,
          date: yesterday,
        ),
        Expense(
          title: 'Upwork',
          amount: 850,
          category: ExpenseCategory.income,
          date: today,
        ),
      ]) {
        await app.expenses.addExpense(e);
      }
      for (final c in [
        Credit(
          creditType: 'Subscriptions',
          name: 'Netflix',
          amount: 850,
          dueDate: today,
          planType: PlanType.monthly,
        ),
        Credit(
          creditType: 'Personal Loan',
          name: 'Rohith',
          amount: 18500,
          dueDate: DateTime(2026, 12, 10),
          planType: PlanType.oneTime,
        ),
        Credit(
          creditType: 'Bills',
          name: 'Electricity Bill',
          amount: 850,
          dueDate: DateTime(2026, 11, 5),
          planType: PlanType.monthly,
        ),
        Credit(
          creditType: 'Insurance',
          name: 'Health Insurance',
          amount: 21000,
          dueDate: DateTime(2027, 1, 1),
          planType: PlanType.yearly,
        ),
      ]) {
        await app.credits.addCredit(c);
      }
      await app.loadAll();
    });
  }

  Future<void> show(WidgetTester tester, Widget home) async {
    usePhoneSize(tester);
    await seed(tester);
    await tester.pumpWidget(app.build(home));
    await settle(tester);
  }

  testWidgets('01 splash', (tester) async {
    await show(tester, const SplashScreen(minimumDuration: Duration(days: 1)));
    await saveScreenshot(tester, app, '$_out/01_splash.png');
    // Let the splash timer finish so no timer is left pending.
    await tester.pump(const Duration(days: 1));
    await settle(tester);
  });

  testWidgets('02 onboarding', (tester) async {
    await show(tester, const OnboardingScreen());
    await saveScreenshot(tester, app, '$_out/02_onboarding.png');
  });

  testWidgets('03 home', (tester) async {
    await show(tester, const MainShell());
    await saveScreenshot(tester, app, '$_out/03_home.png');
  });

  testWidgets('04 transaction (add)', (tester) async {
    await show(tester, const TransactionFormScreen());
    await tester.enterText(find.byType(TextFormField).at(0), 'Netflix');
    await tester.enterText(find.byType(TextFormField).at(1), '48.00');
    FocusManager.instance.primaryFocus?.unfocus();
    await settle(tester);
    await saveScreenshot(tester, app, '$_out/04_transaction.png');
  });

  testWidgets('05 transaction history (row actions open)', (tester) async {
    await show(tester, const MainShell(initialIndex: 1));
    await tester.tap(find.text('Upwork'));
    await settle(tester);
    await saveScreenshot(tester, app, '$_out/05_history.png');
  });

  testWidgets('06 edit transaction', (tester) async {
    await show(tester, const SizedBox());
    final upwork = app.expenses.expenses.firstWhere((e) => e.title == 'Upwork');
    await tester.pumpWidget(app.build(TransactionFormScreen(expense: upwork)));
    await settle(tester);
    await saveScreenshot(tester, app, '$_out/06_edit_transaction.png');
  });

  testWidgets('07 credit', (tester) async {
    await show(tester, const MainShell(initialIndex: 2));
    await tester.enterText(find.byType(TextFormField).at(0), 'Netflix');
    FocusManager.instance.primaryFocus?.unfocus();
    await settle(tester);
    await saveScreenshot(tester, app, '$_out/07_credit.png');
  });

  testWidgets('08 profile', (tester) async {
    await show(tester, const MainShell(initialIndex: 3));
    await saveScreenshot(tester, app, '$_out/08_profile.png');
  });
}
