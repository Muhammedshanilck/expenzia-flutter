import '../database/expense_database.dart';
import '../models/expense.dart';
import 'repository_exception.dart';

/// The only class the UI uses to read and change expenses.
/// It hides SQLite details and converts database errors to readable messages.
class ExpenseRepository {
  ExpenseRepository(this._database);

  final ExpenseDatabase _database;

  Future<List<Expense>> getExpenses() async {
    try {
      return await _database.getAll();
    } catch (e) {
      throw RepositoryException('Could not load your transactions.', e);
    }
  }

  Future<Expense> addExpense(Expense expense) async {
    try {
      final id = await _database.insert(expense);
      return expense.copyWith(id: id);
    } catch (e) {
      throw RepositoryException('Could not save the transaction.', e);
    }
  }

  Future<void> updateExpense(Expense expense) async {
    if (expense.id == null) {
      throw RepositoryException('This transaction has not been saved yet.');
    }
    final int updated;
    try {
      updated = await _database.update(expense);
    } catch (e) {
      throw RepositoryException('Could not update the transaction.', e);
    }
    if (updated == 0) {
      throw RepositoryException('This transaction no longer exists.');
    }
  }

  Future<void> deleteExpense(int id) async {
    try {
      await _database.delete(id);
    } catch (e) {
      throw RepositoryException('Could not delete the transaction.', e);
    }
  }

  Future<void> deleteAll() async {
    try {
      await _database.deleteAll();
    } catch (e) {
      throw RepositoryException('Could not clear your transactions.', e);
    }
  }
}
