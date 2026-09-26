import 'package:fit_forge/data/local/database_helper.dart';
import 'package:fit_forge/data/models/plan_exercise_model.dart';
import 'package:fit_forge/data/repositories/exercise_repository.dart';
import 'package:fit_forge/data/repositories/plan_exercise_repository.dart';
import 'package:fit_forge/data/repositories/quote_repository.dart';
import 'package:fit_forge/data/repositories/workout_log_repository.dart';
import 'package:fit_forge/data/repositories/workout_plan_repository.dart';

/// Fills the app with sample plans and a few weeks of workout history, so
/// every screen has something to show. Replaces all existing data.
class DemoData {
  DemoData({
    required DatabaseHelper helper,
    required WorkoutPlanRepository plans,
    required ExerciseRepository exercises,
    required PlanExerciseRepository planExercises,
    required WorkoutLogRepository logs,
    required QuoteRepository quotes,
  })  : _helper = helper,
        _plans = plans,
        _exercises = exercises,
        _planExercises = planExercises,
        _logs = logs,
        _quotes = quotes;

  final DatabaseHelper _helper;
  final WorkoutPlanRepository _plans;
  final ExerciseRepository _exercises;
  final PlanExerciseRepository _planExercises;
  final WorkoutLogRepository _logs;
  final QuoteRepository _quotes;

  static const weeks = 8;

  static const _notes = [
    'Felt strong today',
    'Left shoulder a bit tight, kept the form strict',
    'Slept badly, last set was a grind',
    'New PR!',
    'Short rest, good pump',
  ];

  /// [today] is overridable for tests. Today's workout is left unlogged.
  Future<void> load({DateTime? today}) async {
    final now = today ?? DateTime.now();
    final day = DateTime(now.year, now.month, now.day);

    await _helper.recreate();

    final plans = <_DemoPlan>[
      const _DemoPlan('Push', DateTime.monday, [
        _DemoExercise('Bench Press', 'Chest',
            sets: 3,
            reps: 5,
            start: 60,
            description: 'Feet flat, shoulder blades squeezed together. '
                'Lower the bar to mid-chest and press up in a slight arc.',
            youTubeUrl: 'https://www.youtube.com/watch?v=rT7DgCr-3pg'),
        _DemoExercise('Incline Dumbbell Press', 'Chest',
            sets: 3, reps: 10, start: 20, increment: 2),
        // Stalls in the last sessions, so it shows a "hold" suggestion.
        _DemoExercise('Overhead Press', 'Shoulders',
            sets: 3, reps: 8, start: 35, stallRecently: true),
        _DemoExercise('Tricep Pushdown', 'Triceps',
            sets: 3, reps: 12, start: 25),
      ]),
      const _DemoPlan('Pull', DateTime.wednesday, [
        _DemoExercise('Pull Up', 'Bodyweight',
            type: 'bodyweight',
            sets: 3,
            reps: 5,
            description: 'Full hang at the bottom, chin over the bar at the '
                'top. No kipping.'),
        _DemoExercise('Barbell Row', 'Back', sets: 3, reps: 8, start: 50),
        _DemoExercise('Barbell Curl', 'Biceps', sets: 3, reps: 10, start: 25),
      ]),
      const _DemoPlan('Legs', DateTime.friday, [
        _DemoExercise('Squat', 'Legs',
            sets: 3,
            reps: 5,
            start: 80,
            increment: 5,
            description: 'Brace before each rep, break at hips and knees '
                'together, hit depth and drive up through mid-foot.',
            youTubeUrl: 'https://www.youtube.com/watch?v=ultWZbUMPL8'),
        _DemoExercise('Romanian Deadlift', 'Back',
            sets: 3, reps: 8, start: 70, increment: 5),
        _DemoExercise('Plank', 'Core', type: 'timed', sets: 3, reps: 30),
      ]),
    ];

    // A plan for today when it isn't a Push/Pull/Legs day, so the home
    // screen is never empty. Bench Press and Squat are shared with the other
    // plans (lighter targets here) and show one combined history.
    if (!plans.any((p) => p.weekday == day.weekday)) {
      plans.add(_DemoPlan('Full Body', day.weekday, [
        const _DemoExercise('Bench Press', 'Chest',
            sets: 3, reps: 10, start: 50),
        const _DemoExercise('Squat', 'Legs',
            sets: 3, reps: 10, start: 60, increment: 5),
        const _DemoExercise('Plank', 'Core', type: 'timed', sets: 2, reps: 30),
      ]));
    }

    var noteIndex = 0;
    for (final plan in plans) {
      final created =
          await _plans.create(name: plan.name, dayOfWeek: plan.weekday);

      final sessions = _sessionDates(plan.weekday, day);
      for (final ex in plan.exercises) {
        final exercise = await _exercises.findOrCreate(
          name: ex.name,
          muscleGroup: ex.muscleGroup,
          exerciseType: ex.type,
        );
        if (ex.description != null || ex.youTubeUrl != null) {
          await _exercises.updateDescriptionAndUrl(
              exercise.id, ex.description, ex.youTubeUrl);
        }
        final slot = await _planExercises.add(
          planId: created.id,
          exercise: exercise,
          sets: [
            for (var i = 0; i < ex.sets; i++)
              (
                reps: ex.reps,
                weight: ex.start,
                increment: ex.type == 'weighted' ? ex.increment : 0.0,
              ),
          ],
        );

        for (final (k, date) in sessions.indexed) {
          final note = (k + noteIndex) % 4 == 0
              ? _notes[(k + noteIndex) % _notes.length]
              : null;
          await _logSession(slot!, ex, k, sessions.length, date, note);
        }
        noteIndex++;
      }
    }

    await _quotes
        .create('The only bad workout is the one that didn\'t happen.');
    await _quotes.create('Strength doesn\'t come from what you can do. '
        'It comes from overcoming the things you once thought you couldn\'t.');
  }

  /// Every [weekday] in the last [weeks] weeks, oldest first, before [today].
  List<DateTime> _sessionDates(int weekday, DateTime today) {
    final back = (today.weekday - weekday + 7) % 7;
    var last = DateTime(today.year, today.month, today.day - back);
    if (!last.isBefore(today)) last = last.subtract(const Duration(days: 7));
    return [
      for (var w = weeks - 1; w >= 0; w--)
        DateTime(last.year, last.month, last.day - 7 * w),
    ];
  }

  /// Session [k] of [total]: targets go up every other session; every fifth
  /// session misses a couple of reps on the last set.
  Future<void> _logSession(PlanExerciseModel slot, _DemoExercise ex, int k,
      int total, DateTime date, String? note) async {
    final stalled = ex.stallRecently && k >= total - 3;
    final level = stalled ? (total - 4) ~/ 2 : k ~/ 2;
    final missLastSet = stalled || k % 5 == 4;

    final double weight;
    final int reps;
    switch (ex.type) {
      case 'bodyweight':
        weight = 0;
        reps = ex.reps + level;
      case 'timed':
        weight = 0;
        reps = ex.reps + 5 * level;
      default:
        weight = ex.start + ex.increment * level;
        reps = ex.reps;
    }

    await _logs.createOrReplace(
      exerciseId: slot.exerciseId,
      planExerciseId: slot.id,
      logDate: date,
      notes: note,
      sets: [
        for (var i = 0; i < ex.sets; i++)
          (
            plannedReps: reps,
            actualReps: missLastSet && i == ex.sets - 1
                ? (reps - 2).clamp(1, reps)
                : reps,
            plannedWeight: weight,
            actualWeight: weight,
            isCompleted: true,
          ),
      ],
    );
  }
}

class _DemoPlan {
  const _DemoPlan(this.name, this.weekday, this.exercises);

  final String name;
  final int weekday;
  final List<_DemoExercise> exercises;
}

class _DemoExercise {
  const _DemoExercise(
    this.name,
    this.muscleGroup, {
    this.type = 'weighted',
    required this.sets,
    required this.reps,
    this.start = 0,
    this.increment = 2.5,
    this.stallRecently = false,
    this.description,
    this.youTubeUrl,
  });

  final String name;
  final String muscleGroup;
  final String type;
  final int sets;

  /// Reps, or seconds for timed exercises.
  final int reps;

  /// Starting weight in kg (weighted exercises).
  final double start;
  final double increment;
  final bool stallRecently;
  final String? description;
  final String? youTubeUrl;
}
