import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Opens the SQLite database and creates the tables on first launch.
class AppDatabase {
  AppDatabase({String? path}) : _path = path;

  static const String fileName = 'expenzia.db';
  static const int version = 1;

  static const String expensesTable = 'expenses';
  static const String creditsTable = 'credits';
  static const String settingsTable = 'settings';

  /// Custom path, used by tests (for example an in-memory database).
  final String? _path;
  Database? _database;

  Future<Database> get database async {
    return _database ??= await _open();
  }

  Future<Database> _open() async {
    final path = _path ?? join(await getDatabasesPath(), fileName);
    return openDatabase(path, version: version, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $expensesTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL CHECK (amount > 0),
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        description TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE $creditsTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        credit_type TEXT NOT NULL,
        name TEXT NOT NULL,
        amount REAL NOT NULL CHECK (amount > 0),
        due_date TEXT NOT NULL,
        plan_type TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE $settingsTable (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
