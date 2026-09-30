import 'dart:io';

import 'package:fit_forge/data/local/dao/exercise_dao.dart';
import 'package:fit_forge/data/models/exercise_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// The global exercise catalogue.
class ExerciseRepository {
  ExerciseRepository(this._exerciseDao, {ImagePicker? picker})
      : _picker = picker ?? ImagePicker();

  final ExerciseDao _exerciseDao;
  final ImagePicker _picker;

  Future<ExerciseModel?> getById(String id) => _exerciseDao.getById(id);

  Future<List<ExerciseModel>> getAll() => _exerciseDao.getAll();

  Future<List<ExerciseModel>> getWithLogs() => _exerciseDao.getWithLogs();

  Future<int> countPlans(String id) => _exerciseDao.countPlans(id);

  /// Returns the exercise with this name (case-insensitive), creating it if
  /// it doesn't exist yet.
  Future<ExerciseModel> findOrCreate({
    required String name,
    required String muscleGroup,
    String exerciseType = 'weighted',
  }) async {
    final existing = await _exerciseDao.findByName(name);
    if (existing != null) return existing;

    final exercise = ExerciseModel(
      id: const Uuid().v4(),
      name: name.trim(),
      muscleGroup: muscleGroup,
      exerciseType: exerciseType,
      createdAt: DateTime.now(),
    );
    await _exerciseDao.insert(exercise);
    return exercise;
  }

  Future<String?> pickAndSaveImage(
      String exerciseId, ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
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
    await _deleteFile(imagePath);
    await _exerciseDao.updateImagePath(exerciseId, null);
  }

  Future<void> updateDescriptionAndUrl(
          String id, String? description, String? youTubeUrl) =>
      _exerciseDao.updateDescriptionAndUrl(id, description, youTubeUrl);

  Future<void> updateMuscleGroup(String id, String muscleGroup) =>
      _exerciseDao.updateMuscleGroup(id, muscleGroup);

  /// Progression settings, shared by every plan with this exercise.
  Future<void> updateProgression(
    String id, {
    required bool autoProgress,
    required double? increment,
    required int? setsToProgress,
  }) =>
      _exerciseDao.updateProgression(id,
          autoProgress: autoProgress,
          increment: increment,
          setsToProgress: setsToProgress);

  /// Deletes the exercise from every plan, together with its history.
  Future<void> delete(ExerciseModel exercise) async {
    await _exerciseDao.delete(exercise.id);
    if (exercise.imagePath != null) await _deleteFile(exercise.imagePath!);
  }

  /// Removes exercises that are in no plan and have no history.
  Future<void> deleteUnused() async {
    final images = await _exerciseDao.deleteUnused();
    for (final path in images) {
      await _deleteFile(path);
    }
  }

  Future<void> _deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}
