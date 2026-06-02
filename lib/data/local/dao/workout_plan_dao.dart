import 'package:fit_forge/data/local/database_helper.dart';
import 'package:fit_forge/data/models/exercise_model.dart';
import 'package:fit_forge/data/models/workout_log_model.dart';
import 'package:fit_forge/data/models/workout_plan_model.dart';
import 'package:sqflite/sqflite.dart';

class WorkoutPlanDao {
  Database get _db => DatabaseHelper.instance.database;

  Future<List<WorkoutPlanModel>> getAll() async {
    final rows = await _db.query(
      WorkoutPlanModel.tableName,
      orderBy: 'day_of_week ASC',
    );
    return rows.map(WorkoutPlanModel.fromMap).toList();
  }

  Future<WorkoutPlanModel?> getByDay(int dayOfWeek) async {
    final rows = await _db.query(
      WorkoutPlanModel.tableName,
      where: 'day_of_week = ? AND is_active = 1',
      whereArgs: [dayOfWeek],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return WorkoutPlanModel.fromMap(rows.first);
  }

  Future<WorkoutPlanModel?> getById(String id) async {
    final rows = await _db.query(
      WorkoutPlanModel.tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return WorkoutPlanModel.fromMap(rows.first);
  }

  Future<void> insert(WorkoutPlanModel plan) async {
    await _db.insert(
      WorkoutPlanModel.tableName,
      plan.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> update(WorkoutPlanModel plan) async {
    await _db.update(
      WorkoutPlanModel.tableName,
      plan.toMap(),
      where: 'id = ?',
      whereArgs: [plan.id],
    );
  }

  Future<void> delete(String id) async {
    await _db.transaction((txn) async {
      final exerciseRows = await txn.query(
        ExerciseModel.tableName,
        columns: ['id'],
        where: 'plan_id = ?',
        whereArgs: [id],
      );
      final exerciseIds = exerciseRows.map((r) => r['id'] as String).toList();

      if (exerciseIds.isNotEmpty) {
        final placeholders = exerciseIds.map((_) => '?').join(',');
        await txn.rawDelete(
          'DELETE FROM ${WorkoutLogModel.tableName} WHERE exercise_id IN ($placeholders)',
          exerciseIds,
        );
      }

      await txn.delete(
        ExerciseModel.tableName,
        where: 'plan_id = ?',
        whereArgs: [id],
      );

      await txn.delete(
        WorkoutPlanModel.tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  Future<void> updateName(String id, String name) async {
    await _db.update(
      WorkoutPlanModel.tableName,
      {'name': name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
