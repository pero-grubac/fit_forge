import 'package:fit_forge/data/local/database_helper.dart';
import 'package:fit_forge/data/models/exercise_model.dart';
import 'package:fit_forge/data/models/plan_exercise_model.dart';
import 'package:fit_forge/data/models/workout_log_model.dart';
import 'package:sqflite/sqflite.dart';

/// The global exercise catalogue.
class ExerciseDao {
  ExerciseDao(this._helper);

  final DatabaseHelper _helper;

  Database get _db => _helper.database;

  Future<ExerciseModel?> getById(String id) async {
    final rows = await _db.query(
      ExerciseModel.tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : ExerciseModel.fromMap(rows.first);
  }

  /// Case-insensitive lookup; names are unique.
  Future<ExerciseModel?> findByName(String name) async {
    final rows = await _db.query(
      ExerciseModel.tableName,
      where: 'name = ? COLLATE NOCASE',
      whereArgs: [name.trim()],
      limit: 1,
    );
    return rows.isEmpty ? null : ExerciseModel.fromMap(rows.first);
  }

  Future<List<ExerciseModel>> getAll() async {
    final rows = await _db.query(
      ExerciseModel.tableName,
      orderBy: 'name COLLATE NOCASE',
    );
    return rows.map(ExerciseModel.fromMap).toList();
  }

  /// Exercises with at least one logged workout.
  Future<List<ExerciseModel>> getWithLogs() async {
    final rows = await _db.rawQuery('''
      SELECT e.* FROM ${ExerciseModel.tableName} e
      WHERE EXISTS (
        SELECT 1 FROM ${WorkoutLogModel.tableName} l WHERE l.exercise_id = e.id
      )
      ORDER BY e.name COLLATE NOCASE
    ''');
    return rows.map(ExerciseModel.fromMap).toList();
  }

  /// Number of plans that include the exercise.
  Future<int> countPlans(String id) async {
    final rows = await _db.rawQuery(
      'SELECT COUNT(*) AS n FROM ${PlanExerciseModel.tableName} '
      'WHERE exercise_id = ?',
      [id],
    );
    return rows.first['n'] as int;
  }

  Future<void> insert(ExerciseModel exercise) async {
    await _db.insert(ExerciseModel.tableName, exercise.toMap());
  }

  Future<void> updateImagePath(String id, String? imagePath) async {
    await _db.update(
      ExerciseModel.tableName,
      {'image_path': imagePath},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateDescriptionAndUrl(
      String id, String? description, String? youTubeUrl) async {
    await _db.update(
      ExerciseModel.tableName,
      {'description': description, 'youtube_url': youTubeUrl},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateMuscleGroup(String id, String muscleGroup) async {
    await _db.update(
      ExerciseModel.tableName,
      {'muscle_group': muscleGroup},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateProgression(
    String id, {
    required bool autoProgress,
    required double? increment,
    required int? setsToProgress,
  }) async {
    await _db.update(
      ExerciseModel.tableName,
      {
        'auto_progress': autoProgress ? 1 : 0,
        'increment': increment,
        'sets_to_progress': setsToProgress,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Deletes the exercise everywhere: its history, its place in every plan
  /// (default sets cascade) and the exercise itself.
  Future<void> delete(String id) async {
    await _db.transaction((txn) async {
      await txn.delete(
        WorkoutLogModel.tableName,
        where: 'exercise_id = ?',
        whereArgs: [id],
      );
      await txn.delete(
        PlanExerciseModel.tableName,
        where: 'exercise_id = ?',
        whereArgs: [id],
      );
      await txn.delete(
        ExerciseModel.tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  /// Removes exercises that are in no plan and have no history. Returns the
  /// image paths of the removed exercises so the files can be deleted.
  Future<List<String>> deleteUnused() async {
    const unused = '''
      NOT EXISTS (SELECT 1 FROM ${PlanExerciseModel.tableName} pe
                  WHERE pe.exercise_id = ${ExerciseModel.tableName}.id)
      AND NOT EXISTS (SELECT 1 FROM ${WorkoutLogModel.tableName} l
                      WHERE l.exercise_id = ${ExerciseModel.tableName}.id)
    ''';
    return _db.transaction((txn) async {
      final rows = await txn.query(
        ExerciseModel.tableName,
        columns: ['image_path'],
        where: '$unused AND image_path IS NOT NULL',
      );
      await txn.delete(ExerciseModel.tableName, where: unused);
      return [for (final r in rows) r['image_path'] as String];
    });
  }
}
