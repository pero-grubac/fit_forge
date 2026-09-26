import 'dart:io';

import 'package:fit_forge/core/models/progression_suggestion.dart';
import 'package:fit_forge/data/demo_data.dart';
import 'package:fit_forge/data/local/database_helper.dart';
import 'package:fit_forge/data/providers.dart';
import 'package:fit_forge/features/workout_log/providers/progression_provider.dart';
import 'package:fit_forge/features/workout_log/providers/streak_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  late Directory dir;
  late ProviderContainer container;

  Database db() => DatabaseHelper.instance.database;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    dir = await Directory.systemTemp.createTemp('fitforge_demo_test');
    await DatabaseHelper.instance.initialize(
        path: '${dir.path}/fitforge.db', factory: databaseFactoryFfi);
    container = ProviderContainer();
  });

  tearDown(() async {
    container.dispose();
    await DatabaseHelper.instance.close();
    await dir.delete(recursive: true);
  });

  // A Saturday: not a Push/Pull/Legs day, so a Full Body plan is added.
  final saturday = DateTime(2026, 9, 26);

  Future<String> slotId(String plan, String exercise) async {
    final rows = await db().rawQuery('''
      SELECT pe.id FROM plan_exercises pe
      JOIN workout_plans p ON p.id = pe.plan_id
      JOIN exercises e ON e.id = pe.exercise_id
      WHERE p.name = ? AND e.name = ?''', [plan, exercise]);
    return rows.single['id'] as String;
  }

  test('creates plans for every weekday it needs, including today', () async {
    await container.read(demoDataProvider).load(today: saturday);

    final plans = await db().query('workout_plans', orderBy: 'day_of_week');
    expect(plans.map((p) => '${p['name']}:${p['day_of_week']}'),
        ['Push:1', 'Pull:3', 'Legs:5', 'Full Body:6']);
  });

  test('shared exercises have one history across plans', () async {
    await container.read(demoDataProvider).load(today: saturday);

    final bench =
        (await db().query('exercises', where: "name = 'Bench Press'")).single;
    final logs = await db().query('workout_logs',
        where: 'exercise_id = ?', whereArgs: [bench['id']]);
    // 8 weeks on Monday (Push) + 8 on Saturday (Full Body).
    expect(logs, hasLength(16));
    expect(logs.map((l) => l['plan_exercise_id']).toSet(), hasLength(2));
    expect(bench['description'], isNotNull);
  });

  test("today's workout is left to do", () async {
    await container.read(demoDataProvider).load(today: saturday);

    final todays =
        await db().query('workout_logs', where: "log_date = '2026-09-26'");
    expect(todays, isEmpty);
    final latest =
        await db().rawQuery('SELECT MAX(log_date) AS d FROM workout_logs');
    expect(latest.single['d'], '2026-09-25');
  });

  test('on a planned day no extra plan is added', () async {
    final monday = DateTime(2026, 9, 28);
    await container.read(demoDataProvider).load(today: monday);

    expect(await db().query('workout_plans'), hasLength(3));
    expect(await db().query('workout_logs', where: "log_date = '2026-09-28'"),
        isEmpty);
  });

  test('shows the different progression suggestions', () async {
    await container.read(demoDataProvider).load(today: saturday);

    Future<ProgressionSuggestion> suggestion(String plan, String ex) async =>
        container.read(progressionProvider(await slotId(plan, ex)).future);

    final bench = await suggestion('Push', 'Bench Press');
    expect(bench.action, ProgressionAction.increase);
    expect(bench.unit, ProgressionUnit.kg);

    final press = await suggestion('Push', 'Overhead Press');
    expect(press.action, ProgressionAction.hold);

    final pullUp = await suggestion('Pull', 'Pull Up');
    expect(pullUp.action, ProgressionAction.increase);
    expect(pullUp.unit, ProgressionUnit.reps);

    final plank = await suggestion('Legs', 'Plank');
    expect(plank.unit, ProgressionUnit.seconds);
  });

  test('loading again replaces the data instead of duplicating it', () async {
    final demo = container.read(demoDataProvider);
    await demo.load(today: saturday);
    final first = (await db().query('workout_logs')).length;

    await demo.load(today: saturday);
    expect(await db().query('workout_logs'), hasLength(first));
    expect(await db().query('workout_plans'), hasLength(4));
  });

  test('gives a streak to look at', () async {
    await container.read(demoDataProvider).load(today: saturday);
    // The provider uses the real date, so compute it for the demo's today.
    final plans = await container.read(workoutPlanRepositoryProvider).getAll();
    final dates =
        await container.read(workoutLogRepositoryProvider).getLoggedDates();
    final streak = calculateStreak(
      plannedDays: {for (final p in plans) p.dayOfWeek},
      loggedDates: dates,
      today: saturday,
    );
    expect(streak, 4 * DemoData.weeks);
  });
}
