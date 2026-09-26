import 'package:fit_forge/data/local/database_helper.dart';
import 'package:fit_forge/data/models/workout_log_model.dart';
import 'package:fit_forge/data/models/workout_set_model.dart';
import 'package:sqflite/sqflite.dart';

class WorkoutLogDao {
  WorkoutLogDao(this._helper);

  final DatabaseHelper _helper;

  Database get _db => _helper.database;

  /// History of an exercise across all plans, newest first.
  Future<List<WorkoutLogModel>> getByExercise(
    String exerciseId, {
    int limit = 10,
  }) async {
    final logRows = await _db.query(
      WorkoutLogModel.tableName,
      where: 'exercise_id = ?',
      whereArgs: [exerciseId],
      orderBy: 'log_date DESC, created_at DESC',
      limit: limit,
    );
    return _withSets(logRows);
  }

  Future<String> insert(WorkoutLogModel log) async {
    await _db.transaction((txn) async {
      await txn.insert(
        WorkoutLogModel.tableName,
        log.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      for (final s in log.sets) {
        await txn.insert(
          WorkoutSetModel.tableName,
          s.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
    return log.id;
  }

  Future<void> delete(String id) async {
    await _db.delete(
      WorkoutLogModel.tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Distinct dates (yyyy-MM-dd) with at least one logged workout.
  Future<Set<String>> getLoggedDates() async {
    final rows =
        await _db.rawQuery('SELECT DISTINCT substr(log_date, 1, 10) AS d '
            'FROM ${WorkoutLogModel.tableName}');
    return {for (final r in rows) r['d'] as String};
  }

  /// Completed sets logged today, keyed by plan exercise id.
  Future<Map<String, int>> getCompletedSetsToday(
      List<String> planExerciseIds) async {
    if (planExerciseIds.isEmpty) return {};
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final placeholders = planExerciseIds.map((_) => '?').join(',');
    final rows = await _db.rawQuery(
      '''
      SELECT l.plan_exercise_id, COUNT(s.id) as completed
      FROM ${WorkoutLogModel.tableName} l
      JOIN ${WorkoutSetModel.tableName} s ON s.log_id = l.id
      WHERE date(l.log_date) = ?
        AND l.plan_exercise_id IN ($placeholders)
        AND s.is_completed = 1
      GROUP BY l.plan_exercise_id
    ''',
      [today, ...planExerciseIds],
    );

    return {
      for (final row in rows)
        row['plan_exercise_id'] as String: (row['completed'] as int)
    };
  }

  Future<WorkoutLogModel?> getByPlanExerciseAndDate(
      String planExerciseId, String date) async {
    final logRows = await _db.query(
      WorkoutLogModel.tableName,
      where: 'plan_exercise_id = ? AND log_date = ?',
      whereArgs: [planExerciseId, date],
      limit: 1,
    );
    final logs = await _withSets(logRows);
    return logs.firstOrNull;
  }

  Future<List<WorkoutLogModel>> _withSets(
      List<Map<String, Object?>> logRows) async {
    if (logRows.isEmpty) return [];

    final logIds = logRows.map((r) => r['id'] as String).toList();
    final placeholders = logIds.map((_) => '?').join(',');
    final setRows = await _db.rawQuery('''
      SELECT * FROM ${WorkoutSetModel.tableName}
      WHERE log_id IN ($placeholders)
      ORDER BY log_id, set_number ASC
    ''', logIds);

    final setsByLog = <String, List<WorkoutSetModel>>{};
    for (final row in setRows) {
      setsByLog
          .putIfAbsent(row['log_id'] as String, () => [])
          .add(WorkoutSetModel.fromMap(row));
    }

    return [
      for (final row in logRows)
        WorkoutLogModel.fromMap(row).withSets(setsByLog[row['id']] ?? []),
    ];
  }
}
