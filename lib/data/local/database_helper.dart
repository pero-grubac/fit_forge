import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static const version = 3;

  Database? _db;
  String? _path;
  DatabaseFactory? _factory;

  /// Image files of exercises merged away during migration. Deleted only
  /// after the migration has committed.
  final _orphanedImages = <String>[];

  Database get database {
    if (_db == null) throw Exception('Database not initialized');
    return _db!;
  }

  /// [path] and [factory] can be overridden in tests.
  Future<void> initialize({String? path, DatabaseFactory? factory}) async {
    final dbFactory = factory ?? databaseFactory;
    final dbPath =
        path ?? join(await dbFactory.getDatabasesPath(), 'fitforge.db');
    _path = dbPath;
    _factory = dbFactory;
    _db = await dbFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: version,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        // Foreign keys are enabled only after create/upgrade: table rebuilds
        // during migration must not trigger cascades on the old tables.
        onOpen: (db) => db.execute('PRAGMA foreign_keys = ON'),
      ),
    );
    await _deleteOrphanedImages();
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
          "ALTER TABLE exercises ADD COLUMN exercise_type TEXT NOT NULL DEFAULT 'weighted'");
    }
    if (oldVersion < 3) {
      await _migrateToV3(db);
    }
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

    await _createExercisesTable(db, 'exercises');
    await _createPlanExercisesTable(db);
    await _createDefaultSetsTable(db, 'default_sets');

    await db.execute('''
      CREATE TABLE workout_logs (
        id               TEXT PRIMARY KEY,
        exercise_id      TEXT NOT NULL REFERENCES exercises(id) ON DELETE RESTRICT,
        log_date         TEXT NOT NULL,
        notes            TEXT,
        total_volume     REAL NOT NULL DEFAULT 0,
        created_at       TEXT NOT NULL,
        plan_exercise_id TEXT REFERENCES plan_exercises(id) ON DELETE SET NULL
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

    await db.execute(
        'CREATE INDEX idx_logs_exercise  ON workout_logs(exercise_id)');
    await db.execute(
        'CREATE INDEX idx_logs_date      ON workout_logs(log_date DESC)');
    await db.execute('CREATE INDEX idx_sets_log       ON workout_sets(log_id)');
    await _createV3Indexes(db);
  }

  /// Exercises become a global catalogue shared by all plans. Plan-specific
  /// data (sort order, default sets) moves to `plan_exercises`.
  ///
  /// Old exercise rows with the same name (case-insensitive, trimmed) are
  /// merged into the oldest one. Each old row becomes a `plan_exercises` row
  /// with the same id, so default sets and logs keep pointing at it.
  Future<void> _migrateToV3(Database db) async {
    final rows = await db.query('exercises', orderBy: 'created_at ASC, id ASC');

    final canonicalByName = <String, Map<String, Object?>>{};
    // old exercise id -> id of the plan_exercises row it maps to
    final planExerciseIdOf = <String, String>{};
    final planExercises = <Map<String, Object?>>[];
    final slotByPlanAndExercise = <String, String>{};

    for (final row in rows) {
      final id = row['id'] as String;
      final key = (row['name'] as String).trim().toLowerCase();

      var canonical = canonicalByName[key];
      if (canonical == null) {
        canonical = Map.of(row)..['name'] = (row['name'] as String).trim();
        canonicalByName[key] = canonical;
      } else {
        for (final field in ['description', 'youtube_url', 'image_path']) {
          canonical[field] ??= row[field];
        }
        final image = row['image_path'] as String?;
        if (image != null && image != canonical['image_path']) {
          _orphanedImages.add(image);
        }
      }

      // The same exercise twice in one plan collapses into one slot.
      final slotKey = '${row['plan_id']}|${canonical['id']}';
      final existingSlot = slotByPlanAndExercise[slotKey];
      if (existingSlot != null) {
        planExerciseIdOf[id] = existingSlot;
        continue;
      }
      slotByPlanAndExercise[slotKey] = id;
      planExerciseIdOf[id] = id;
      planExercises.add({
        'id': id,
        'plan_id': row['plan_id'],
        'exercise_id': canonical['id'],
        'sort_order': row['sort_order'],
      });
    }

    await _createExercisesTable(db, 'exercises_new');
    for (final c in canonicalByName.values) {
      await db.insert('exercises_new', {
        'id': c['id'],
        'name': c['name'],
        'muscle_group': c['muscle_group'],
        'exercise_type': c['exercise_type'],
        'description': c['description'],
        'image_path': c['image_path'],
        'youtube_url': c['youtube_url'],
        'created_at': c['created_at'],
      });
    }

    await _createPlanExercisesTable(db);
    for (final pe in planExercises) {
      await db.insert('plan_exercises', pe);
    }

    await _createDefaultSetsTable(db, 'default_sets_new');
    await db.execute('''
      INSERT INTO default_sets_new
        (id, plan_exercise_id, set_number, reps, weight, increment)
      SELECT id, exercise_id, set_number, reps, weight, increment
      FROM default_sets
      WHERE exercise_id IN (SELECT id FROM plan_exercises)
    ''');

    await db.execute('ALTER TABLE workout_logs ADD COLUMN plan_exercise_id '
        'TEXT REFERENCES plan_exercises(id) ON DELETE SET NULL');
    // Link logs to their slot first, while exercise_id still holds old ids,
    // then point exercise_id at the merged exercise.
    for (final entry in planExerciseIdOf.entries) {
      await db.update(
        'workout_logs',
        {'plan_exercise_id': entry.value},
        where: 'exercise_id = ?',
        whereArgs: [entry.key],
      );
    }
    await db.execute('''
      UPDATE workout_logs
      SET exercise_id = (
        SELECT exercise_id FROM plan_exercises
        WHERE plan_exercises.id = workout_logs.plan_exercise_id
      )
      WHERE plan_exercise_id IS NOT NULL
    ''');

    await db.execute('DROP TABLE default_sets');
    await db.execute('DROP TABLE exercises');
    await db.execute('ALTER TABLE exercises_new RENAME TO exercises');
    await db.execute('ALTER TABLE default_sets_new RENAME TO default_sets');
    await _createV3Indexes(db);

    final violations = await db.rawQuery('PRAGMA foreign_key_check');
    if (violations.isNotEmpty) {
      _orphanedImages.clear();
      throw StateError('Migration to v3 left broken references: $violations');
    }
  }

  Future<void> _createExercisesTable(Database db, String name) => db.execute('''
        CREATE TABLE $name (
          id            TEXT PRIMARY KEY,
          name          TEXT NOT NULL UNIQUE COLLATE NOCASE,
          muscle_group  TEXT NOT NULL,
          exercise_type TEXT NOT NULL DEFAULT 'weighted',
          description   TEXT,
          image_path    TEXT,
          youtube_url   TEXT,
          created_at    TEXT NOT NULL
        )
      ''');

  Future<void> _createPlanExercisesTable(Database db) => db.execute('''
        CREATE TABLE plan_exercises (
          id          TEXT PRIMARY KEY,
          plan_id     TEXT NOT NULL REFERENCES workout_plans(id) ON DELETE CASCADE,
          exercise_id TEXT NOT NULL REFERENCES exercises(id) ON DELETE RESTRICT,
          sort_order  INTEGER NOT NULL DEFAULT 0,
          UNIQUE(plan_id, exercise_id)
        )
      ''');

  Future<void> _createDefaultSetsTable(Database db, String name) =>
      db.execute('''
        CREATE TABLE $name (
          id               TEXT PRIMARY KEY,
          plan_exercise_id TEXT NOT NULL REFERENCES plan_exercises(id) ON DELETE CASCADE,
          set_number       INTEGER NOT NULL,
          reps             INTEGER NOT NULL DEFAULT 10,
          weight           REAL NOT NULL DEFAULT 0,
          increment        REAL NOT NULL DEFAULT 2.5,
          UNIQUE(plan_exercise_id, set_number)
        )
      ''');

  Future<void> _createV3Indexes(Database db) async {
    await db.execute('CREATE INDEX idx_plan_exercises_plan '
        'ON plan_exercises(plan_id, sort_order)');
    await db.execute('CREATE INDEX idx_plan_exercises_exercise '
        'ON plan_exercises(exercise_id)');
    await db.execute('CREATE INDEX idx_logs_plan_exercise '
        'ON workout_logs(plan_exercise_id, log_date)');
  }

  Future<void> _deleteOrphanedImages() async {
    for (final path in _orphanedImages) {
      try {
        final file = File(path);
        if (await file.exists()) await file.delete();
      } catch (_) {
        // A leftover image file is harmless.
      }
    }
    _orphanedImages.clear();
  }

  /// Deletes the database file and creates an empty database in its place.
  Future<void> recreate() async {
    final path = _path;
    final factory = _factory;
    if (path == null || factory == null) {
      throw StateError('Database not initialized');
    }
    await close();
    await factory.deleteDatabase(path);
    await initialize(path: path, factory: factory);
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
