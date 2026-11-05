import 'package:fit_forge/core/utils/plan_schedule.dart';
import 'package:fit_forge/data/models/plan_reschedule_model.dart';
import 'package:fit_forge/data/providers.dart';
import 'package:fit_forge/features/workout_log/providers/rest_timer_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final streakProvider = FutureProvider<int>((ref) async {
  final plans = await ref.watch(workoutPlanRepositoryProvider).getAll();
  final moves = await ref.watch(planRescheduleRepositoryProvider).getAll();
  final slots = await ref.watch(planExerciseRepositoryProvider).getAllSlots();
  final days =
      await ref.watch(workoutLogRepositoryProvider).getSlotDaySummaries();

  final doneDays = <String, Set<String>>{};
  final firstLog = <String, String>{};
  for (final d in days) {
    if (d.sets > 0 && d.done == d.sets) {
      doneDays.putIfAbsent(d.planExerciseId, () => {}).add(d.day);
    }
    final first = firstLog[d.planExerciseId];
    if (first == null || d.day.compareTo(first) < 0) {
      firstLog[d.planExerciseId] = d.day;
    }
  }

  final slotsByPlan = <String, List<SlotHistory>>{};
  for (final s in slots) {
    final added = s.createdAt == null ? null : dayOf(s.createdAt!);
    final logged = firstLog[s.id] == null ? null : DateTime.parse(firstLog[s.id]!);
    final from = switch ((added, logged)) {
      (final a?, final l?) => a.isBefore(l) ? a : l,
      (final a?, null) => a,
      (null, final l?) => l,
      (null, null) => null,
    };
    if (from == null) continue;
    slotsByPlan.putIfAbsent(s.planId, () => []).add(
        SlotHistory(requiredFrom: from, doneDays: doneDays[s.id] ?? const {}));
  }

  return calculateStreak(
    slotsByPlan: slotsByPlan,
    schedule: PlanSchedule(
      weekdays: {for (final p in plans) p.id: p.dayOfWeek},
      moves: moves,
    ),
    today: ref.watch(clockProvider)(),
  );
});

/// What the streak needs to know about one exercise of a plan.
class SlotHistory {
  const SlotHistory({required this.requiredFrom, required this.doneDays});

  /// The first day the exercise belongs to its plan's workout: when it was
  /// added, or first logged if that's earlier.
  final DateTime requiredFrom;

  /// Days ('yyyy-MM-dd') it was saved with every set ticked.
  final Set<String> doneDays;
}

/// Consecutive days kept, going back from [today]. A day is kept when every
/// workout promised for it is done: its regular workouts on that day, and
/// those moved off it on the day they were moved to. A workout is done when
/// all of its exercises were saved with every set ticked.
///
/// The streak breaks at the latest day with a workout not done in time.
/// Days whose workouts are still ahead (today, or moved to a later day)
/// neither break nor add to it. Days without workouts are skipped.
int calculateStreak({
  required Map<String, List<SlotHistory>> slotsByPlan,
  required PlanSchedule schedule,
  required DateTime today,
}) {
  final starts = [
    for (final slots in slotsByPlan.values)
      for (final s in slots) s.requiredFrom,
  ];
  if (starts.isEmpty) return 0;
  final earliest = starts.reduce((a, b) => a.isBefore(b) ? a : b);
  final t = dayOf(today);

  /// Null when the plan had nothing to do on [due] (no exercises yet).
  bool? doneOn(String planId, DateTime due) {
    final required = [
      for (final s in slotsByPlan[planId] ?? const <SlotHistory>[])
        if (!s.requiredFrom.isAfter(due)) s,
    ];
    if (required.isEmpty) return null;
    return required.every((s) => s.doneDays.contains(dayKey(due)));
  }

  var streak = 0;
  for (var d = t; !d.isBefore(earliest); d = addDays(d, -1)) {
    var promised = false;
    var allDone = true;
    var missed = false;
    for (final planId in schedule.plansOn(d.weekday)) {
      final due = schedule.dueDate(planId, d);
      final done = doneOn(planId, due);
      if (done == null) continue;
      promised = true;
      if (done) continue;
      allDone = false;
      if (due.isBefore(t)) missed = true;
    }
    if (!promised) continue;
    if (missed) break;
    if (allDone) streak++;
  }
  return streak;
}
