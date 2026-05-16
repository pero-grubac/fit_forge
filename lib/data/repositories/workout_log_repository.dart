import 'package:fit_forge/data/local/dao/workout_log_dao.dart';
import 'package:fit_forge/data/models/workout_log_model.dart';
import 'package:fit_forge/data/models/workout_set_model.dart';
import 'package:uuid/uuid.dart';

class WorkoutLogRepository {
  final _logDao = WorkoutLogDao();

  Future<List<WorkoutLogModel>> getByExercise(
    String exerciseId, {
    int limit = 10,
  }) =>
      _logDao.getByExercise(exerciseId, limit: limit);

  Future<WorkoutLogModel?> getById(String id) => _logDao.getById(id);

  Future<bool> hasLogToday(String exerciseId) =>
      _logDao.hasLogToday(exerciseId);

  Future<WorkoutLogModel> create({
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
    final logId = const Uuid().v4();

    final workoutSets = sets.indexed
        .map((e) => WorkoutSetModel(
              id: const Uuid().v4(),
              logId: logId,
              setNumber: e.$1 + 1,
              plannedReps: e.$2.plannedReps,
              actualReps: e.$2.actualReps,
              plannedWeight: e.$2.plannedWeight,
              actualWeight: e.$2.actualWeight,
              isCompleted: e.$2.isCompleted,
            ))
        .toList();

    final log = WorkoutLogModel.create(
      id: logId,
      exerciseId: exerciseId,
      logDate: logDate,
      notes: notes,
      sets: workoutSets,
    );

    await _logDao.insert(log);
    return log;
  }

  Future<void> delete(String id) => _logDao.delete(id);

  Future<Map<String, int>> getCompletedSetsToday(List<String> exerciseIds) =>
      _logDao.getCompletedSetsToday(exerciseIds);
}
