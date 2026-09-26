import 'package:fit_forge/data/local/dao/plan_exercise_dao.dart';
import 'package:fit_forge/data/models/default_set_model.dart';
import 'package:fit_forge/data/models/exercise_model.dart';
import 'package:fit_forge/data/models/plan_exercise_model.dart';
import 'package:fit_forge/data/repositories/exercise_repository.dart';
import 'package:uuid/uuid.dart';

class PlanExerciseRepository {
  PlanExerciseRepository(this._dao, this._exercises);

  final PlanExerciseDao _dao;
  final ExerciseRepository _exercises;

  Future<List<PlanExerciseModel>> getByPlan(String planId) =>
      _dao.getByPlan(planId);

  Future<PlanExerciseModel?> getById(String id) => _dao.getById(id);

  /// Adds [exercise] to the plan with the given default sets. Returns null if
  /// the plan already contains the exercise.
  Future<PlanExerciseModel?> add({
    required String planId,
    required ExerciseModel exercise,
    required List<({int reps, double weight, double increment})> sets,
  }) async {
    if (await _dao.exists(planId, exercise.id)) return null;

    final id = const Uuid().v4();
    final planExercise = PlanExerciseModel(
      id: id,
      planId: planId,
      exercise: exercise,
      sortOrder: await _dao.nextSortOrder(planId),
      defaultSets: [
        for (final (i, s) in sets.indexed)
          DefaultSetModel(
            id: const Uuid().v4(),
            planExerciseId: id,
            setNumber: i + 1,
            reps: s.reps,
            weight: s.weight,
            increment: s.increment,
          ),
      ],
    );
    await _dao.insert(planExercise);
    return planExercise;
  }

  Future<void> updateSortOrder(String id, int sortOrder) =>
      _dao.updateSortOrder(id, sortOrder);

  /// Removes the exercise from the plan. Its history is kept.
  Future<void> remove(String id) async {
    await _dao.delete(id);
    await _exercises.deleteUnused();
  }
}
