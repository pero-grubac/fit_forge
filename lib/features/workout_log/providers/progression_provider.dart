import 'package:fit_forge/core/utils/set_progression.dart';
import 'package:fit_forge/data/models/exercise_model.dart';
import 'package:fit_forge/data/providers.dart';
import 'package:fit_forge/features/settings/providers/settings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Progression setup for one plan exercise.
class ProgressionInfo {
  const ProgressionInfo({
    required this.enabled,
    required this.unit,
    required this.rule,
    required this.status,
  });

  /// Off when disabled in Settings or for this exercise.
  final bool enabled;
  final ProgressionUnit unit;
  final SetProgression rule;

  /// Where progression stands after all earlier workouts from this plan
  /// (today excluded): counting good sets, or moving up to a new level.
  final ProgressionStatus status;
}

/// The rule and counter for a plan exercise. The counter is kept per plan
/// slot, so a heavy Monday and a light Thursday don't mix.
final progressionProvider = FutureProvider.family<ProgressionInfo?, String>(
    (ref, planExerciseId) async {
  final planExercise =
      await ref.watch(planExerciseRepositoryProvider).getById(planExerciseId);
  if (planExercise == null) return null;
  final settings = await ref.watch(settingsProvider.future);
  final exercise = planExercise.exercise;

  final unit = switch (exercise.exerciseType) {
    'bodyweight' => ProgressionUnit.reps,
    'timed' => ProgressionUnit.seconds,
    _ => ProgressionUnit.kg,
  };
  final byReps = unit != ProgressionUnit.kg;
  final rule = SetProgression(
    setsToProgress: exercise.setsToProgress ?? settings.setsToProgress,
    increment: exercise.increment ??
        (byReps
            ? ExerciseModel.defaultIncrementFor(exercise.exerciseType)
            : settings.defaultIncrement),
  );

  final today = DateTime.now().toIso8601String().substring(0, 10);
  final logs = await ref
      .watch(workoutLogRepositoryProvider)
      .getByPlanExercise(planExerciseId);
  final earlier = logs
      .where((l) => l.logDate.toIso8601String().substring(0, 10) != today)
      .toList()
      .reversed;

  final first = planExercise.defaultSets.firstOrNull;
  final start = byReps ? (first?.reps ?? 0).toDouble() : (first?.weight ?? 0);

  return ProgressionInfo(
    enabled: settings.autoProgression && exercise.autoProgress,
    unit: unit,
    rule: rule,
    status: rule.status(
      SetProgression.sessionsFromLogs(earlier, byReps: byReps),
      start: start,
      plannedSets: planExercise.defaultSets.isEmpty
          ? 3
          : planExercise.defaultSets.length,
    ),
  );
});
