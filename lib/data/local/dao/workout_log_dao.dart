import 'package:fit_forge/data/local/database_helper.dart';
import 'package:fit_forge/data/models/workout_log_model.dart';
import 'package:fit_forge/data/models/workout_set_model.dart';
import 'package:sqflite/sqflite.dart';

class WorkoutLogDao {
  Database get _db => DatabaseHelper.instance.database;

  Future<List<WorkoutLogModel>> getByExercise(
    String exerciseId, {
    int limit = 10,
  }) async {
    final rows = await _db.rawQuery('''
      SELECT l.*,
             s.id        AS s_id,
             s.set_number,
             s.planned_reps,
             s.actual_reps,
             s.planned_weight,
             s.actual_weight,
             s.is_completed
      FROM ${WorkoutLogModel.tableName} l
      LEFT JOIN workout_sets s ON s.log_id = l.id
      WHERE l.exercise_id = ?
      ORDER BY l.log_date DESC, s.set_number ASC
      LIMIT ?
    ''', [exerciseId, limit]);

    return _groupRows(rows);
  }

  Future<WorkoutLogModel?> getById(String id) async {
    final rows = await _db.rawQuery('''
      SELECT l.*,
             s.id        AS s_id,
             s.set_number,
             s.planned_reps,
             s.actual_reps,
             s.planned_weight,
             s.actual_weight,
             s.is_completed
      FROM  ${WorkoutLogModel.tableName} l
      LEFT JOIN workout_sets s ON s.log_id = l.id
      WHERE l.id = ?
      ORDER BY s.set_number ASC
    ''', [id]);

    if (rows.isEmpty) return null;
    return _groupRows(rows).first;
  }

  Future<bool> hasLogToday(String exerciseId) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final rows = await _db.query(
      WorkoutLogModel.tableName,
      where: 'exercise_id = ? AND log_date = ?',
      whereArgs: [exerciseId, today],
      limit: 1,
    );
    return rows.isNotEmpty;
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

  // Grupira raw SQL redove u WorkoutLogModel s listom setova
  List<WorkoutLogModel> _groupRows(List<Map<String, dynamic>> rows) {
    final Map<String, WorkoutLogModel> logsMap = {};
    final Map<String, List<WorkoutSetModel>> setsMap = {};

    for (final row in rows) {
      final logId = row['id'] as String;

      if (!logsMap.containsKey(logId)) {
        logsMap[logId] = WorkoutLogModel.fromMap(row);
        setsMap[logId] = [];
      }

      if (row['s_id'] != null) {
        setsMap[logId]!.add(WorkoutSetModel.fromMap({
          'id': row['s_id'],
          'log_id': logId,
          'set_number': row['set_number'],
          'planned_reps': row['planned_reps'],
          'actual_reps': row['actual_reps'],
          'planned_weight': row['planned_weight'],
          'actual_weight': row['actual_weight'],
          'is_completed': row['is_completed'],
        }));
      }
    }

    return logsMap.entries.map((e) {
      final log = e.value;
      final sets = setsMap[e.key] ?? [];
      return WorkoutLogModel(
        id: log.id,
        exerciseId: log.exerciseId,
        logDate: log.logDate,
        notes: log.notes,
        totalVolume: log.totalVolume,
        createdAt: log.createdAt,
        sets: sets,
      );
    }).toList();
  }
}
