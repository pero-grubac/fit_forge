import 'package:uuid/uuid.dart';

import '../local/dao/exercise_dao.dart';
import '../models/default_set_model.dart';
import '../models/exercise_model.dart';

class ExerciseRepository {
  final _exerciseDao = ExerciseDao();

  Future<List<ExerciseModel>> getByPlan(String planId) =>
      _exerciseDao.getByPlan(planId);

  Future<ExerciseModel?> getById(String id) => _exerciseDao.getById(id);

  Future<ExerciseModel> create({
    required String planId,
    required String name,
    required String muscleGroup,
    String? description,
    String? youTubeUrl,
    required int sortOrder,
    required List<({int reps, double weight, double increment})> sets,
  }) async {
    final id = const Uuid().v4();
    final defaultSets = sets.indexed
        .map((e) => DefaultSetModel(
              id: const Uuid().v4(),
              exerciseId: id,
              setNumber: e.$1 + 1,
              reps: e.$2.reps,
              weight: e.$2.weight,
              increment: e.$2.increment,
            ))
        .toList();

    final exercise = ExerciseModel(
      id: id,
      planId: planId,
      name: name,
      muscleGroup: muscleGroup,
      description: description,
      youTubeUrl: youTubeUrl,
      sortOrder: sortOrder,
      createdAt: DateTime.now(),
      defaultSets: defaultSets,
    );

    await _exerciseDao.insert(exercise);
    return exercise;
  }

  Future<void> update(ExerciseModel exercise) => _exerciseDao.update(exercise);

  Future<void> updateImagePath(String id, String? imagePath) =>
      _exerciseDao.updateImagePath(id, imagePath);

  Future<void> updateSortOrder(String id, int sortOrder) =>
      _exerciseDao.updateSortOrder(id, sortOrder);

  Future<void> delete(String id) => _exerciseDao.delete(id);
}
