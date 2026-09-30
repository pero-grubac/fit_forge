import 'dart:io';

import 'package:fit_forge/core/services/rest_alerts.dart';
import 'package:fit_forge/data/local/database_helper.dart';
import 'package:fit_forge/data/providers.dart';
import 'package:fit_forge/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'helpers/fake_rest_alerts.dart';

/// App-level smoke tests against a real (temporary) SQLite database.
void main() {
  sqfliteFfiInit();
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('fitforge_widget_test');
    await DatabaseHelper.instance.initialize(
        path: '${dir.path}/fitforge.db', factory: databaseFactoryFfi);
  });

  tearDown(() async {
    await DatabaseHelper.instance.close();
    await dir.delete(recursive: true);
  });

  /// Database calls are real I/O, which the fake test clock doesn't wait for;
  /// let them complete between frames.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 20; i++) {
      await tester
          .runAsync(() => Future.delayed(const Duration(milliseconds: 20)));
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  String quoteText(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const Key('motivation_quote'))).data!;

  Future<void> startApp(WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [restAlertsProvider.overrideWithValue(FakeRestAlerts())],
      child: const FitForgeApp(),
    ));
    await settle(tester);
  }

  testWidgets('first launch shows onboarding', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await startApp(tester);

    expect(find.text('Skip'), findsOneWidget);
  });

  testWidgets('without a plan for today the home screen says so',
      (tester) async {
    SharedPreferences.setMockInitialValues({'is_setup_done': true});
    await startApp(tester);

    expect(find.text('No plan for today'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.bar_chart_rounded));
    await settle(tester);
    expect(find.text('You have no workouts yet'), findsOneWidget);
  });

  testWidgets('logging a workout from the home screen saves it',
      (tester) async {
    SharedPreferences.setMockInitialValues({'is_setup_done': true});

    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.runAsync(() async {
      final plan = await container
          .read(workoutPlanRepositoryProvider)
          .create(name: 'Push', dayOfWeek: DateTime.now().weekday);
      final bench = await container
          .read(exerciseRepositoryProvider)
          .findOrCreate(name: 'Bench Press', muscleGroup: 'Chest');
      await container.read(planExerciseRepositoryProvider).add(
        planId: plan.id,
        exercise: bench,
        sets: const [
          (reps: 5, weight: 60.0, increment: 2.5),
          (reps: 5, weight: 60.0, increment: 2.5),
        ],
      );
    });

    await startApp(tester);
    expect(find.text('Bench Press'), findsOneWidget);
    expect(find.text('0/2 sets'), findsOneWidget);
    final quoteBefore = quoteText(tester);

    await tester.tap(find.text('Bench Press'));
    await settle(tester);

    await tester.ensureVisible(find.byKey(const Key('set_toggle_1')));
    await tester.tap(find.byKey(const Key('set_toggle_1')));
    await tester.pump();
    // Default rest of 90 s starts after a set that isn't the last one.
    expect(find.text('1:30'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('set_toggle_2')));
    await tester.tap(find.byKey(const Key('set_toggle_2')));
    await tester.pump();
    // After the last set there is nothing to rest for.
    expect(find.byKey(const Key('rest_remaining')), findsNothing);
    await tester.tap(find.text('Save workout'));
    await settle(tester);

    expect(find.text('2/2 sets'), findsOneWidget);
    expect(quoteText(tester), isNot(quoteBefore));

    // Switching tabs and coming back to Home also shows a new quote.
    final quoteAfterWorkout = quoteText(tester);
    await tester.tap(find.byIcon(Icons.bar_chart_rounded));
    await settle(tester);
    await tester.tap(find.byIcon(Icons.home_rounded));
    await settle(tester);
    expect(quoteText(tester), isNot(quoteAfterWorkout));

    final history = await tester.runAsync(() async {
      final bench =
          (await container.read(exerciseRepositoryProvider).getAll()).single;
      return container
          .read(workoutLogRepositoryProvider)
          .getByExercise(bench.id);
    });
    expect(history, hasLength(1));
    expect(history!.single.sets.where((s) => s.isCompleted), hasLength(2));
    expect(history.single.totalVolume, 600);
  });

  testWidgets('a plan can be moved to another day', (tester) async {
    SharedPreferences.setMockInitialValues({'is_setup_done': true});
    final today = DateTime.now().weekday;
    final otherDay = today % 7 + 1;
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.runAsync(() => container
        .read(workoutPlanRepositoryProvider)
        .create(name: 'Push', dayOfWeek: otherDay));

    await startApp(tester);
    expect(find.text('No plan for today'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.calendar_month).last);
    await settle(tester);
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await settle(tester);
    await tester.tap(find.byKey(Key('plan_day_$today')));
    await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
    await settle(tester);

    await tester.tap(find.byIcon(Icons.home_rounded));
    await settle(tester);
    expect(find.text('No plan for today'), findsNothing);
    expect(find.text('Push'), findsOneWidget);
  });

  testWidgets('demo data is hidden until the version is tapped 7 times',
      (tester) async {
    SharedPreferences.setMockInitialValues({'is_setup_done': true});
    PackageInfo.setMockInitialValues(
      appName: 'Fit Forge',
      packageName: 'com.fitforge.fit_forge',
      version: '1.3.0',
      buildNumber: '5',
      buildSignature: '',
    );
    await startApp(tester);
    await tester.tap(find.byIcon(Icons.settings_rounded));
    await settle(tester);

    expect(find.text('Load demo data'), findsNothing);

    final version = find.byKey(const Key('app_version'));
    await tester.scrollUntilVisible(version, 200);
    expect(find.text('FitForge 1.3.0 (5)'), findsOneWidget);
    for (var i = 0; i < 7; i++) {
      await tester.tap(version);
      await tester.pump();
    }
    await settle(tester);

    await tester.scrollUntilVisible(find.text('Load demo data'), 200);
    expect(find.text('Load demo data'), findsOneWidget);
    final prefs = await tester.runAsync(SharedPreferences.getInstance);
    expect(prefs!.getBool('dev_mode'), isTrue);
  });

  group('exercise description and session notes', () {
    late ProviderContainer container;
    late String benchId;
    late String planExerciseId;

    /// Today's plan with Bench Press; returns after seeding.
    Future<void> seed(WidgetTester tester, {String? description}) async {
      SharedPreferences.setMockInitialValues({'is_setup_done': true});
      container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.runAsync(() async {
        final plan = await container
            .read(workoutPlanRepositoryProvider)
            .create(name: 'Push', dayOfWeek: DateTime.now().weekday);
        final exercises = container.read(exerciseRepositoryProvider);
        final bench = await exercises.findOrCreate(
            name: 'Bench Press', muscleGroup: 'Chest');
        benchId = bench.id;
        if (description != null) {
          await exercises.updateDescriptionAndUrl(bench.id, description, null);
        }
        final pe = await container.read(planExerciseRepositoryProvider).add(
          planId: plan.id,
          exercise: bench,
          sets: const [(reps: 5, weight: 60.0, increment: 2.5)],
        );
        planExerciseId = pe!.id;
      });
    }

    Future<void> openBenchFromHome(WidgetTester tester) async {
      await startApp(tester);
      await tester.tap(find.text('Bench Press'));
      await settle(tester);
    }

    testWidgets('description from the plan is shown while logging',
        (tester) async {
      await seed(tester, description: 'Keep your back flat');
      await openBenchFromHome(tester);

      expect(find.text('Keep your back flat'), findsOneWidget);
    });

    testWidgets('editing while logging updates the shared exercise',
        (tester) async {
      await seed(tester);
      await openBenchFromHome(tester);
      expect(find.text('Add description'), findsOneWidget);

      await tester.tap(find.text('Add description'));
      await settle(tester);
      await tester.enterText(
          find.widgetWithText(TextField, 'e.g. Keep your back flat...'),
          'Elbows at 45 degrees');
      final save = find.widgetWithText(ElevatedButton, 'Save');
      await tester.ensureVisible(save);
      await tester.tap(save);
      await settle(tester);

      // Shown on the log page right away ...
      expect(find.byKey(const Key('exercise_description')), findsOneWidget);
      expect(find.text('Elbows at 45 degrees'), findsOneWidget);
      // ... and stored on the exercise, which the plan screen reads.
      final stored = await tester.runAsync(
          () => container.read(exerciseRepositoryProvider).getById(benchId));
      expect(stored!.description, 'Elbows at 45 degrees');
    });

    testWidgets('the note from the last session is shown', (tester) async {
      await seed(tester);
      await tester.runAsync(
          () => container.read(workoutLogRepositoryProvider).createOrReplace(
                exerciseId: benchId,
                planExerciseId: planExerciseId,
                logDate: DateTime.now().subtract(const Duration(days: 3)),
                notes: 'Felt heavy on the last set',
                sets: const [
                  (
                    plannedReps: 5,
                    actualReps: 5,
                    plannedWeight: 60.0,
                    actualWeight: 60.0,
                    isCompleted: true,
                  ),
                ],
              ));
      await openBenchFromHome(tester);

      expect(find.text('Felt heavy on the last set'), findsOneWidget);
      expect(find.text('Notes for this session'), findsOneWidget);
    });
  });

  group('set-count progression while logging', () {
    /// Today's plan with Barbell Curl 3×8 @ 10 kg, +2.5 kg after 8 good sets,
    /// and two earlier sessions of 3 good sets (6 so far).
    Future<void> seed(
      WidgetTester tester, {
      bool auto = true,
      bool missLastSet = false,
      List<List<double>> history = const [
        [10, 10, 10],
        [10, 10, 10],
      ],
    }) async {
      SharedPreferences.setMockInitialValues(
          {'is_setup_done': true, 'rest_seconds': 0});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await tester.runAsync(() async {
        final plan = await container
            .read(workoutPlanRepositoryProvider)
            .create(name: 'Arms', dayOfWeek: DateTime.now().weekday);
        final exercises = container.read(exerciseRepositoryProvider);
        final curl = await exercises.findOrCreate(
            name: 'Barbell Curl', muscleGroup: 'Biceps');
        await exercises.updateProgression(curl.id,
            autoProgress: auto, increment: 2.5, setsToProgress: 8);
        final pe = await container.read(planExerciseRepositoryProvider).add(
              planId: plan.id,
              exercise: curl,
              sets: List.filled(3, (reps: 8, weight: 10.0, increment: 0.0)),
            );
        for (final (i, weights) in history.indexed) {
          final weeksAgo = history.length - i;
          await container.read(workoutLogRepositoryProvider).createOrReplace(
            exerciseId: curl.id,
            planExerciseId: pe!.id,
            logDate: DateTime.now().subtract(Duration(days: 7 * weeksAgo)),
            sets: [
              for (final (j, w) in weights.indexed)
                (
                  plannedReps: 8,
                  // Optionally miss the last set of the last workout.
                  actualReps: missLastSet &&
                          i == history.length - 1 &&
                          j == weights.length - 1
                      ? 6
                      : 8,
                  plannedWeight: w,
                  actualWeight: w,
                  isCompleted: true,
                ),
            ],
          );
        }
      });
      await startApp(tester);
      await tester.tap(find.text('Barbell Curl'));
      await settle(tester);
    }

    String weight(WidgetTester tester, int set) => tester
        .widget<TextField>(find.byKey(Key('set_weight_$set')))
        .controller!
        .text;

    /// Ticks a set, then scrolls back up so the banner is built again.
    Future<void> tick(WidgetTester tester, int set) async {
      await tester.ensureVisible(find.byKey(Key('set_toggle_$set')));
      await tester.tap(find.byKey(Key('set_toggle_$set')));
      await tester.pump();
      await tester.scrollUntilVisible(
        find.byKey(const Key('progression_message')),
        -200,
        scrollable: find
            .descendant(
                of: find.byType(CustomScrollView),
                matching: find.byType(Scrollable))
            .first,
      );
    }

    testWidgets('the 9th set is pre-filled heavier', (tester) async {
      await seed(tester);

      expect([weight(tester, 1), weight(tester, 2), weight(tester, 3)],
          ['10.0', '10.0', '12.5']);
      expect(find.text('6/8 sets at 10 kg — then 12.5 kg'), findsOneWidget);

      await tick(tester, 1);
      expect(find.text('7/8 sets at 10 kg — then 12.5 kg'), findsOneWidget);
    });

    testWidgets('after an increase one more set moves up each week',
        (tester) async {
      await seed(tester, history: const [
        [10, 10, 10],
        [10, 10, 10],
        [10, 10, 12.5],
      ]);

      expect([weight(tester, 1), weight(tester, 2), weight(tester, 3)],
          ['10.0', '12.5', '12.5']);
      expect(find.text('Moving up to 12.5 kg: 2 of 3 sets this workout'),
          findsOneWidget);
    });

    testWidgets('a missed heavy set repeats the same week', (tester) async {
      await seed(tester, missLastSet: true, history: const [
        [10, 10, 10],
        [10, 10, 10],
        [10, 10, 12.5],
        [10, 12.5, 12.5],
      ]);

      expect([weight(tester, 1), weight(tester, 2), weight(tester, 3)],
          ['10.0', '12.5', '12.5']);
      expect(find.text('Moving up to 12.5 kg: 2 of 3 sets this workout'),
          findsOneWidget);
    });

    testWidgets('the first full workout at the new weight starts the count',
        (tester) async {
      await seed(tester, history: const [
        [10, 10, 10],
        [10, 10, 10],
        [10, 10, 12.5],
        [10, 12.5, 12.5],
        [12.5, 12.5, 12.5],
      ]);

      expect([weight(tester, 1), weight(tester, 2), weight(tester, 3)],
          ['12.5', '12.5', '12.5']);
      expect(find.text('3/8 sets at 12.5 kg — then 15 kg'), findsOneWidget);
    });

    testWidgets('a missed set resets the count and the next sets',
        (tester) async {
      await seed(tester);

      await tester.enterText(find.byKey(const Key('set_reps_1')), '6');
      await tick(tester, 1);

      expect(find.text('0/8 sets at 10 kg — then 12.5 kg'), findsOneWidget);
      expect(weight(tester, 3), '10.0');
    });

    testWidgets('a manual increase resets and carries the new weight',
        (tester) async {
      await seed(tester);

      await tester.enterText(find.byKey(const Key('set_weight_1')), '12.5');
      await tick(tester, 1);

      expect(find.text('1/8 sets at 12.5 kg — then 15 kg'), findsOneWidget);
      expect([weight(tester, 2), weight(tester, 3)], ['12.5', '12.5']);
    });

    testWidgets('turned off: last session as it was, no banner',
        (tester) async {
      await seed(tester, auto: false);

      expect([weight(tester, 1), weight(tester, 2), weight(tester, 3)],
          ['10.0', '10.0', '10.0']);
      expect(find.byKey(const Key('progression_message')), findsNothing);
    });
  });
}
