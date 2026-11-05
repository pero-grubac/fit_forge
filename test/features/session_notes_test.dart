import 'dart:io';

import 'package:fit_forge/data/local/database_helper.dart';
import 'package:fit_forge/data/providers.dart';
import 'package:fit_forge/features/workout_log/providers/workout_log_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Editing/clearing a past session's note from the Progress history list
/// (the swipe-right/swipe-left actions) goes through
/// [WorkoutLogNotifier.updateNotes].
void main() {
  sqfliteFfiInit();
  late Directory dir;
  late ProviderContainer container;
  late String exerciseId;
  late String logId;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('fitforge_notes_test');
    await DatabaseHelper.instance
        .initialize(path: '${dir.path}/fitforge.db', factory: databaseFactoryFfi);
    container = ProviderContainer();

    final plan = await container
        .read(workoutPlanRepositoryProvider)
        .create(name: 'Push', dayOfWeek: 1);
    final bench = await container
        .read(exerciseRepositoryProvider)
        .findOrCreate(name: 'Bench Press', muscleGroup: 'Chest');
    exerciseId = bench.id;
    final pe = await container.read(planExerciseRepositoryProvider).add(
      planId: plan.id,
      exercise: bench,
      sets: const [(reps: 5, weight: 60.0, increment: 2.5)],
    );
    final log = await container.read(workoutLogRepositoryProvider).createOrReplace(
      exerciseId: bench.id,
      planExerciseId: pe!.id,
      logDate: DateTime(2026, 9, 25),
      notes: 'Felt heavy',
      sets: const [
        (
          plannedReps: 5,
          actualReps: 5,
          plannedWeight: 60.0,
          actualWeight: 60.0,
          isCompleted: true,
          feeling: null,
        ),
      ],
    );
    logId = log.id;
  });

  tearDown(() async {
    container.dispose();
    await DatabaseHelper.instance.close();
    await dir.delete(recursive: true);
  });

  test('editing a note changes it without touching the sets', () async {
    await container.read(workoutLogNotifierProvider.notifier).updateNotes(
        logId: logId, exerciseId: exerciseId, notes: 'Actually felt good');

    final logs = await container.read(workoutLogRepositoryProvider).getByExercise(exerciseId);
    final log = logs.single;
    expect(log.notes, 'Actually felt good');
    expect(log.sets.single.actualWeight, 60.0);
  });

  test('clearing a note (empty swipe-left) sets it to null', () async {
    await container
        .read(workoutLogNotifierProvider.notifier)
        .updateNotes(logId: logId, exerciseId: exerciseId, notes: null);

    final logs = await container.read(workoutLogRepositoryProvider).getByExercise(exerciseId);
    expect(logs.single.notes, isNull);
  });
}
