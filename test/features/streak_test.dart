import 'package:fit_forge/core/utils/plan_schedule.dart';
import 'package:fit_forge/data/models/plan_reschedule_model.dart';
import 'package:fit_forge/features/workout_log/providers/streak_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // 2026-09-21 is a Monday.
  const mon = 1, wed = 3, fri = 5;

  /// One exercise per plan, part of it from [from]; [done] = days it was
  /// saved with every set ticked, per plan.
  int streak(
    Map<String, int> weekdays,
    Map<String, Set<String>> done,
    DateTime today, {
    String from = '2026-09-21',
    List<PlanRescheduleModel> moves = const [],
  }) =>
      calculateStreak(
        slotsByPlan: {
          for (final id in weekdays.keys)
            id: [
              SlotHistory(
                  requiredFrom: DateTime.parse(from),
                  doneDays: done[id] ?? const {}),
            ],
        },
        schedule: PlanSchedule(weekdays: weekdays, moves: moves),
        today: today,
      );

  group('one plan per workout day', () {
    const plans = {'mon': mon, 'wed': wed, 'fri': fri};

    test('today not done yet does not break the streak', () {
      // Friday 25th, Mon + Wed done, Friday still in progress.
      expect(
          streak(plans, {'mon': {'2026-09-21'}, 'wed': {'2026-09-23'}},
              DateTime(2026, 9, 25, 8)),
          2);
    });

    test('today done counts', () {
      expect(
          streak(
              plans,
              {
                'mon': {'2026-09-21'},
                'wed': {'2026-09-23'},
                'fri': {'2026-09-25'},
              },
              DateTime(2026, 9, 25, 20)),
          3);
    });

    test('rest days are skipped', () {
      // Sunday 27th: Wed + Fri done; Monday 21st missed.
      expect(
          streak(plans, {'wed': {'2026-09-23'}, 'fri': {'2026-09-25'}},
              DateTime(2026, 9, 27)),
          2);
    });

    test('a missed past workout breaks the streak', () {
      expect(
          streak(plans, {'mon': {'2026-09-21'}, 'fri': {'2026-09-25'}},
              DateTime(2026, 9, 25)),
          1);
    });

    test('streaks longer than 60 days are counted', () {
      final days = <String>{};
      var d = DateTime(2026, 1, 1);
      while (!d.isAfter(DateTime(2026, 9, 25))) {
        days.add(dayKey(d));
        d = addDays(d, 1);
      }
      expect(
          streak(plans, {for (final id in plans.keys) id: days},
              DateTime(2026, 9, 25),
              from: '2026-01-01'),
          greaterThan(60 * 3 / 7));
    });

    test('nothing done means no streak', () {
      expect(streak(plans, {}, DateTime(2026, 9, 25)), 0);
    });
  });

  group('every exercise of a workout counts', () {
    test('a workout with one exercise skipped is missed', () {
      final s = calculateStreak(
        slotsByPlan: {
          'mon': [
            SlotHistory(
                requiredFrom: DateTime(2026, 9, 21),
                doneDays: const {'2026-09-21'}),
            SlotHistory(requiredFrom: DateTime(2026, 9, 21), doneDays: const {}),
          ],
        },
        schedule: PlanSchedule(weekdays: {'mon': mon}, moves: const []),
        today: DateTime(2026, 9, 23),
      );
      expect(s, 0);
    });

    test('an exercise added later is not required on earlier days', () {
      final s = calculateStreak(
        slotsByPlan: {
          'mon': [
            SlotHistory(
                requiredFrom: DateTime(2026, 9, 14),
                doneDays: const {'2026-09-14', '2026-09-21'}),
            // Added on the 21st and done that day.
            SlotHistory(
                requiredFrom: DateTime(2026, 9, 21),
                doneDays: const {'2026-09-21'}),
          ],
        },
        schedule: PlanSchedule(weekdays: {'mon': mon}, moves: const []),
        today: DateTime(2026, 9, 23),
      );
      expect(s, 2);
    });
  });

  group('a workout moved to another day', () {
    // A is Monday's, moved to Friday 25th; W is Wednesday's; B is Friday's.
    const plans = {'A': mon, 'W': wed, 'B': fri};
    final moveA = [
      PlanRescheduleModel(
          planId: 'A',
          fromDate: DateTime(2026, 9, 21),
          toDate: DateTime(2026, 9, 25)),
    ];
    final saturday = DateTime(2026, 9, 26);
    const wDone = {'2026-09-23'};

    test('both done on the new day: the streak goes on', () {
      expect(
          streak(
              plans,
              {
                'A': {'2026-09-25'},
                'W': wDone,
                'B': {'2026-09-25'},
              },
              saturday,
              moves: moveA),
          3);
    });

    test('moved one done, the day\'s own one not: breaks on that day', () {
      expect(
          streak(plans, {'A': {'2026-09-25'}, 'W': wDone}, saturday,
              moves: moveA),
          0);
    });

    test('day\'s own one done, moved one not: breaks from its original day',
        () {
      expect(
          streak(plans, {'W': wDone, 'B': {'2026-09-25'}}, saturday,
              moves: moveA),
          2);
    });

    test('neither done: breaks on the latest missed day', () {
      expect(streak(plans, {'W': wDone}, saturday, moves: moveA), 0);
    });

    test('while it waits, its original day neither breaks nor adds', () {
      // Thursday: Monday's workout is still due on Friday.
      expect(
          streak(plans, {'W': wDone}, DateTime(2026, 9, 24), moves: moveA), 1);
    });

    test('done on its own day, the original day counts again', () {
      expect(
          streak(
              plans,
              {
                'A': {'2026-09-25'},
                'W': wDone,
                'B': {'2026-09-25'},
              },
              DateTime(2026, 9, 25, 20),
              moves: moveA),
          3);
    });
  });
}
