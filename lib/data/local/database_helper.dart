import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _db;

  Database get database {
    if (_db == null) throw Exception('Database not initialized');
    return _db!;
  }

  Future<void> initialize() async {
    final path = join(await getDatabasesPath(), 'fitforge.db');
    _db = await openDatabase(
      path,
      version: 1,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE workout_plans (
        id          TEXT PRIMARY KEY,
        name        TEXT NOT NULL,
        day_of_week INTEGER NOT NULL,
        is_active   INTEGER NOT NULL DEFAULT 1,
        created_at  TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE exercises (
        id           TEXT PRIMARY KEY,
        plan_id      TEXT NOT NULL REFERENCES workout_plans(id) ON DELETE CASCADE,
        name         TEXT NOT NULL,
        muscle_group TEXT NOT NULL,
        description  TEXT,
        image_path   TEXT,
        youtube_url  TEXT,
        sort_order   INTEGER NOT NULL DEFAULT 0,
        created_at   TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE default_sets (
        id          TEXT PRIMARY KEY,
        exercise_id TEXT NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
        set_number  INTEGER NOT NULL,
        reps        INTEGER NOT NULL DEFAULT 10,
        weight      REAL NOT NULL DEFAULT 0,
        increment   REAL NOT NULL DEFAULT 2.5,
        UNIQUE(exercise_id, set_number)
      )
    ''');

    await db.execute('''
      CREATE TABLE workout_logs (
        id           TEXT PRIMARY KEY,
        exercise_id  TEXT NOT NULL REFERENCES exercises(id) ON DELETE RESTRICT,
        log_date     TEXT NOT NULL,
        notes        TEXT,
        total_volume REAL NOT NULL DEFAULT 0,
        created_at   TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE workout_sets (
        id             TEXT PRIMARY KEY,
        log_id         TEXT NOT NULL REFERENCES workout_logs(id) ON DELETE CASCADE,
        set_number     INTEGER NOT NULL,
        planned_reps   INTEGER NOT NULL,
        actual_reps    INTEGER NOT NULL,
        planned_weight REAL NOT NULL,
        actual_weight  REAL NOT NULL,
        is_completed   INTEGER NOT NULL DEFAULT 0,
        UNIQUE(log_id, set_number)
      )
    ''');

    await db.execute('''
      CREATE TABLE motivational_quotes (
        id         TEXT PRIMARY KEY,
        text       TEXT NOT NULL,
        is_active  INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');
    await _createIndexes(db);
  }

  Future<void> _createIndexes(Database db) async {
    await db.execute(
        'CREATE INDEX idx_logs_exercise  ON workout_logs(exercise_id)');
    await db.execute(
        'CREATE INDEX idx_logs_date      ON workout_logs(log_date DESC)');
    await db.execute('CREATE INDEX idx_sets_log       ON workout_sets(log_id)');
    await db.execute(
        'CREATE INDEX idx_exercises_plan ON exercises(plan_id, sort_order)');
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
