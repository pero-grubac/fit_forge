import 'package:fit_forge/data/models/workout_log_model.dart';
import 'package:fit_forge/data/repositories/workout_log_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _logRepo = WorkoutLogRepository();

final exerciseLogsProvider =
    FutureProvider.family<List<WorkoutLogModel>, String>((ref, exerciseId) {
  return _logRepo.getByExercise(exerciseId);
});

final completedSetsTodayProvider =
FutureProvider.family<Map<String, int>, String>((ref, exerciseIdsJoined) {
  final ids = exerciseIdsJoined.isEmpty
      ? <String>[]
      : exerciseIdsJoined.split(',');
  return WorkoutLogRepository().getCompletedSetsToday(ids);
});

class WorkoutLogNotifier extends AsyncNotifier<void> {
  final _repo = WorkoutLogRepository();

  @override
  Future<void> build() async {}

  Future<WorkoutLogModel> logWorkout({
    required String exerciseId,
    required DateTime logDate,
    String? notes,
    required List<
            ({
              int plannedReps,
              int actualReps,
              double plannedWeight,
              double actualWeight,
              bool isCompleted,
            })>
        sets,
  }) async {
    state = const AsyncLoading();
    final log = await AsyncValue.guard(() => _repo.create(
          exerciseId: exerciseId,
          logDate: logDate,
          notes: notes,
          sets: sets,
        ));
    state = const AsyncData(null);

    ref.invalidate(exerciseLogsProvider(exerciseId));

    return log.value!;
  }
}

final workoutLogNotifierProvider =
    AsyncNotifierProvider<WorkoutLogNotifier, void>(WorkoutLogNotifier.new);
