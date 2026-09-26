import 'package:fit_forge/data/models/plan_exercise_model.dart';
import 'package:fit_forge/data/models/workout_plan_model.dart';
import 'package:fit_forge/data/providers.dart';
import 'package:fit_forge/data/repositories/workout_plan_repository.dart';
import 'package:fit_forge/features/workout_log/providers/streak_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final workoutPlansProvider = FutureProvider<List<WorkoutPlanModel>>((ref) {
  return ref.watch(workoutPlanNotifierProvider.future);
});

final planByDayProvider =
    FutureProvider.family<WorkoutPlanModel?, int>((ref, dayOfWeek) {
  return ref.watch(workoutPlanNotifierProvider.future).then(
        (plans) => plans.where((p) => p.dayOfWeek == dayOfWeek).firstOrNull,
      );
});

final todayPlansProvider = FutureProvider<List<WorkoutPlanModel>>((ref) {
  final today = DateTime.now().weekday;
  return ref.watch(workoutPlanNotifierProvider.future).then(
        (plans) => plans.where((p) => p.dayOfWeek == today).toList(),
      );
});

final planExercisesProvider =
    FutureProvider.family<List<PlanExerciseModel>, String>((ref, planId) {
  return ref.watch(planExerciseRepositoryProvider).getByPlan(planId);
});

class WorkoutPlanNotifier extends AsyncNotifier<List<WorkoutPlanModel>> {
  WorkoutPlanRepository get _repo => ref.read(workoutPlanRepositoryProvider);

  @override
  Future<List<WorkoutPlanModel>> build() => _repo.getAll();

  Future<void> create({required String name, required int dayOfWeek}) async {
    await _repo.create(name: name, dayOfWeek: dayOfWeek);
    ref.invalidateSelf();
    // The streak depends on which weekdays have a plan.
    ref.invalidate(streakProvider);
  }

  Future<void> updatePlan(WorkoutPlanModel plan) async {
    await _repo.update(plan);
    ref.invalidateSelf();
    // The streak depends on which weekdays have a plan.
    ref.invalidate(streakProvider);
  }

  Future<void> deletePlan(String id) async {
    await _repo.delete(id);
    ref.invalidateSelf();
    // The streak depends on which weekdays have a plan.
    ref.invalidate(streakProvider);
  }

  Future<void> updateName(String id, String name) async {
    await _repo.updateName(id, name);
    ref.invalidateSelf();
    // The streak depends on which weekdays have a plan.
    ref.invalidate(streakProvider);
  }
}

final workoutPlanNotifierProvider =
    AsyncNotifierProvider<WorkoutPlanNotifier, List<WorkoutPlanModel>>(
        WorkoutPlanNotifier.new);
