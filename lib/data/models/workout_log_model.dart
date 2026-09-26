import 'package:fit_forge/data/models/workout_set_model.dart';

class WorkoutLogModel {
  final String id;
  final String exerciseId;

  /// The plan slot the log was recorded from; null if it was removed.
  final String? planExerciseId;
  final DateTime logDate;
  final String? notes;
  final double totalVolume;
  final DateTime createdAt;
  final List<WorkoutSetModel> sets;

  static const tableName = 'workout_logs';

  const WorkoutLogModel({
    required this.id,
    required this.exerciseId,
    this.planExerciseId,
    required this.logDate,
    this.notes,
    required this.totalVolume,
    required this.createdAt,
    this.sets = const [],
  });

  factory WorkoutLogModel.create({
    required String id,
    required String exerciseId,
    String? planExerciseId,
    required DateTime logDate,
    String? notes,
    required List<WorkoutSetModel> sets,
  }) {
    final volume = sets
        .where((s) => s.isCompleted)
        .fold(0.0, (sum, s) => sum + s.actualReps * s.actualWeight);

    return WorkoutLogModel(
      id: id,
      exerciseId: exerciseId,
      planExerciseId: planExerciseId,
      logDate: logDate,
      notes: notes,
      totalVolume: volume,
      createdAt: DateTime.now(),
      sets: sets,
    );
  }

  factory WorkoutLogModel.fromMap(Map<String, dynamic> map) {
    return WorkoutLogModel(
      id: map['id'] as String,
      exerciseId: map['exercise_id'] as String,
      planExerciseId: map['plan_exercise_id'] as String?,
      logDate: DateTime.parse(map['log_date'] as String),
      notes: map['notes'] as String?,
      totalVolume: (map['total_volume'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  WorkoutLogModel withSets(List<WorkoutSetModel> sets) => WorkoutLogModel(
        id: id,
        exerciseId: exerciseId,
        planExerciseId: planExerciseId,
        logDate: logDate,
        notes: notes,
        totalVolume: totalVolume,
        createdAt: createdAt,
        sets: sets,
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exercise_id': exerciseId,
      'plan_exercise_id': planExerciseId,
      'log_date': logDate.toIso8601String().substring(0, 10),
      'notes': notes,
      'total_volume': totalVolume,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
