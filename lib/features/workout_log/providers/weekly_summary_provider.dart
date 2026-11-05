import 'package:fit_forge/core/utils/set_progression.dart';
import 'package:fit_forge/data/models/workout_log_model.dart';
import 'package:fit_forge/data/providers.dart';
import 'package:fit_forge/features/progress/providers/progress_provider.dart';
import 'package:fit_forge/features/workout_log/providers/rest_timer_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// This week so far vs the same days of last week, across every exercise.
class WeeklySummary {
  const WeeklySummary({required this.volumeChangePercent, required this.newPrCount});

  /// Null when there's no volume on the same days last week to compare to.
  final double? volumeChangePercent;

  /// Exercises whose best weight/reps/seconds this week beats everything
  /// logged before this week.
  final int newPrCount;

  bool get isEmpty => volumeChangePercent == null && newPrCount == 0;
}

/// Null when nothing has been logged this week at all. Recomputed whenever
/// [exercisesWithLogsProvider] is invalidated (a saved workout, demo data,
/// an import or a reset).
final weeklySummaryProvider = FutureProvider<WeeklySummary?>((ref) async {
  final exercises = await ref.watch(exercisesWithLogsProvider.future);
  if (exercises.isEmpty) return null;
  final logRepo = ref.watch(workoutLogRepositoryProvider);

  final today = ref.watch(clockProvider)();
  final startOfToday = DateTime(today.year, today.month, today.day);
  // Monday starts the week; DateTime.weekday is 1 (Mon) .. 7 (Sun).
  final weekStart = startOfToday.subtract(Duration(days: today.weekday - 1));
  final prevWeekStart = weekStart.subtract(const Duration(days: 7));

  final logsByExercise = [
    for (final exercise in exercises)
      (
        unit: exercise.progressionUnit,
        logs: await logRepo.getByExercise(exercise.id, limit: 1000),
      ),
  ];

  bool thisWeek(WorkoutLogModel log) => !log.logDate.isBefore(weekStart);

  // Compare up to the last day trained this week, against the same days of
  // last week. A whole last week against a few days of this one would
  // always look like a drop early in the week.
  DateTime? lastDayThisWeek;
  for (final (unit: _, :logs) in logsByExercise) {
    for (final log in logs.where(thisWeek)) {
      if (lastDayThisWeek == null || log.logDate.isAfter(lastDayThisWeek)) {
        lastDayThisWeek = log.logDate;
      }
    }
  }
  if (lastDayThisWeek == null) return null;
  final lastWeekEnd = lastDayThisWeek.subtract(const Duration(days: 7));

  var thisWeekVolume = 0.0;
  var lastWeekVolume = 0.0;
  var newPrCount = 0;

  for (final (:unit, :logs) in logsByExercise) {
    var bestBefore = 0.0;
    var bestThisWeek = 0.0;
    for (final log in logs) {
      final completed = log.sets.where((s) => s.isCompleted);
      if (completed.isEmpty) continue;
      final best = unit == ProgressionUnit.kg
          ? completed.map((s) => s.actualWeight).fold(0.0, (m, v) => v > m ? v : m)
          : completed
              .map((s) => s.actualReps.toDouble())
              .fold(0.0, (m, v) => v > m ? v : m);

      if (thisWeek(log)) {
        thisWeekVolume += log.totalVolume;
        if (best > bestThisWeek) bestThisWeek = best;
      } else {
        if (!log.logDate.isBefore(prevWeekStart) &&
            !log.logDate.isAfter(lastWeekEnd)) {
          lastWeekVolume += log.totalVolume;
        }
        if (best > bestBefore) bestBefore = best;
      }
    }
    if (bestThisWeek > 0 && bestThisWeek > bestBefore) newPrCount++;
  }

  final volumeChange = lastWeekVolume == 0
      ? null
      : ((thisWeekVolume - lastWeekVolume) / lastWeekVolume) * 100;
  return WeeklySummary(volumeChangePercent: volumeChange, newPrCount: newPrCount);
});
