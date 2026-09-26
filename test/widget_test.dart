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
}
