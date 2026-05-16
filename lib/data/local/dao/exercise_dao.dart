import 'package:fit_forge/data/local/dao/default_set_dao.dart';
import 'package:fit_forge/data/local/database_helper.dart';
import 'package:fit_forge/data/models/default_set_model.dart';
import 'package:fit_forge/data/models/exercise_model.dart';
import 'package:sqflite/sqflite.dart';

class ExerciseDao {
  Database get _db => DatabaseHelper.instance.database;
  final _defaultSetDao = DefaultSetDao();

  Future<List<ExerciseModel>> getByPlan(String planId) async {
    final exerciseRows = await _db.query(
      ExerciseModel.tableName,
      where: 'plan_id = ?',
      whereArgs: [planId],
      orderBy: 'sort_order ASC',
    );

    final exercises = <ExerciseModel>[];
    for (final row in exerciseRows) {
      final defaultSets =
          await _defaultSetDao.getDefaultSets(row['id'] as String);
      exercises
          .add(ExerciseModel.fromMap(row).copyWith(defaultSets: defaultSets));
    }
    return exercises;
  }

  Future<ExerciseModel?> getById(String id) async {
    final rows = await _db.query(
      ExerciseModel.tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final defaultSets = await _defaultSetDao.getDefaultSets(id);
    return ExerciseModel.fromMap(rows.first).copyWith(defaultSets: defaultSets);
  }

  Future<void> insert(ExerciseModel exercise) async {
    await _db.transaction((txn) async {
      await txn.insert(
        ExerciseModel.tableName,
        exercise.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      for (final s in exercise.defaultSets) {
        await txn.insert(
          DefaultSetModel.tableName,
          s.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> update(ExerciseModel exercise) async {
    await _db.transaction((txn) async {
      await txn.update(
        ExerciseModel.tableName,
        exercise.toMap(),
        where: 'id = ?',
        whereArgs: [exercise.id],
      );
      await txn.delete(
        DefaultSetModel.tableName,
        where: 'exercise_id = ?',
        whereArgs: [exercise.id],
      );
      for (final s in exercise.defaultSets) {
        await txn.insert(
          DefaultSetModel.tableName,
          s.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> updateImagePath(String id, String? imagePath) async {
    await _db.update(
      ExerciseModel.tableName,
      {'image_path': imagePath},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateSortOrder(String id, int sortOrder) async {
    await _db.update(
      ExerciseModel.tableName,
      {'sort_order': sortOrder},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> delete(String id) async {
    await _db.delete(
      ExerciseModel.tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
