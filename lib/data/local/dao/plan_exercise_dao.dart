import 'package:fit_forge/data/local/database_helper.dart';
import 'package:fit_forge/data/models/default_set_model.dart';
import 'package:fit_forge/data/models/exercise_model.dart';
import 'package:fit_forge/data/models/plan_exercise_model.dart';
import 'package:sqflite/sqflite.dart';

/// Links between plans and exercises, with each link's default sets.
class PlanExerciseDao {
  PlanExerciseDao(this._helper);

  final DatabaseHelper _helper;

  Database get _db => _helper.database;

  static const _select = '''
    SELECT pe.id AS pe_id, pe.plan_id, pe.sort_order, e.*
    FROM ${PlanExerciseModel.tableName} pe
    JOIN ${ExerciseModel.tableName} e ON e.id = pe.exercise_id
  ''';

  Future<List<PlanExerciseModel>> getByPlan(String planId) async {
    final rows = await _db.rawQuery(
      '$_select WHERE pe.plan_id = ? ORDER BY pe.sort_order, pe.rowid',
      [planId],
    );
    final setRows = await _db.rawQuery('''
      SELECT ds.* FROM ${DefaultSetModel.tableName} ds
      JOIN ${PlanExerciseModel.tableName} pe ON pe.id = ds.plan_exercise_id
      WHERE pe.plan_id = ?
      ORDER BY ds.set_number
    ''', [planId]);
    return _build(rows, setRows);
  }

  Future<PlanExerciseModel?> getById(String id) async {
    final rows = await _db.rawQuery('$_select WHERE pe.id = ?', [id]);
    if (rows.isEmpty) return null;
    final setRows = await _db.query(
      DefaultSetModel.tableName,
      where: 'plan_exercise_id = ?',
      whereArgs: [id],
      orderBy: 'set_number',
    );
    return _build(rows, setRows).first;
  }

  Future<bool> exists(String planId, String exerciseId) async {
    final rows = await _db.query(
      PlanExerciseModel.tableName,
      columns: ['id'],
      where: 'plan_id = ? AND exercise_id = ?',
      whereArgs: [planId, exerciseId],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<int> nextSortOrder(String planId) async {
    final rows = await _db.rawQuery(
      'SELECT COALESCE(MAX(sort_order) + 1, 0) AS next '
      'FROM ${PlanExerciseModel.tableName} WHERE plan_id = ?',
      [planId],
    );
    return rows.first['next'] as int;
  }

  Future<void> insert(PlanExerciseModel planExercise) async {
    await _db.transaction((txn) async {
      await txn.insert(PlanExerciseModel.tableName, planExercise.toMap());
      for (final s in planExercise.defaultSets) {
        await txn.insert(DefaultSetModel.tableName, s.toMap());
      }
    });
  }

  /// Replaces the plan's target sets for this exercise.
  Future<void> replaceDefaultSets(
      String planExerciseId, List<DefaultSetModel> sets) async {
    await _db.transaction((txn) async {
      await txn.delete(
        DefaultSetModel.tableName,
        where: 'plan_exercise_id = ?',
        whereArgs: [planExerciseId],
      );
      for (final s in sets) {
        await txn.insert(DefaultSetModel.tableName, s.toMap());
      }
    });
  }

  Future<void> updateSortOrder(String id, int sortOrder) async {
    await _db.update(
      PlanExerciseModel.tableName,
      {'sort_order': sortOrder},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Removes the exercise from the plan. Default sets cascade; logs keep
  /// their history and lose only the link to this slot.
  Future<void> delete(String id) async {
    await _db.delete(
      PlanExerciseModel.tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  List<PlanExerciseModel> _build(
    List<Map<String, Object?>> rows,
    List<Map<String, Object?>> setRows,
  ) {
    final setsBySlot = <String, List<DefaultSetModel>>{};
    for (final row in setRows) {
      final set = DefaultSetModel.fromMap(row);
      setsBySlot.putIfAbsent(set.planExerciseId, () => []).add(set);
    }
    return [
      for (final row in rows)
        PlanExerciseModel(
          id: row['pe_id'] as String,
          planId: row['plan_id'] as String,
          exercise: ExerciseModel.fromMap(row),
          sortOrder: row['sort_order'] as int,
          defaultSets: setsBySlot[row['pe_id']] ?? const [],
        ),
    ];
  }
}
