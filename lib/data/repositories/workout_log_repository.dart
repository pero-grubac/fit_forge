import 'package:fit_forge/data/local/dao/workout_log_dao.dart';
import 'package:fit_forge/data/models/workout_log_model.dart';
import 'package:fit_forge/data/models/workout_set_model.dart';
import 'package:uuid/uuid.dart';

typedef LoggedSet = ({
  int plannedReps,
  int actualReps,
  double plannedWeight,
  double actualWeight,
  bool isCompleted,
});

class WorkoutLogRepository {
  WorkoutLogRepository(this._logDao);

  final WorkoutLogDao _logDao;

  /// History of an exercise across all plans, newest first.
  Future<List<WorkoutLogModel>> getByExercise(
    String exerciseId, {
    int limit = 10,
  }) =>
      _logDao.getByExercise(exerciseId, limit: limit);

  /// Logs recorded from one plan slot, newest first.
  Future<List<WorkoutLogModel>> getByPlanExercise(
    String planExerciseId, {
    int limit = 50,
  }) =>
      _logDao.getByPlanExercise(planExerciseId, limit: limit);

  Future<void> delete(String id) => _logDao.delete(id);

  /// Distinct dates (yyyy-MM-dd) with at least one logged workout.
  Future<Set<String>> getLoggedDates() => _logDao.getLoggedDates();

  Future<Map<String, int>> getCompletedSetsToday(
          List<String> planExerciseIds) =>
      _logDao.getCompletedSetsToday(planExerciseIds);

  Future<WorkoutLogModel?> getForPlanExerciseOn(
          String planExerciseId, DateTime date) =>
      _logDao.getByPlanExerciseAndDate(
          planExerciseId, date.toIso8601String().substring(0, 10));

  /// Saves the session, replacing an earlier log of the same plan exercise
  /// on the same day.
  Future<WorkoutLogModel> createOrReplace({
    required String exerciseId,
    required String planExerciseId,
    required DateTime logDate,
    String? notes,
    required List<LoggedSet> sets,
  }) async {
    final existing = await getForPlanExerciseOn(planExerciseId, logDate);
    if (existing != null) {
      await _logDao.delete(existing.id);
    }

    final logId = const Uuid().v4();
    final log = WorkoutLogModel.create(
      id: logId,
      exerciseId: exerciseId,
      planExerciseId: planExerciseId,
      logDate: logDate,
      notes: notes,
      sets: [
        for (final (i, s) in sets.indexed)
          WorkoutSetModel(
            id: const Uuid().v4(),
            logId: logId,
            setNumber: i + 1,
            plannedReps: s.plannedReps,
            actualReps: s.actualReps,
            plannedWeight: s.plannedWeight,
            actualWeight: s.actualWeight,
            isCompleted: s.isCompleted,
          ),
      ],
    );

    await _logDao.insert(log);
    return log;
  }
}
