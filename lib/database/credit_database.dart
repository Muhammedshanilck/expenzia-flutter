import '../models/credit.dart';
import 'app_database.dart';

/// Queries for the `credits` table.
class CreditDatabase {
  CreditDatabase(this._appDatabase);

  final AppDatabase _appDatabase;
  static const String _table = AppDatabase.creditsTable;

  Future<int> insert(Credit credit) async {
    final db = await _appDatabase.database;
    return db.insert(_table, credit.toMap()..remove('id'));
  }

  /// Nearest due date first.
  Future<List<Credit>> getAll() async {
    final db = await _appDatabase.database;
    final rows = await db.query(_table, orderBy: 'due_date ASC, id ASC');
    return rows.map(Credit.fromMap).toList();
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
