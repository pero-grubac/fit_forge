import 'dart:io';

import 'package:fit_forge/data/local/database_helper.dart';
import 'package:fit_forge/data/providers.dart';
import 'package:fit_forge/data/repositories/workout_log_repository.dart';
import 'package:fit_forge/features/workout_log/providers/rest_timer_provider.dart';
import 'package:fit_forge/features/workout_log/providers/streak_provider.dart';
import 'package:fit_forge/features/workout_plan/providers/workout_plan_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// The streak against a real database: what counts as done, and moves.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  late Directory dir;
  late String slotId;
  late String exerciseId;

  // Monday 21 Sep 2026.
  final monday = DateTime(2026, 9, 21);
  final wednesday = DateTime(2026, 9, 23);

  ProviderContainer on(DateTime today) {
    final c = ProviderContainer(
        overrides: [clockProvider.overrideWithValue(() => today)]);
    addTearDown(c.dispose);
    return c;
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    dir = await Directory.systemTemp.createTemp('fitforge_streak_test');
    await DatabaseHelper.instance.initialize(
        path: '${dir.path}/fitforge.db', factory: databaseFactoryFfi);
    final c = ProviderContainer();
    final plan = await c
        .read(workoutPlanRepositoryProvider)
        .create(name: 'Push', dayOfWeek: DateTime.monday);
    final bench = await c
        .read(exerciseRepositoryProvider)
        .findOrCreate(name: 'Bench Press', muscleGroup: 'Chest');
    exerciseId = bench.id;
    final pe = await c.read(planExerciseRepositoryProvider).add(
      planId: plan.id,
      exercise: bench,
      sets: const [
        (reps: 5, weight: 60.0, increment: 2.5),
        (reps: 5, weight: 60.0, increment: 2.5),
      ],
    );
    slotId = pe!.id;
    c.dispose();
  });

  tearDown(() async {
    await DatabaseHelper.instance.close();
    await dir.delete(recursive: true);
  });

  Future<void> log(ProviderContainer c, DateTime day,
      {required bool bothSetsDone}) {
    LoggedSet set(bool done) => (
          plannedReps: 5,
          actualReps: 5,
          plannedWeight: 60.0,
          actualWeight: 60.0,
          isCompleted: done,
          feeling: null,
        );
    return c.read(workoutLogRepositoryProvider).createOrReplace(
      exerciseId: exerciseId,
      planExerciseId: slotId,
      logDate: day,
      sets: [set(true), set(bothSetsDone)],
    );
  }

  test('every set ticked: the day counts', () async {
    final c = on(wednesday);
    await log(c, monday, bothSetsDone: true);
    expect(await c.read(streakProvider.future), 1);
  });

  test('a set left unticked: the day is missed', () async {
    final c = on(wednesday);
    await log(c, monday, bothSetsDone: false);
    expect(await c.read(streakProvider.future), 0);
  });

  test('moving Monday\'s workout to Wednesday keeps the streak', () async {
    final c = on(monday);
    await log(c, DateTime(2026, 9, 14), bothSetsDone: true);
    final home = await c.read(homeScheduleProvider.future);
    await c
        .read(workoutPlanNotifierProvider.notifier)
        .moveWorkout(home.dueToday.single, wednesday);

    // Tuesday: Monday's workout is waiting for Wednesday.
    final tuesday = on(DateTime(2026, 9, 22));
    expect(await tuesday.read(streakProvider.future), 1);
    final upcoming = (await tuesday.read(homeScheduleProvider.future)).upcoming;
    expect([for (final o in upcoming) (o.dueDate, o.isMoved)], [
      (wednesday, true),
      (DateTime(2026, 9, 28), false), // next Monday's, as usual
    ]);

    // Done on Wednesday: Monday counts.
    final wed = on(wednesday);
    await log(wed, wednesday, bothSetsDone: true);
    expect(await wed.read(streakProvider.future), 2);

    // Not done by Thursday: the streak breaks from Monday.
    await wed.read(workoutLogRepositoryProvider).delete(
        (await wed.read(workoutLogRepositoryProvider).getByExercise(exerciseId))
            .first
            .id);
    expect(await on(DateTime(2026, 9, 24)).read(streakProvider.future), 0);
  });
}
