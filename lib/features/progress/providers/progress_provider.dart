import 'package:fit_forge/data/models/workout_log_model.dart';
import 'package:fit_forge/data/repositories/workout_log_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _logRepo = WorkoutLogRepository();

final progressLogsProvider =
    FutureProvider.family<List<WorkoutLogModel>, String>((ref, exerciseId) {
  return _logRepo.getByExercise(exerciseId, limit: 50);
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
