import 'package:fit_forge/data/local/database_helper.dart';
import 'package:fit_forge/data/models/default_set_model.dart';
import 'package:fit_forge/data/models/exercise_model.dart';
import 'package:fit_forge/data/models/workout_log_model.dart';
import 'package:fit_forge/data/models/workout_plan_model.dart';
import 'package:fit_forge/data/models/workout_set_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class DummyData {
  static final _uuid = const Uuid();
  static final _db = DatabaseHelper.instance.database;

  static Future<void> insert() async {
    final now = DateTime.now();

    for (int day = 1; day <= 7; day++) {
      final planId    = _uuid.v4();
      final exerciseId = _uuid.v4();
      final logId     = _uuid.v4();
      final setId     = _uuid.v4();
      final defaultSetId = _uuid.v4();

      final logDate = now.subtract(Duration(days: 8 - day));
      final dateStr = logDate.toIso8601String().substring(0, 10);

      // Plan
      await _db.insert(WorkoutPlanModel.tableName, {
        'id':          planId,
        'name':        'Plan $day',
        'day_of_week': day,
        'created_at':  dateStr,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);

      // Exercise
      await _db.insert(ExerciseModel.tableName, {
        'id':           exerciseId,
        'plan_id':      planId,
        'name':         'Vjezba $day',
        'muscle_group': 'Chest',
        'sort_order':   0,
        'created_at':   dateStr,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);

      // Default set
      await _db.insert(DefaultSetModel.tableName, {
        'id':          defaultSetId,
        'exercise_id': exerciseId,
        'set_number':  1,
        'reps':        10,
        'weight':      50.0,
        'increment':   2.5,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);

      // Workout log
      await _db.insert(WorkoutLogModel.tableName, {
        'id':           logId,
        'exercise_id':  exerciseId,
        'log_date':     dateStr,
        'total_volume': 500.0,
        'created_at':   dateStr,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);

      // Workout set
      await _db.insert(WorkoutSetModel.tableName, {
        'id':             setId,
        'log_id':         logId,
        'set_number':     1,
        'planned_reps':   10,
        'actual_reps':    10,
        'planned_weight': 50.0,
        'actual_weight':  50.0,
        'is_completed':   1,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);

      print('Inserted dummy data for day $day — $dateStr');
    }

    print('=== Dummy data inserted ===');
  }
}