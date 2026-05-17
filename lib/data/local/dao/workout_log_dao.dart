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
    // Prvo dohvati log IDs
    final logRows = await _db.query(
      WorkoutLogModel.tableName,
      where: 'exercise_id = ?',
      whereArgs: [exerciseId],
      orderBy: 'log_date DESC',
      limit: limit,
    );

    if (logRows.isEmpty) return [];

    final logIds = logRows.map((r) => r['id'] as String).toList();
    final placeholders = logIds.map((_) => '?').join(',');

    // Onda dohvati sve setove za te logove
    final setRows = await _db.rawQuery('''
    SELECT * FROM ${WorkoutSetModel.tableName}
    WHERE log_id IN ($placeholders)
    ORDER BY log_id, set_number ASC
  ''', logIds);

    // Grupiraj
    final Map<String, List<WorkoutSetModel>> setsMap = {};
    for (final row in setRows) {
      final logId = row['log_id'] as String;
      setsMap.putIfAbsent(logId, () => []);
      setsMap[logId]!.add(WorkoutSetModel.fromMap(row));
    }

    return logRows.map((row) {
      final log = WorkoutLogModel.fromMap(row);
      return WorkoutLogModel(
        id:          log.id,
        exerciseId:  log.exerciseId,
        logDate:     log.logDate,
        notes:       log.notes,
        totalVolume: log.totalVolume,
        createdAt:   log.createdAt,
        sets:        setsMap[log.id] ?? [],
      );
    }).toList();
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

  Future<Map<String, int>> getCompletedSetsToday(
      List<String> exerciseIds) async {
    if (exerciseIds.isEmpty) return {};
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final placeholders = exerciseIds.map((_) => '?').join(',');
    final rows = await _db.rawQuery(
      '''
        SELECT l.exercise_id, COUNT(s.id) as completed
        FROM ${WorkoutLogModel.tableName} l
        JOIN ${WorkoutSetModel.tableName} s ON s.log_id = l.id
        WHERE l.log_date = ?
          AND l.exercise_id IN ($placeholders)
          AND s.is_completed = 1
        GROUP BY l.exercise_id
      ''',
      [today, ...exerciseIds],
    );

    return {
      for (final row in rows)
        row['exercise_id'] as String: (row['completed'] as int)
    };
  }

  Future<WorkoutLogModel?> getByExerciseAndDate(
      String exerciseId, String date) async {
    final logRows = await _db.query(
      WorkoutLogModel.tableName,
      where: 'exercise_id = ? AND log_date = ?',
      whereArgs: [exerciseId, date],
      limit: 1,
    );
    if (logRows.isEmpty) return null;

    final log = WorkoutLogModel.fromMap(logRows.first);
    final setRows = await _db.query(
      WorkoutSetModel.tableName,
      where: 'log_id = ?',
      whereArgs: [log.id],
      orderBy: 'set_number ASC',
    );

    return WorkoutLogModel(
      id:          log.id,
      exerciseId:  log.exerciseId,
      logDate:     log.logDate,
      notes:       log.notes,
      totalVolume: log.totalVolume,
      createdAt:   log.createdAt,
      sets:        setRows.map(WorkoutSetModel.fromMap).toList(),
    );
  }
}
