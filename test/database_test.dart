import 'dart:io';

import 'package:expenzia/database/app_database.dart';
import 'package:expenzia/database/credit_database.dart';
import 'package:expenzia/database/expense_database.dart';
import 'package:expenzia/database/settings_database.dart';
import 'package:expenzia/models/credit.dart';
import 'package:expenzia/models/expense.dart';
import 'package:expenzia/repositories/credit_repository.dart';
import 'package:expenzia/repositories/expense_repository.dart';
import 'package:expenzia/repositories/profile_repository.dart';
import 'package:expenzia/repositories/repository_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory tempDir;
  late String dbPath;
  late AppDatabase database;
  late ExpenseRepository repository;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('expenzia_test');
    dbPath = p.join(tempDir.path, 'expenzia.db');
    database = AppDatabase(path: dbPath);
    repository = ExpenseRepository(ExpenseDatabase(database));
  });

  tearDown(() async {
    await database.close();
    await tempDir.delete(recursive: true);
  });

  final netflix = Expense(
    title: 'Netflix',
    amount: 48,
    category: ExpenseCategory.expense,
    date: DateTime(2026, 2, 22),
    description: 'Monthly plan',
  );

  test('creates, reads, updates and deletes an expense', () async {
    final saved = await repository.addExpense(netflix);
    expect(saved.id, isNotNull);

    var all = await repository.getExpenses();
    expect(all, hasLength(1));
    expect(all.first.title, 'Netflix');
    expect(all.first.amount, 48);
    expect(all.first.category, ExpenseCategory.expense);
    expect(all.first.date, DateTime(2026, 2, 22));
    expect(all.first.description, 'Monthly plan');

    await repository.updateExpense(
      saved.copyWith(
        title: 'Upwork',
        amount: 850,
        category: ExpenseCategory.income,
      ),
    );
    all = await repository.getExpenses();
    expect(all.single.title, 'Upwork');
    expect(all.single.amount, 850);
    expect(all.single.isIncome, isTrue);

    await repository.deleteExpense(saved.id!);
    expect(await repository.getExpenses(), isEmpty);
  });

  test('returns expenses newest first', () async {
    await repository.addExpense(
      netflix.copyWith(title: 'Old', date: DateTime(2022, 1, 16)),
    );
    await repository.addExpense(
      netflix.copyWith(title: 'New', date: DateTime(2026, 2, 22)),
    );
    final titles = (await repository.getExpenses()).map((e) => e.title);
    expect(titles, ['New', 'Old']);
  });

  test(
    'data is still there after the database is closed and reopened',
    () async {
      await repository.addExpense(netflix);
      await database.close();

      final reopened = AppDatabase(path: dbPath);
      final all = await ExpenseRepository(
        ExpenseDatabase(reopened),
      ).getExpenses();
      expect(all.single.title, 'Netflix');
      await reopened.close();
    },
  );

  test('database errors become RepositoryException', () async {
    // The table has CHECK (amount > 0), so this insert fails in SQLite.
    await expectLater(
      () => repository.addExpense(netflix.copyWith(amount: -1)),
      throwsA(isA<RepositoryException>()),
    );
    await expectLater(
      () => repository.updateExpense(netflix.copyWith(id: 999)),
      throwsA(isA<RepositoryException>()),
    );
  });

  test('credits and profile settings are stored', () async {
    final credits = CreditRepository(CreditDatabase(database));
    await credits.addCredit(
      Credit(
        creditType: 'Subscriptions',
        name: 'Netflix',
        amount: 850,
        dueDate: DateTime(2026, 2, 22),
        planType: PlanType.monthly,
      ),
    );
    expect((await credits.getCredits()).single.name, 'Netflix');

    final profile = ProfileRepository(SettingsDatabase(database));
    expect(await profile.getName(), ProfileRepository.defaultName);
    expect(await profile.isOnboardingDone(), isFalse);
    await profile.saveName('Asha');
    await profile.setOnboardingDone();
    expect(await profile.getName(), 'Asha');
    expect(await profile.isOnboardingDone(), isTrue);

    await profile.clear();
    expect(await profile.getName(), ProfileRepository.defaultName);
  });
}
