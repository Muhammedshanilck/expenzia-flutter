// End-to-end flow on a real SQLite file: add, validate, edit, delete,
// totals refresh, and data still present after an app "restart".

import 'dart:io';

import 'package:expenzia/database/app_database.dart';
import 'package:expenzia/screens/main_shell.dart';
import 'package:expenzia/screens/splash_screen.dart';
import 'package:expenzia/widgets/swipeable_transaction_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'helpers.dart';

void main() {
  late Directory tempDir;
  late String dbPath;

  setUpAll(() async {
    useFfiDatabase();
    await loadAppFonts();
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('expenzia_flow');
    dbPath = p.join(tempDir.path, 'expenzia.db');
  });

  tearDown(() async {
    try {
      await tempDir.delete(recursive: true);
    } on FileSystemException {
      // The database file may still be open if a test failed early.
    }
  });

  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await settle(tester);
  }

  /// The edit/delete button inside the row that shows [title].
  Finder rowAction(String title, String tooltip) => find.descendant(
    of: find.ancestor(
      of: find.text(title),
      matching: find.byType(SwipeableTransactionRow),
    ),
    matching: find.byTooltip(tooltip),
  );

  Future<void> fillForm(
    WidgetTester tester, {
    required String name,
    required String amount,
  }) async {
    await tester.enterText(find.byType(TextFormField).at(0), name);
    await tester.enterText(find.byType(TextFormField).at(1), amount);
    await tester.pump();
  }

  testWidgets('add, validate, edit and delete expenses with live totals', (
    tester,
  ) async {
    usePhoneSize(tester);
    final app = TestApp(AppDatabase(path: dbPath));

    // First launch: splash -> onboarding -> home.
    await tester.pumpWidget(
      app.build(
        const SplashScreen(minimumDuration: Duration(milliseconds: 10)),
      ),
    );
    await settle(tester);
    expect(find.text('Get Started'), findsOneWidget);
    await tapAndSettle(tester, find.text('Get Started'));

    // Empty state on Home.
    expect(find.text('No transactions yet'), findsOneWidget);
    expect(find.text('₹ 0.00'), findsWidgets);

    // Open the add form and try to save it empty.
    await tapAndSettle(tester, find.bySemanticsLabel('Add transaction'));
    expect(find.text('Transaction'), findsOneWidget);
    await tapAndSettle(tester, find.text('Save'));
    expect(find.text('Name is required'), findsOneWidget);
    expect(find.text('Amount is required'), findsOneWidget);

    // Invalid amounts are rejected.
    await fillForm(tester, name: 'Netflix', amount: '0');
    await tapAndSettle(tester, find.text('Save'));
    expect(find.text('Amount must be greater than zero'), findsOneWidget);
    await fillForm(tester, name: 'Netflix', amount: '12.345');
    await tapAndSettle(tester, find.text('Save'));
    expect(find.text('Enter a valid number, e.g. 250.50'), findsOneWidget);
    expect(app.expenses.expenses, isEmpty);

    // Valid expense is saved and Home updates.
    await fillForm(tester, name: 'Netflix', amount: '48');
    await tapAndSettle(tester, find.text('Save'));
    expect(find.text('Netflix'), findsOneWidget);
    // The row and the (negative) total balance.
    expect(find.text('- ₹ 48.00'), findsNWidgets(2));

    // Add an income through the Transaction Type dropdown.
    await tapAndSettle(tester, find.bySemanticsLabel('Add transaction'));
    await tapAndSettle(tester, find.text('Expense'));
    await tapAndSettle(tester, find.text('Income').last);
    await fillForm(tester, name: 'Upwork', amount: '850');
    await tapAndSettle(tester, find.text('Save'));
    expect(find.text('+ ₹ 850.00'), findsOneWidget);
    expect(find.text('₹ 802.00'), findsOneWidget); // balance 850 - 48
    expect(find.text('₹ 850.00'), findsOneWidget); // income
    expect(find.text('₹ 48.00'), findsNWidgets(2)); // expenses and weekly
    expect(find.text('₹ 1.60'), findsOneWidget); // daily average: 48 / 30

    // Edit Netflix from the history screen.
    await tapAndSettle(tester, find.bySemanticsLabel('Transaction history'));
    await tapAndSettle(tester, find.text('Netflix'));
    await tapAndSettle(tester, rowAction('Netflix', 'Edit'));
    expect(find.text('Edit Transaction'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Netflix'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(1), '100');
    await tapAndSettle(tester, find.text('Save'));
    expect(find.text('- ₹ 100.00'), findsOneWidget);
    expect(find.text('Transaction updated'), findsOneWidget);

    // Delete: cancel first, then confirm.
    await tapAndSettle(tester, find.text('Netflix'));
    await tapAndSettle(tester, rowAction('Netflix', 'Delete'));
    expect(find.text('Delete transaction?'), findsOneWidget);
    await tapAndSettle(tester, find.text('Cancel'));
    expect(find.text('Netflix'), findsOneWidget);

    // The row closes after an action, so open it again.
    await tapAndSettle(tester, find.text('Netflix'));
    await tapAndSettle(tester, rowAction('Netflix', 'Delete'));
    await tapAndSettle(tester, find.widgetWithText(TextButton, 'Delete'));
    expect(find.text('Netflix'), findsNothing);
    expect(app.expenses.expenses.map((e) => e.title), ['Upwork']);

    // Home totals follow the delete.
    await tapAndSettle(tester, find.bySemanticsLabel('Home'));
    expect(find.text('₹ 850.00'), findsNWidgets(2)); // balance and income
    expect(find.text('₹ 0.00'), findsWidgets); // expenses, daily, weekly

    await tester.runAsync(app.database.close);

    // "Restart": new controllers on the same database file.
    final restarted = TestApp(AppDatabase(path: dbPath));
    await tester.pumpWidget(
      restarted.build(
        const SplashScreen(minimumDuration: Duration(milliseconds: 10)),
      ),
    );
    await settle(tester);
    // Onboarding was completed before, so the app opens on Home.
    expect(find.byType(MainShell), findsOneWidget);
    expect(find.text('Upwork'), findsOneWidget);
    expect(find.text('+ ₹ 850.00'), findsOneWidget);
    await tester.runAsync(restarted.database.close);
  });

  testWidgets('credit form saves to the list and profile can clear storage', (
    tester,
  ) async {
    usePhoneSize(tester);
    final app = TestApp(AppDatabase(path: dbPath));
    await tester.runAsync(app.loadAll);
    await tester.pumpWidget(app.build(const MainShell(initialIndex: 2)));
    await settle(tester);

    expect(find.text('Nothing saved yet'), findsOneWidget);
    await tester.tap(find.text('Save'));
    await settle(tester);
    expect(find.text('Name is required'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'Netflix');
    await tester.enterText(find.byType(TextFormField).at(1), '850');
    await tester.tap(find.text('Save'));
    await settle(tester);
    expect(find.text('Netflix'), findsOneWidget);
    expect(find.text('₹ 850.00'), findsOneWidget);
    expect(app.credits.credits, hasLength(1));

    // Profile -> Clear Storage removes everything after confirmation.
    await tester.tap(find.bySemanticsLabel('Profile'));
    await settle(tester);
    await tester.tap(find.text('Clear Storage'));
    await settle(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Clear'));
    await settle(tester);
    expect(find.text('All data cleared'), findsOneWidget);
    expect(app.credits.credits, isEmpty);
    expect(app.expenses.expenses, isEmpty);
    await tester.runAsync(app.database.close);
  });
}
