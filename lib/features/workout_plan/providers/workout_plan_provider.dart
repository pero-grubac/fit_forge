import 'package:fit_forge/core/utils/plan_schedule.dart';
import 'package:fit_forge/data/models/plan_exercise_model.dart';
import 'package:fit_forge/data/models/plan_reschedule_model.dart';
import 'package:fit_forge/data/models/workout_plan_model.dart';
import 'package:fit_forge/data/providers.dart';
import 'package:fit_forge/data/repositories/workout_plan_repository.dart';
import 'package:fit_forge/features/workout_log/providers/rest_timer_provider.dart';
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

final planReschedulesProvider =
    FutureProvider<List<PlanRescheduleModel>>((ref) {
  return ref.watch(planRescheduleRepositoryProvider).getAll();
});

/// What the Home screen shows for today.
class HomeSchedule {
  const HomeSchedule({
    required this.plans,
    required this.schedule,
    required this.today,
  });

  /// Every plan, by id.
  final Map<String, WorkoutPlanModel> plans;
  final PlanSchedule schedule;
  final DateTime today;

  List<PlanOccurrence> get dueToday => schedule.dueOn(today);

  /// Today's regular workouts that were moved to another day.
  List<PlanOccurrence> get movedAway => schedule.movedAwayFrom(today);

  List<PlanOccurrence> get upcoming => schedule.upcoming(today);
}

final homeScheduleProvider = FutureProvider<HomeSchedule>((ref) async {
  final plans = await ref.watch(workoutPlanNotifierProvider.future);
  final moves = await ref.watch(planReschedulesProvider.future);
  return HomeSchedule(
    plans: {for (final p in plans) p.id: p},
    schedule: PlanSchedule(
      weekdays: {for (final p in plans) p.id: p.dayOfWeek},
      moves: moves,
    ),
    today: dayOf(ref.watch(clockProvider)()),
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
    final before = state.valueOrNull?.where((p) => p.id == plan.id).firstOrNull;
    await _repo.update(plan);
    if (before != null && before.dayOfWeek != plan.dayOfWeek) {
      // Moves were made from the old weekday's workouts.
      await ref.read(planRescheduleRepositoryProvider).clearForPlan(plan.id);
      ref.invalidate(planReschedulesProvider);
    }
    ref.invalidateSelf();
    // The streak depends on which weekdays have a plan.
    ref.invalidate(streakProvider);
  }

  Future<void> deletePlan(String id) async {
    await _repo.delete(id);
    ref.invalidateSelf();
    ref.invalidate(planReschedulesProvider);
    // The streak depends on which weekdays have a plan.
    ref.invalidate(streakProvider);
  }

  /// Does the workout [o] on [to] instead (its regular day undoes the move).
  Future<void> moveWorkout(PlanOccurrence o, DateTime to) async {
    await ref
        .read(planRescheduleRepositoryProvider)
        .move(o.planId, o.regularDate, to);
    ref.invalidate(planReschedulesProvider);
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
