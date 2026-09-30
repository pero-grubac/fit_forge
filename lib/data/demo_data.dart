import 'package:fit_forge/core/utils/set_progression.dart';
import 'package:fit_forge/data/local/database_helper.dart';
import 'package:fit_forge/data/models/exercise_model.dart';
import 'package:fit_forge/data/models/plan_exercise_model.dart';
import 'package:fit_forge/data/repositories/exercise_repository.dart';
import 'package:fit_forge/data/repositories/plan_exercise_repository.dart';
import 'package:fit_forge/data/repositories/quote_repository.dart';
import 'package:fit_forge/data/repositories/workout_log_repository.dart';
import 'package:fit_forge/data/repositories/workout_plan_repository.dart';

/// Fills the app with sample plans and a few weeks of workout history, so
/// every screen has something to show. Replaces all existing data.
///
/// The history follows the set-count progression rule, so what the app
/// suggests next matches what was "done" before.
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

  /// Sets before increase for demo exercises that don't set their own; the
  /// same as the default in Settings.
  static const defaultSetsToProgress = 8;

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
            setsToProgress: 6,
            description: 'Feet flat, shoulder blades squeezed together. '
                'Lower the bar to mid-chest and press up in a slight arc.',
            youTubeUrl: 'https://www.youtube.com/watch?v=rT7DgCr-3pg'),
        _DemoExercise('Incline Dumbbell Press', 'Chest',
            sets: 3, reps: 10, start: 20, increment: 2),
        // Keeps missing the last set lately, so its counter stays low.
        _DemoExercise('Overhead Press', 'Shoulders',
            sets: 3, reps: 8, start: 35, strugglingLately: true),
        _DemoExercise('Tricep Pushdown', 'Triceps',
            sets: 3, reps: 12, start: 25, increment: 5),
      ]),
      const _DemoPlan('Pull', DateTime.wednesday, [
        _DemoExercise('Pull Up', 'Bodyweight',
            type: 'bodyweight',
            sets: 3,
            reps: 5,
            setsToProgress: 6,
            description: 'Full hang at the bottom, chin over the bar at the '
                'top. No kipping.'),
        _DemoExercise('Barbell Row', 'Back', sets: 3, reps: 8, start: 50),
        // Auto increase turned off: the user raises it by hand.
        _DemoExercise('Barbell Curl', 'Biceps',
            sets: 3, reps: 10, start: 25, autoProgress: false),
      ]),
      const _DemoPlan('Legs', DateTime.friday, [
        _DemoExercise('Squat', 'Legs',
            sets: 3,
            reps: 5,
            start: 80,
            increment: 5,
            setsToProgress: 6,
            description: 'Brace before each rep, break at hips and knees '
                'together, hit depth and drive up through mid-foot.',
            youTubeUrl: 'https://www.youtube.com/watch?v=ultWZbUMPL8'),
        _DemoExercise('Romanian Deadlift', 'Back',
            sets: 3, reps: 8, start: 70, increment: 10),
        _DemoExercise('Plank', 'Core', type: 'timed', sets: 3, reps: 30),
      ]),
    ];

    // A plan for today when it isn't a Push/Pull/Legs day, so the home
    // screen is never empty. Bench Press and Squat are shared with the other
    // plans (lighter targets here) and show one combined history.
    if (!plans.any((p) => p.weekday == day.weekday)) {
      plans.add(_DemoPlan('Full Body', day.weekday, const [
        _DemoExercise('Bench Press', 'Chest',
            sets: 3, reps: 10, start: 50, setsToProgress: 6),
        _DemoExercise('Squat', 'Legs',
            sets: 3, reps: 10, start: 60, increment: 5, setsToProgress: 6),
        _DemoExercise('Plank', 'Core', type: 'timed', sets: 2, reps: 30),
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
        await _exercises.updateProgression(
          exercise.id,
          autoProgress: ex.autoProgress,
          increment: ex.increment,
          setsToProgress: ex.setsToProgress,
        );
        final slot = await _planExercises.add(
          planId: created.id,
          exercise: exercise,
          sets: [
            for (var i = 0; i < ex.sets; i++)
              (reps: ex.reps, weight: ex.start, increment: 0.0),
          ],
        );

        await _logHistory(slot!, ex, sessions, noteIndex);
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

  /// Logs one session per date, following the progression rule. Every fifth
  /// session misses two reps on the last set (which resets the counter);
  /// "struggling" exercises miss it in the last three sessions too.
  Future<void> _logHistory(PlanExerciseModel slot, _DemoExercise ex,
      List<DateTime> dates, int noteOffset) async {
    final byReps = ex.type != 'weighted';
    final rule = SetProgression(
      setsToProgress: ex.setsToProgress ?? defaultSetsToProgress,
      increment: ex.increment ?? ExerciseModel.defaultIncrementFor(ex.type),
    );
    final start = byReps ? ex.reps.toDouble() : ex.start;
    final history = <Session>[];
    var manualLevel = start;

    for (final (k, date) in dates.indexed) {
      final missLast =
          k % 5 == 4 || (ex.strugglingLately && k >= dates.length - 3);
      // Without auto increase, the user bumps the weight every 3rd session.
      if (!ex.autoProgress && k > 0 && k % 3 == 0) {
        manualLevel += rule.increment;
      }
      final levels = ex.autoProgress
          ? rule.planSession(
              rule.status(history, start: start, plannedSets: ex.sets), ex.sets)
          : List.filled(ex.sets, manualLevel);

      final sets = <LoggedSet>[];
      final session = <PerformedSet>[];
      for (final (i, level) in levels.indexed) {
        final planned = byReps ? level.round() : ex.reps;
        final missed = missLast && i == ex.sets - 1;
        final done = missed ? (planned - 2).clamp(0, planned) : planned;
        sets.add((
          plannedReps: planned,
          actualReps: done,
          plannedWeight: byReps ? 0.0 : level,
          actualWeight: byReps ? 0.0 : level,
          isCompleted: true,
        ));
        session.add((level: level, success: !missed));
      }
      history.add(session);

      await _logs.createOrReplace(
        exerciseId: slot.exerciseId,
        planExerciseId: slot.id,
        logDate: date,
        notes: (k + noteOffset) % 4 == 0
            ? _notes[(k + noteOffset) % _notes.length]
            : null,
        sets: sets,
      );
    }
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
    this.increment,
    this.setsToProgress,
    this.autoProgress = true,
    this.strugglingLately = false,
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

  /// Null uses the default (2.5 kg / 1 rep / 5 s).
  final double? increment;
  final int? setsToProgress;
  final bool autoProgress;
  final bool strugglingLately;
  final String? description;
  final String? youTubeUrl;
}
