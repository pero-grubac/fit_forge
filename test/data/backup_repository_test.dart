import 'dart:convert';
import 'dart:io';

import 'package:fit_forge/data/local/database_helper.dart';
import 'package:fit_forge/data/providers.dart';
import 'package:fit_forge/data/repositories/backup_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  late Directory dir;
  late ProviderContainer container;

  Database db() => DatabaseHelper.instance.database;

  Future<Map<String, int>> counts() async => {
        for (final table in BackupRepository.tables)
          table: (await db().rawQuery('SELECT COUNT(*) AS n FROM $table'))
              .first['n'] as int,
      };

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('fitforge_backup_test');
    await DatabaseHelper.instance.initialize(
        path: '${dir.path}/fitforge.db', factory: databaseFactoryFfi);
    container = ProviderContainer();

    final plan = await container
        .read(workoutPlanRepositoryProvider)
        .create(name: 'Push', dayOfWeek: 1);
    final bench = await container
        .read(exerciseRepositoryProvider)
        .findOrCreate(name: 'Bench Press', muscleGroup: 'Chest');
    await db().update('exercises', {'image_path': '${dir.path}/missing.jpg'});
    final pe = await container.read(planExerciseRepositoryProvider).add(
      planId: plan.id,
      exercise: bench,
      sets: const [(reps: 5, weight: 100.0, increment: 2.5)],
    );
    await container.read(workoutLogRepositoryProvider).createOrReplace(
      exerciseId: bench.id,
      planExerciseId: pe!.id,
      logDate: DateTime(2026, 9, 25),
      sets: const [
        (
          plannedReps: 5,
          actualReps: 5,
          plannedWeight: 100.0,
          actualWeight: 100.0,
          isCompleted: true,
        ),
      ],
    );
    await container.read(quoteRepositoryProvider).create('Why not you?');
  });

  tearDown(() async {
    container.dispose();
    await DatabaseHelper.instance.close();
    await dir.delete(recursive: true);
  });

  BackupRepository backup() => container.read(backupRepositoryProvider);

  test('export and import restore the same data', () async {
    final before = await counts();
    expect(before.values.every((n) => n > 0), isTrue);

    final json = await backup().exportJson();
    await DatabaseHelper.instance.recreate();
    expect((await counts()).values.every((n) => n == 0), isTrue);

    await backup().importJson(json);
    expect(await counts(), before);
    final log = (await db().query('workout_logs')).single;
    expect(log['total_volume'], 500.0);
  });

  test('image paths to missing files are cleared on import', () async {
    final json = await backup().exportJson();
    await backup().importJson(json);
    expect((await db().query('exercises')).single['image_path'], isNull);
  });

  test('import replaces existing data instead of merging', () async {
    final json = await backup().exportJson();
    await container
        .read(workoutPlanRepositoryProvider)
        .create(name: 'Extra', dayOfWeek: 2);

    await backup().importJson(json);
    expect((await db().query('workout_plans')).map((p) => p['name']), ['Push']);
  });

  group('invalid files are rejected and nothing changes', () {
    Future<void> expectRejected(String json) async {
      final before = await counts();
      await expectLater(
          backup().importJson(json), throwsA(isA<BackupFormatException>()));
      expect(await counts(), before);
    }

    test('not JSON', () => expectRejected('hello'));

    test('other JSON', () => expectRejected('{"foo": 1}'));

    test('newer schema version', () async {
      final data = jsonDecode(await backup().exportJson());
      data['schema_version'] = DatabaseHelper.version + 1;
      await expectRejected(jsonEncode(data));
    });

    test('broken references', () async {
      final data = jsonDecode(await backup().exportJson());
      (data['tables']['exercises'] as List).clear();
      await expectRejected(jsonEncode(data));
    });

    test('unknown columns', () async {
      final data = jsonDecode(await backup().exportJson());
      (data['tables']['workout_plans'] as List).first['color'] = 'red';
      await expectRejected(jsonEncode(data));
    });
  });
}
