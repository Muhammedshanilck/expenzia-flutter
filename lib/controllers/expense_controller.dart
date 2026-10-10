import 'package:flutter/foundation.dart';

import '../models/expense.dart';
import '../models/expense_summary.dart';
import '../repositories/expense_repository.dart';
import '../repositories/repository_exception.dart';

/// Holds the expense list for the UI and reloads it after every change,
/// so the lists and totals on every screen stay up to date.
class ExpenseController extends ChangeNotifier {
  ExpenseController(this._repository);

  final ExpenseRepository _repository;

  List<Expense> _expenses = [];
  ExpenseSummary _summary = ExpenseSummary.empty;
  bool _isLoading = false;
  String? _errorMessage;

  List<Expense> get expenses => List.unmodifiable(_expenses);
  ExpenseSummary get summary => _summary;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadExpenses() async {
    _isLoading = true;
    notifyListeners();
    try {
      _expenses = await _repository.getExpenses();
      _summary = ExpenseSummary.fromExpenses(_expenses);
      _errorMessage = null;
    } on RepositoryException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Throws [RepositoryException] so the screen can show the message.
  Future<void> addExpense(Expense expense) async {
    await _repository.addExpense(expense);
    await loadExpenses();
  }

  Future<void> updateExpense(Expense expense) async {
    await _repository.updateExpense(expense);
    await loadExpenses();
  }

  Future<void> deleteExpense(Expense expense) async {
    if (expense.id == null) return;
    await _repository.deleteExpense(expense.id!);
    await loadExpenses();
  }

  Future<void> deleteAll() async {
    await _repository.deleteAll();
    await loadExpenses();
  }
}
