import 'package:fit_forge/data/models/exercise_model.dart';
import 'package:fit_forge/data/models/workout_plan_model.dart';
import 'package:fit_forge/data/repositories/exercise_repository.dart';
import 'package:fit_forge/data/repositories/workout_plan_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _exerciseRepo = ExerciseRepository();

final workoutPlansProvider = FutureProvider<List<WorkoutPlanModel>>((ref) {
  return ref.watch(workoutPlanNotifierProvider.future);
});

final planByDayProvider =
    FutureProvider.family<WorkoutPlanModel?, int>((ref, dayOfWeek) {
  return ref.watch(workoutPlanNotifierProvider.future).then(
        (plans) => plans.where((p) => p.dayOfWeek == dayOfWeek).firstOrNull,
      );
});

final todayPlanProvider = FutureProvider<WorkoutPlanModel?>((ref) {
  final today = DateTime.now().weekday;
  return ref.watch(workoutPlanNotifierProvider.future).then(
        (plans) => plans.where((p) => p.dayOfWeek == today).firstOrNull,
      );
});

final exercisesProvider =
    FutureProvider.family<List<ExerciseModel>, String>((ref, planId) {
  return _exerciseRepo.getByPlan(planId);
});

class WorkoutPlanNotifier extends AsyncNotifier<List<WorkoutPlanModel>> {
  final _repo = WorkoutPlanRepository();

  @override
  Future<List<WorkoutPlanModel>> build() => _repo.getAll();

  Future<void> create({required String name, required int dayOfWeek}) async {
    await _repo.create(name: name, dayOfWeek: dayOfWeek);
    ref.invalidateSelf();
  }

  Future<void> updatePlan(WorkoutPlanModel plan) async {
    await _repo.update(plan);
    ref.invalidateSelf();
  }

  Future<void> deletePlan(String id) async {
    await _repo.delete(id);
    ref.invalidateSelf();
  }
}

final workoutPlanNotifierProvider =
    AsyncNotifierProvider<WorkoutPlanNotifier, List<WorkoutPlanModel>>(
        WorkoutPlanNotifier.new);
