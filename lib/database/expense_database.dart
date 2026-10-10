import '../models/expense.dart';
import 'app_database.dart';

/// Create, read, update and delete queries for the `expenses` table.
class ExpenseDatabase {
  ExpenseDatabase(this._appDatabase);

  final AppDatabase _appDatabase;
  static const String _table = AppDatabase.expensesTable;

  Future<int> insert(Expense expense) async {
    final db = await _appDatabase.database;
    final values = expense.toMap()..remove('id');
    return db.insert(_table, values);
  }

  /// Newest first.
  Future<List<Expense>> getAll() async {
    final db = await _appDatabase.database;
    final rows = await db.query(_table, orderBy: 'date DESC, id DESC');
    return rows.map(Expense.fromMap).toList();
  }

  /// Returns the number of updated rows (0 if the expense no longer exists).
  Future<int> update(Expense expense) async {
    final db = await _appDatabase.database;
    return db.update(
      _table,
      expense.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _appDatabase.database;
    return db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAll() async {
    final db = await _appDatabase.database;
    await db.delete(_table);
  }
}
