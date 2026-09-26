import 'package:fit_forge/data/models/exercise_model.dart';
import 'package:fit_forge/data/models/workout_log_model.dart';
import 'package:fit_forge/data/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Exercises that have at least one logged workout.
final exercisesWithLogsProvider = FutureProvider<List<ExerciseModel>>((ref) {
  return ref.watch(exerciseRepositoryProvider).getWithLogs();
});

/// Full history of an exercise across all plans, newest first.
final exerciseHistoryProvider =
    FutureProvider.family<List<WorkoutLogModel>, String>((ref, exerciseId) {
  return ref
      .watch(workoutLogRepositoryProvider)
      .getByExercise(exerciseId, limit: 1000);
});
