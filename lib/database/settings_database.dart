import 'package:sqflite/sqflite.dart';

import 'app_database.dart';

/// Simple key/value storage for the profile name and the onboarding flag.
class SettingsDatabase {
  SettingsDatabase(this._appDatabase);

  final AppDatabase _appDatabase;
  static const String _table = AppDatabase.settingsTable;

  Future<String?> getValue(String key) async {
    final db = await _appDatabase.database;
    final rows = await db.query(
      _table,
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['value'] as String;
  }

  Future<void> setValue(String key, String value) async {
    final db = await _appDatabase.database;
    await db.insert(_table, {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> deleteAll() async {
    final db = await _appDatabase.database;
    await db.delete(_table);
  }
}
