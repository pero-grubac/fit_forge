class DefaultSetModel {
  final String id;
  final String planExerciseId;
  final int setNumber;
  final int reps;
  final double weight;
  final double increment;

  static const tableName = 'default_sets';

  const DefaultSetModel({
    required this.id,
    required this.planExerciseId,
    required this.setNumber,
    required this.reps,
    required this.weight,
    required this.increment,
  });

  factory DefaultSetModel.fromMap(Map<String, dynamic> map) {
    return DefaultSetModel(
      id: map['id'] as String,
      planExerciseId: map['plan_exercise_id'] as String,
      setNumber: map['set_number'] as int,
      reps: map['reps'] as int,
      weight: (map['weight'] as num).toDouble(),
      increment: (map['increment'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'plan_exercise_id': planExerciseId,
      'set_number': setNumber,
      'reps': reps,
      'weight': weight,
      'increment': increment,
    };
  }
}
