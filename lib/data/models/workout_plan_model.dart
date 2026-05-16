class WorkoutPlanModel {
  final String id;
  final String name;
  final int dayOfWeek; // 1=Pon, 2=Uto ... 7=Ned
  final bool isActive;
  final DateTime createdAt;

  static const tableName = 'workout_plans';

  const WorkoutPlanModel({
    required this.id,
    required this.name,
    required this.dayOfWeek,
    required this.isActive,
    required this.createdAt,
  });

  factory WorkoutPlanModel.fromMap(Map<String, dynamic> map) {
    return WorkoutPlanModel(
      id: map['id'] as String,
      name: map['name'] as String,
      dayOfWeek: map['day_of_week'] as int,
      isActive: (map['is_active'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'day_of_week': dayOfWeek,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  WorkoutPlanModel copyWith({
    String? name,
    int? dayOfWeek,
    bool? isActive,
  }) {
    return WorkoutPlanModel(
      id: id,
      name: name ?? this.name,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }
}
