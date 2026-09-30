import 'dart:io';

import 'package:fit_forge/data/local/database_helper.dart';
import 'package:fit_forge/data/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

int _firstInt(List<Map<String, Object?>> rows) =>
    rows.first.values.first as int;

/// Schema as shipped in v1.2.0 (database version 2).
Future<void> _createV2(Database db, int version) async {
  await db.execute('''
    CREATE TABLE workout_plans (
      id TEXT PRIMARY KEY, name TEXT NOT NULL, day_of_week INTEGER NOT NULL,
      is_active INTEGER NOT NULL DEFAULT 1, created_at TEXT NOT NULL)''');
  await db.execute('''
    CREATE TABLE exercises (
      id TEXT PRIMARY KEY,
      plan_id TEXT NOT NULL REFERENCES workout_plans(id) ON DELETE CASCADE,
      name TEXT NOT NULL, muscle_group TEXT NOT NULL,
      exercise_type TEXT NOT NULL DEFAULT 'weighted',
      description TEXT, image_path TEXT, youtube_url TEXT,
      sort_order INTEGER NOT NULL DEFAULT 0, created_at TEXT NOT NULL)''');
  await db.execute('''
    CREATE TABLE default_sets (
      id TEXT PRIMARY KEY,
      exercise_id TEXT NOT NULL REFERENCES exercises(id) ON DELETE CASCADE,
      set_number INTEGER NOT NULL, reps INTEGER NOT NULL DEFAULT 10,
      weight REAL NOT NULL DEFAULT 0, increment REAL NOT NULL DEFAULT 2.5,
      UNIQUE(exercise_id, set_number))''');
  await db.execute('''
    CREATE TABLE workout_logs (
      id TEXT PRIMARY KEY,
      exercise_id TEXT NOT NULL REFERENCES exercises(id) ON DELETE RESTRICT,
      log_date TEXT NOT NULL, notes TEXT,
      total_volume REAL NOT NULL DEFAULT 0, created_at TEXT NOT NULL)''');
  await db.execute('''
    CREATE TABLE workout_sets (
      id TEXT PRIMARY KEY,
      log_id TEXT NOT NULL REFERENCES workout_logs(id) ON DELETE CASCADE,
      set_number INTEGER NOT NULL, planned_reps INTEGER NOT NULL,
      actual_reps INTEGER NOT NULL, planned_weight REAL NOT NULL,
      actual_weight REAL NOT NULL, is_completed INTEGER NOT NULL DEFAULT 0,
      UNIQUE(log_id, set_number))''');
  await db.execute('''
    CREATE TABLE motivational_quotes (
      id TEXT PRIMARY KEY, text TEXT NOT NULL,
      is_active INTEGER NOT NULL DEFAULT 1, created_at TEXT NOT NULL)''');
  await db
      .execute('CREATE INDEX idx_logs_exercise ON workout_logs(exercise_id)');
  await db.execute('CREATE INDEX idx_logs_date ON workout_logs(log_date DESC)');
  await db.execute('CREATE INDEX idx_sets_log ON workout_sets(log_id)');
  await db.execute(
      'CREATE INDEX idx_exercises_plan ON exercises(plan_id, sort_order)');
}

Future<void> _seedV2(Database db, {required String imageDir}) async {
  Future<void> plan(String id, int day) => db.insert('workout_plans', {
        'id': id,
        'name': 'Plan $id',
        'day_of_week': day,
        'created_at': '2026-01-01',
      });
  Future<void> exercise(String id, String plan, String name, String created,
          {String? description, String? image}) =>
      db.insert('exercises', {
        'id': id,
        'plan_id': plan,
        'name': name,
        'muscle_group': 'Chest',
        'description': description,
        'image_path': image,
        'created_at': created,
      });
  Future<void> defaultSet(String exercise, double weight) =>
      db.insert('default_sets', {
        'id': 'ds_$exercise',
        'exercise_id': exercise,
        'set_number': 1,
        'reps': 5,
        'weight': weight,
        'increment': 2.5,
      });
  Future<void> log(String id, String exercise, String date) async {
    await db.insert('workout_logs', {
      'id': id,
      'exercise_id': exercise,
      'log_date': date,
      'total_volume': 0,
      'created_at': date,
    });
    await db.insert('workout_sets', {
      'id': 's_$id',
      'log_id': id,
      'set_number': 1,
      'planned_reps': 5,
      'actual_reps': 5,
      'planned_weight': 100,
      'actual_weight': 100,
      'is_completed': 1,
    });
  }

  await plan('mon', 1);
  await plan('thu', 4);
  // Same exercise in two plans, different casing/whitespace.
  await exercise('bench_mon', 'mon', 'Bench Press', '2026-01-01');
  await exercise('bench_thu', 'thu', 'bench press ', '2026-02-01',
      description: 'Keep your back flat', image: '$imageDir/adopted.jpg');
  await exercise('squat_mon', 'mon', 'Squat', '2026-01-02');
  // Same exercise twice in one plan.
  await exercise('bench_mon_2', 'mon', 'BENCH PRESS', '2026-03-01',
      image: '$imageDir/orphan.jpg');
  await defaultSet('bench_mon', 100);
  await defaultSet('bench_thu', 80);
  await defaultSet('squat_mon', 120);
  await defaultSet('bench_mon_2', 60);
  await log('l1', 'bench_mon', '2026-03-02');
  await log('l2', 'bench_thu', '2026-03-05');
  await log('l3', 'bench_mon_2', '2026-03-09');
  await log('l4', 'squat_mon', '2026-03-09');
}

void main() {
  sqfliteFfiInit();
  late Directory dir;
  late String path;
  late ProviderContainer container;

  setUp(() async {
    container = ProviderContainer();
    dir = await Directory.systemTemp.createTemp('fitforge_test');
    path = '${dir.path}/fitforge.db';
  });

  tearDown(() async {
    container.dispose();
    await DatabaseHelper.instance.close();
    await dir.delete(recursive: true);
  });

  Future<Database> openV2AndSeed() async {
    final db = await databaseFactoryFfi.openDatabase(path,
        options: OpenDatabaseOptions(version: 2, onCreate: _createV2));
    await _seedV2(db, imageDir: dir.path);
    await db.close();
    await DatabaseHelper.instance
        .initialize(path: path, factory: databaseFactoryFfi);
    return DatabaseHelper.instance.database;
  }

  group('migration v2 -> v3', () {
    test('merges duplicate exercises into one shared exercise', () async {
      final db = await openV2AndSeed();

      final exercises = await db.query('exercises', orderBy: 'name');
      expect(exercises.map((e) => e['id']), ['bench_mon', 'squat_mon']);
      final bench = exercises.first;
      expect(bench['name'], 'Bench Press');
      // Missing metadata is taken from the merged duplicates.
      expect(bench['description'], 'Keep your back flat');
    });

    test('keeps one plan slot per plan with its own default sets', () async {
      final db = await openV2AndSeed();

      final slots = await db.query('plan_exercises', orderBy: 'id');
      expect(
        slots.map((s) => '${s['id']}:${s['plan_id']}:${s['exercise_id']}'),
        [
          'bench_mon:mon:bench_mon',
          'bench_thu:thu:bench_mon',
          'squat_mon:mon:squat_mon',
        ],
      );

      final sets = await db.query('default_sets', orderBy: 'plan_exercise_id');
      expect(sets.map((s) => '${s['plan_exercise_id']}:${s['weight']}'),
          ['bench_mon:100.0', 'bench_thu:80.0', 'squat_mon:120.0']);
    });

    test('keeps all logs and sets, linked to the shared exercise', () async {
      final db = await openV2AndSeed();

      final logs = await db.query('workout_logs', orderBy: 'id');
      expect(
        logs.map(
            (l) => '${l['id']}:${l['exercise_id']}:${l['plan_exercise_id']}'),
        [
          'l1:bench_mon:bench_mon',
          'l2:bench_mon:bench_thu',
          'l3:bench_mon:bench_mon',
          'l4:squat_mon:squat_mon',
        ],
      );
      expect(
          _firstInt(await db.rawQuery('SELECT COUNT(*) FROM workout_sets')), 4);
      expect(await db.rawQuery('PRAGMA foreign_key_check'), isEmpty);
    });

    test('v4: the increment moves from the sets to the exercise', () async {
      final db = await openV2AndSeed();

      final rows = await db.query('exercises', orderBy: 'name');
      expect(rows.map((e) => e['increment']), [2.5, 2.5]);
      expect(rows.map((e) => e['auto_progress']), [1, 1]);
      expect(rows.map((e) => e['sets_to_progress']), [null, null]);
    });

    test('enables foreign keys after the upgrade', () async {
      final db = await openV2AndSeed();
      expect(_firstInt(await db.rawQuery('PRAGMA foreign_keys')), 1);
    });

    test('adopts a duplicate image, deletes the rest', () async {
      final adopted = File('${dir.path}/adopted.jpg')..writeAsStringSync('x');
      final orphan = File('${dir.path}/orphan.jpg')..writeAsStringSync('x');
      final db = await openV2AndSeed();

      final bench =
          (await db.query('exercises', where: "id = 'bench_mon'")).single;
      expect(bench['image_path'], adopted.path);
      expect(adopted.existsSync(), isTrue);
      expect(orphan.existsSync(), isFalse);
    });

    test('deleting a plan keeps the workout history', () async {
      final db = await openV2AndSeed();
      await container.read(workoutPlanRepositoryProvider).delete('thu');

      final l2 = (await db.query('workout_logs', where: "id = 'l2'")).single;
      expect(l2['exercise_id'], 'bench_mon');
      expect(l2['plan_exercise_id'], isNull);
      expect(
          await db.query('plan_exercises', where: "plan_id = 'thu'"), isEmpty);
    });
  });

  group('plan exercises', () {
    setUp(() async {
      await DatabaseHelper.instance
          .initialize(path: path, factory: databaseFactoryFfi);
      await DatabaseHelper.instance.database.insert('workout_plans', {
        'id': 'mon',
        'name': 'Monday',
        'day_of_week': 1,
        'created_at': '2026-01-01',
      });
    });

    const sets = [(reps: 5, weight: 100.0, increment: 2.5)];

    test('the same exercise cannot be added twice to a plan', () async {
      final exercise = await container
          .read(exerciseRepositoryProvider)
          .findOrCreate(name: 'Bench Press', muscleGroup: 'Chest');
      final repo = container.read(planExerciseRepositoryProvider);

      expect(await repo.add(planId: 'mon', exercise: exercise, sets: sets),
          isNotNull);
      expect(await repo.add(planId: 'mon', exercise: exercise, sets: sets),
          isNull);
    });

    test('findOrCreate matches names case-insensitively', () async {
      final a = await container
          .read(exerciseRepositoryProvider)
          .findOrCreate(name: 'Bench Press', muscleGroup: 'Chest');
      final b = await container
          .read(exerciseRepositoryProvider)
          .findOrCreate(name: ' bench press', muscleGroup: 'Chest');
      expect(b.id, a.id);
    });

    test('removing from a plan drops an exercise only without history',
        () async {
      final exercise = await container
          .read(exerciseRepositoryProvider)
          .findOrCreate(name: 'Bench Press', muscleGroup: 'Chest');
      final repo = container.read(planExerciseRepositoryProvider);
      final pe = await repo.add(planId: 'mon', exercise: exercise, sets: sets);

      await repo.remove(pe!.id);
      expect(
          await container.read(exerciseRepositoryProvider).getById(exercise.id),
          isNull);
    });

    group('workout logs', () {
      const logged = [
        (
          plannedReps: 5,
          actualReps: 5,
          plannedWeight: 100.0,
          actualWeight: 100.0,
          isCompleted: true,
        ),
      ];

      test('saving again on the same day replaces the log of that plan slot',
          () async {
        await DatabaseHelper.instance.database.insert('workout_plans', {
          'id': 'thu',
          'name': 'Thursday',
          'day_of_week': 4,
          'created_at': '2026-01-01',
        });
        final exercise = await container
            .read(exerciseRepositoryProvider)
            .findOrCreate(name: 'Bench Press', muscleGroup: 'Chest');
        final plans = container.read(planExerciseRepositoryProvider);
        final mon =
            await plans.add(planId: 'mon', exercise: exercise, sets: sets);
        final thu =
            await plans.add(planId: 'thu', exercise: exercise, sets: sets);
        final logs = container.read(workoutLogRepositoryProvider);
        final day = DateTime(2026, 9, 25);

        Future<void> save(String planExerciseId) => logs.createOrReplace(
              exerciseId: exercise.id,
              planExerciseId: planExerciseId,
              logDate: day,
              sets: logged,
            );

        await save(mon!.id);
        await save(mon.id);
        await save(thu!.id);

        final history = await logs.getByExercise(exercise.id);
        expect(history.map((l) => l.planExerciseId).toList()..sort(),
            [mon.id, thu.id]..sort());
      });
    });
  });
}
