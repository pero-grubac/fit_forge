import 'package:fit_forge/core/models/progression_suggestion.dart';
import 'package:fit_forge/core/utils/progression_calculator.dart';
import 'package:fit_forge/data/providers.dart';
import 'package:fit_forge/features/settings/providers/settings_provider.dart';
import 'package:fit_forge/features/workout_log/providers/workout_log_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Suggestion for a plan exercise. Uses the logs recorded from the same plan
/// slot when there are enough, so a heavy Monday and a light Thursday don't
/// mix; otherwise falls back to the whole history of the exercise.
const _bodyweightRepStep = 1;
const _timedSecondsStep = 5;

final progressionProvider =
    FutureProvider.family<ProgressionSuggestion, String>(
        (ref, planExerciseId) async {
  final planExercise =
      await ref.watch(planExerciseRepositoryProvider).getById(planExerciseId);
  if (planExercise == null) return ProgressionSuggestion.noData;

  final settings = await ref.watch(settingsProvider.future);
  final logs =
      await ref.watch(exerciseLogsProvider(planExercise.exerciseId).future);

  final slotLogs =
      logs.where((l) => l.planExerciseId == planExerciseId).toList();

  final calculator = ProgressionCalculator(
    smallIncrement: settings.smallIncrement,
    largeIncrement: settings.largeIncrement,
    threshold: settings.progressionThreshold,
  );
  final history =
      slotLogs.length >= ProgressionCalculator.historyNeeded ? slotLogs : logs;
  final exercise = planExercise.exercise;

  if (exercise.isBodyweight) {
    return calculator.calculateReps(history, step: _bodyweightRepStep);
  }
  if (exercise.isTimed) {
    return calculator.calculateReps(history,
        step: _timedSecondsStep, unit: ProgressionUnit.seconds);
  }
  return calculator.calculate(history, defaultSets: planExercise.defaultSets);
});
