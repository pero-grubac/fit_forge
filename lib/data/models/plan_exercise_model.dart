import 'package:fit_forge/data/models/default_set_model.dart';
import 'package:fit_forge/data/models/exercise_model.dart';

/// An exercise placed in a plan, with the plan-specific targets.
class PlanExerciseModel {
  final String id;
  final String planId;
  final ExerciseModel exercise;
  final int sortOrder;
  final List<DefaultSetModel> defaultSets;

  static const tableName = 'plan_exercises';

  const PlanExerciseModel({
    required this.id,
    required this.planId,
    required this.exercise,
    required this.sortOrder,
    this.defaultSets = const [],
  });

  String get exerciseId => exercise.id;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'plan_id': planId,
      'exercise_id': exercise.id,
      'sort_order': sortOrder,
    };
  }

  PlanExerciseModel copyWith({
    ExerciseModel? exercise,
    int? sortOrder,
    List<DefaultSetModel>? defaultSets,
  }) {
    return PlanExerciseModel(
      id: id,
      planId: planId,
      exercise: exercise ?? this.exercise,
      sortOrder: sortOrder ?? this.sortOrder,
      defaultSets: defaultSets ?? this.defaultSets,
    );
  }
}
