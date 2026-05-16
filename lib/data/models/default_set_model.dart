class DefaultSetModel {
  final String id;
  final String exerciseId;
  final int setNumber;
  final int reps;
  final double weight;
  final double increment;

  static const tableName = 'default_sets';

  const DefaultSetModel({
    required this.id,
    required this.exerciseId,
    required this.setNumber,
    required this.reps,
    required this.weight,
    required this.increment,
  });

  factory DefaultSetModel.fromMap(Map<String, dynamic> map) {
    return DefaultSetModel(
      id: map['id'] as String,
      exerciseId: map['exercise_id'] as String,
      setNumber: map['set_number'] as int,
      reps: map['reps'] as int,
      weight: (map['weight'] as num).toDouble(),
      increment: (map['increment'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exercise_id': exerciseId,
      'set_number': setNumber,
      'reps': reps,
      'weight': weight,
      'increment': increment,
    };
  }
}
