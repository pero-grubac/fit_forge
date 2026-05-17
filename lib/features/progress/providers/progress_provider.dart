import 'package:fit_forge/data/models/workout_log_model.dart';
import 'package:fit_forge/data/repositories/exercise_repository.dart';
import 'package:fit_forge/data/repositories/workout_log_repository.dart';
import 'package:fit_forge/features/workout_plan/providers/workout_plan_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final progressLogsProvider =
    FutureProvider.family<List<WorkoutLogModel>, String>((ref, exerciseId) {
  return WorkoutLogRepository().getByExercise(exerciseId, limit: 50);
});

final maxWeightProvider =
    FutureProvider.family<double, String>((ref, exerciseId) async {
  final logs = await ref.watch(progressLogsProvider(exerciseId).future);
  if (logs.isEmpty) return 0.0;
  return logs
      .expand((log) => log.sets)
      .where((s) => s.isCompleted)
      .map((s) => s.actualWeight)
      .fold<double>(0.0, (max, w) => w > max ? w : max);
});

final exerciseLogsByNameProvider =
    FutureProvider.family<List<WorkoutLogModel>, String>(
        (ref, exerciseName) async {
  final plans = await ref.watch(workoutPlanNotifierProvider.future);
  final allLogs = <WorkoutLogModel>[];

  for (final plan in plans) {
    final exercises = await ExerciseRepository().getByPlan(plan.id);
    final matching = exercises
        .where((ex) => ex.name.toLowerCase() == exerciseName.toLowerCase());
    for (final ex in matching) {
      final logs = await WorkoutLogRepository().getByExercise(ex.id, limit: 50);
      allLogs.addAll(logs);
    }
  }

  allLogs.sort((a, b) => b.logDate.compareTo(a.logDate));
  return allLogs;
});
