import 'package:fit_forge/data/local/database_helper.dart';
import 'package:fit_forge/data/models/plan_reschedule_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class PlanRescheduleDao {
  PlanRescheduleDao(this._helper);

  final DatabaseHelper _helper;

  Database get _db => _helper.database;

  Future<List<PlanRescheduleModel>> getAll() async {
    final rows = await _db.query(PlanRescheduleModel.tableName);
    return rows.map(PlanRescheduleModel.fromMap).toList();
  }

  Future<void> upsert(String planId, DateTime from, DateTime to) async {
    await _db.insert(
      PlanRescheduleModel.tableName,
      {
        'id': const Uuid().v4(),
        'plan_id': planId,
        'from_date': dayKey(from),
        'to_date': dayKey(to),
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> delete(String planId, DateTime from) async {
    await _db.delete(
      PlanRescheduleModel.tableName,
      where: 'plan_id = ? AND from_date = ?',
      whereArgs: [planId, dayKey(from)],
    );
  }

  Future<void> deleteForPlan(String planId) async {
    await _db.delete(
      PlanRescheduleModel.tableName,
      where: 'plan_id = ?',
      whereArgs: [planId],
    );
  }
}
