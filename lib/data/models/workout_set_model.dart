class WorkoutSetModel {
  final String id;
  final String logId;
  final int setNumber;
  final int plannedReps;
  final int actualReps;
  final double plannedWeight;
  final double actualWeight;
  final bool isCompleted;

  static const tableName = 'workout_sets';

  const WorkoutSetModel({
    required this.id,
    required this.logId,
    required this.setNumber,
    required this.plannedReps,
    required this.actualReps,
    required this.plannedWeight,
    required this.actualWeight,
    required this.isCompleted,
  });

  factory WorkoutSetModel.fromMap(Map<String, dynamic> map) {
    return WorkoutSetModel(
      id: map['id'] as String,
      logId: map['log_id'] as String,
      setNumber: map['set_number'] as int,
      plannedReps: map['planned_reps'] as int,
      actualReps: map['actual_reps'] as int,
      plannedWeight: (map['planned_weight'] as num).toDouble(),
      actualWeight: (map['actual_weight'] as num).toDouble(),
      isCompleted: (map['is_completed'] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'log_id': logId,
      'set_number': setNumber,
      'planned_reps': plannedReps,
      'actual_reps': actualReps,
      'planned_weight': plannedWeight,
      'actual_weight': actualWeight,
      'is_completed': isCompleted ? 1 : 0,
    };
  }

  WorkoutSetModel copyWith({
    int? actualReps,
    double? actualWeight,
    bool? isCompleted,
  }) {
    return WorkoutSetModel(
      id: id,
      logId: logId,
      setNumber: setNumber,
      plannedReps: plannedReps,
      actualReps: actualReps ?? this.actualReps,
      plannedWeight: plannedWeight,
      actualWeight: actualWeight ?? this.actualWeight,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
