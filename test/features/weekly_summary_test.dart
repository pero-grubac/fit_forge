import 'dart:io';

import 'package:fit_forge/data/local/database_helper.dart';
import 'package:fit_forge/data/providers.dart';
import 'package:fit_forge/features/workout_log/providers/rest_timer_provider.dart';
import 'package:fit_forge/features/workout_log/providers/weekly_summary_provider.dart';
import 'package:fit_forge/features/workout_log/providers/workout_log_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  late Directory dir;
  late DateTime weekStart;
  late DateTime prevWeekStart;

  ProviderContainer makeContainer(DateTime now) {
    final container = ProviderContainer(
      overrides: [clockProvider.overrideWithValue(() => now)],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('fitforge_weekly_test');
    await DatabaseHelper.instance
        .initialize(path: '${dir.path}/fitforge.db', factory: databaseFactoryFfi);

    final now = DateTime(2026, 11, 5);
    final today0 = DateTime(now.year, now.month, now.day);
    weekStart = today0.subtract(Duration(days: today0.weekday - 1));
    prevWeekStart = weekStart.subtract(const Duration(days: 7));
  });

  tearDown(() async {
    await DatabaseHelper.instance.close();
    await dir.delete(recursive: true);
  });

  Future<String> seedExercise(ProviderContainer container) async {
    final plan = await container
        .read(workoutPlanRepositoryProvider)
        .create(name: 'Push', dayOfWeek: 1);
    final bench = await container
        .read(exerciseRepositoryProvider)
        .findOrCreate(name: 'Bench Press', muscleGroup: 'Chest');
    final pe = await container.read(planExerciseRepositoryProvider).add(
      planId: plan.id,
      exercise: bench,
      sets: const [(reps: 5, weight: 10.0, increment: 2.5)],
    );
    return pe!.id;
  }

  Future<void> log(
    ProviderContainer container,
    String planExerciseId, {
    required DateTime date,
    required double weight,
  }) async {
    final pe =
        await container.read(planExerciseRepositoryProvider).getById(planExerciseId);
    await container.read(workoutLogRepositoryProvider).createOrReplace(
      exerciseId: pe!.exerciseId,
      planExerciseId: planExerciseId,
      logDate: date,
      sets: [
        (
          plannedReps: 5,
          actualReps: 5,
          plannedWeight: weight,
          actualWeight: weight,
          isCompleted: true,
          feeling: null,
        ),
      ],
    );
  }

  test('no logs at all gives null', () async {
    final container = makeContainer(DateTime(2026, 11, 5));
    expect(await container.read(weeklySummaryProvider.future), isNull);
  });

  test('nothing logged this week gives null even with older history', () async {
    final container = makeContainer(DateTime(2026, 11, 5));
    final pe = await seedExercise(container);
    await log(container, pe, date: prevWeekStart, weight: 10);

    expect(await container.read(weeklySummaryProvider.future), isNull);
  });

  test('volume change and a new PR this week', () async {
    final container = makeContainer(DateTime(2026, 11, 5));
    final pe = await seedExercise(container);
    await log(container, pe, date: prevWeekStart, weight: 10); // volume 50
    await log(container, pe, date: weekStart, weight: 20); // volume 100, new PR

    final summary = await container.read(weeklySummaryProvider.future);
    expect(summary, isNotNull);
    expect(summary!.volumeChangePercent, 100.0);
    expect(summary.newPrCount, 1);
  });

  test('early in the week only the same days of last week are compared',
      () async {
    final container = makeContainer(DateTime(2026, 11, 5));
    final pe = await seedExercise(container);
    await log(container, pe, date: prevWeekStart, weight: 10); // Mon: 50
    await log(container, pe,
        date: prevWeekStart.add(const Duration(days: 2)), weight: 10); // Wed
    await log(container, pe, date: weekStart, weight: 10); // Mon: 50

    final summary = await container.read(weeklySummaryProvider.future);
    expect(summary!.volumeChangePercent, 0.0);
  });

  test('demo data gives a believable summary on every day of the week',
      () async {
    // Mon 2 Nov 2026 .. Sun 8 Nov 2026.
    for (var d = 2; d <= 8; d++) {
      final today = DateTime(2026, 11, d);
      final container = makeContainer(today);
      await container.read(demoDataProvider).load(today: today);

      final summary = await container.read(weeklySummaryProvider.future);
      if (today.weekday == DateTime.monday) {
        // Nothing logged yet this week: today's workout is left to do.
        expect(summary, isNull, reason: '$today');
        continue;
      }
      expect(summary, isNotNull, reason: '$today');
      expect(summary!.volumeChangePercent, isNotNull, reason: '$today');
      expect(summary.volumeChangePercent!, inInclusiveRange(-15, 25),
          reason: '$today: ${summary.volumeChangePercent}');
      // The demo follows progressive overload: new records come with more
      // work done, never less.
      if (summary.newPrCount > 0) {
        expect(summary.volumeChangePercent!, greaterThanOrEqualTo(0),
            reason: '$today: ${summary.newPrCount} PRs at '
                '${summary.volumeChangePercent}%');
      }
    }
  });

  test('saving a workout refreshes the summary', () async {
    final container = makeContainer(DateTime(2026, 11, 5));
    final pe = await seedExercise(container);
    await log(container, pe, date: prevWeekStart, weight: 10);
    expect(await container.read(weeklySummaryProvider.future), isNull);

    final slot =
        await container.read(planExerciseRepositoryProvider).getById(pe);
    await container.read(workoutLogNotifierProvider.notifier).logWorkout(
      planExercise: slot!,
      logDate: weekStart,
      sets: [
        (
          plannedReps: 5,
          actualReps: 5,
          plannedWeight: 12.5,
          actualWeight: 12.5,
          isCompleted: true,
          feeling: null,
        ),
      ],
    );

    final summary = await container.read(weeklySummaryProvider.future);
    expect(summary, isNotNull);
    expect(summary!.newPrCount, 1);
  });

  test('a lighter week than last is a negative change and no new PR', () async {
    final container = makeContainer(DateTime(2026, 11, 5));
    final pe = await seedExercise(container);
    await log(container, pe, date: prevWeekStart, weight: 20); // volume 100
    await log(container, pe, date: weekStart, weight: 10); // volume 50, not a PR

    final summary = await container.read(weeklySummaryProvider.future);
    expect(summary, isNotNull);
    expect(summary!.volumeChangePercent, -50.0);
    expect(summary.newPrCount, 0);
  });
}
