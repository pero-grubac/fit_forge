import 'package:fit_forge/core/utils/plan_schedule.dart';
import 'package:fit_forge/data/models/plan_reschedule_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Thursday 5 Nov 2026. Full Body is a Thursday plan, Pull a Wednesday one.
  final thu = DateTime(2026, 11, 5);
  const weekdays = {'full': DateTime.thursday, 'pull': DateTime.wednesday};

  PlanSchedule schedule([List<PlanRescheduleModel> moves = const []]) =>
      PlanSchedule(weekdays: weekdays, moves: moves);

  PlanRescheduleModel move(String plan, DateTime from, DateTime to) =>
      PlanRescheduleModel(planId: plan, fromDate: from, toDate: to);

  List<String> keys(Iterable<DateTime> days) => [for (final d in days) dayKey(d)];

  test('a plan is due on its weekday', () {
    expect(schedule().dueOn(thu).map((o) => o.planId), ['full']);
    expect(schedule().dueOn(addDays(thu, 1)), isEmpty);
  });

  test('a moved workout leaves its day and shows up on the new one', () {
    final s = schedule([move('full', thu, DateTime(2026, 11, 7))]);
    expect(s.dueOn(thu), isEmpty);
    expect(s.movedAwayFrom(thu).single.dueDate, DateTime(2026, 11, 7));

    final sat = s.dueOn(DateTime(2026, 11, 7)).single;
    expect(sat.planId, 'full');
    expect(sat.isMoved, isTrue);
    expect(sat.regularDate, thu);
  });

  test('today\'s workout can go to any day before the next one', () {
    final o = schedule().occurrence('full', thu);
    expect(keys(schedule().targetDays(o, thu)), [
      '2026-11-06',
      '2026-11-07',
      '2026-11-08',
      '2026-11-09',
      '2026-11-10',
      '2026-11-11', // the next one is on Thursday 12th
    ]);
  });

  test('a later workout can be done earlier, but not in the past', () {
    // Next Wednesday's Pull, seen on Thursday: back to today at the
    // earliest (its window starts the day after last Wednesday).
    final o = schedule().occurrence('pull', DateTime(2026, 11, 11));
    final days = schedule().targetDays(o, thu);
    expect(dayKey(days.first), '2026-11-05');
    expect(dayKey(days.last), '2026-11-17');
    expect(keys(days), isNot(contains('2026-11-11'))); // where it is now
  });

  test('a moved workout can be moved again or back, never into the past', () {
    final s = schedule([move('full', thu, DateTime(2026, 11, 7))]);
    final o = s.occurrence('full', thu);

    // Still Thursday: back to Thursday is offered.
    expect(keys(s.targetDays(o, thu)), contains('2026-11-05'));

    // Friday: Thursday is gone, Friday and later are still fine.
    final fromFri = keys(s.targetDays(o, DateTime(2026, 11, 6)));
    expect(fromFri, isNot(contains('2026-11-05')));
    expect(fromFri.first, '2026-11-06');
  });

  test('a workout whose day has passed cannot be moved', () {
    final o = schedule().occurrence('full', DateTime(2026, 10, 29));
    expect(schedule().targetDays(o, thu), isEmpty);
  });

  test('never two of the same plan on one day', () {
    // Next Thursday's Full Body pulled to Wednesday 11th.
    final s = schedule(
        [move('full', DateTime(2026, 11, 12), DateTime(2026, 11, 11))]);
    final today = s.occurrence('full', thu);
    expect(keys(s.targetDays(today, thu)), isNot(contains('2026-11-11')));
  });

  test('coming up: the next days, soonest first, moved ones included', () {
    final s = schedule([move('full', thu, DateTime(2026, 11, 7))]);
    final up = s.upcoming(thu);
    expect([for (final o in up) '${o.planId} ${dayKey(o.dueDate)}'], [
      'full 2026-11-07',
      'pull 2026-11-11',
    ]);
  });

  test('moves are safe across daylight saving changes', () {
    // Europe moves the clocks back on Sunday 25 Oct 2026.
    final o = schedule().occurrence('pull', DateTime(2026, 10, 21));
    final days = schedule().targetDays(o, DateTime(2026, 10, 21));
    expect(keys(days).last, '2026-10-27');
    expect(days.every((d) => d.hour == 0), isTrue);
  });
}
