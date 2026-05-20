import 'dart:io';

import 'package:fit_forge/data/local/dao/exercise_dao.dart';
import 'package:fit_forge/data/models/default_set_model.dart';
import 'package:fit_forge/data/models/exercise_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ExerciseRepository {
  final _exerciseDao = ExerciseDao();
  final _picker = ImagePicker();

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

  Future<String?> pickAndSaveImage(String exerciseId) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (picked == null) return null;

    final appDir = await getApplicationDocumentsDirectory();
    final fileName =
        'exercise_${exerciseId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final saved = await File(picked.path).copy('${appDir.path}/$fileName');

    await _exerciseDao.updateImagePath(exerciseId, saved.path);
    return saved.path;
  }

  Future<void> removeImage(String exerciseId, String imagePath) async {
    final file = File(imagePath);
    if (await file.exists()) await file.delete();
    await _exerciseDao.updateImagePath(exerciseId, null);
  }

  Future<void> updateDescriptionAndUrl(
          String id, String? description, String? youTubeUrl) =>
      _exerciseDao.updateDescriptionAndUrl(id, description, youTubeUrl);
}
