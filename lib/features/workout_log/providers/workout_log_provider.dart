import 'package:fit_forge/data/models/plan_exercise_model.dart';
import 'package:fit_forge/data/models/workout_log_model.dart';
import 'package:fit_forge/data/providers.dart';
import 'package:fit_forge/data/repositories/workout_log_repository.dart';
import 'package:fit_forge/features/progress/providers/progress_provider.dart';
import 'package:fit_forge/features/workout_log/providers/streak_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Recent history of an exercise across all plans, newest first.
final exerciseLogsProvider =
    FutureProvider.family<List<WorkoutLogModel>, String>((ref, exerciseId) {
  return ref.watch(workoutLogRepositoryProvider).getByExercise(exerciseId);
});

/// Completed sets today, keyed by plan exercise id. The argument is the
/// comma-joined plan exercise ids.
final completedSetsTodayProvider =
    FutureProvider.family<Map<String, int>, String>((ref, planExerciseIds) {
  final ids = planExerciseIds.isEmpty ? <String>[] : planExerciseIds.split(',');
  return ref.watch(workoutLogRepositoryProvider).getCompletedSetsToday(ids);
});

class WorkoutLogNotifier extends AsyncNotifier<void> {
  WorkoutLogRepository get _repo => ref.read(workoutLogRepositoryProvider);

  @override
  Future<void> build() async {}

  /// Returns the saved log, or null if saving failed (state holds the error).
  Future<WorkoutLogModel?> logWorkout({
    required PlanExerciseModel planExercise,
    required DateTime logDate,
    String? notes,
    required List<LoggedSet> sets,
  }) async {
    state = const AsyncLoading();
    final log = await AsyncValue.guard(() => _repo.createOrReplace(
          exerciseId: planExercise.exerciseId,
          planExerciseId: planExercise.id,
          logDate: logDate,
          notes: notes,
          sets: sets,
        ));
    if (log.hasError) {
      state = AsyncError(log.error!, log.stackTrace!);
      return null;
    }
    state = const AsyncData(null);

    ref.invalidate(exerciseLogsProvider(planExercise.exerciseId));
    ref.invalidate(exerciseHistoryProvider(planExercise.exerciseId));
    ref.invalidate(exercisesWithLogsProvider);
    ref.invalidate(streakProvider);

    return log.value;
  }
}

final workoutLogNotifierProvider =
    AsyncNotifierProvider<WorkoutLogNotifier, void>(WorkoutLogNotifier.new);
