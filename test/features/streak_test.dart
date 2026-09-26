import 'package:fit_forge/features/workout_log/providers/streak_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // 2026-09-21 is a Monday.
  const mon = 1, wed = 3, fri = 5;
  const plan = {mon, wed, fri};

  int streak(Set<String> logged, DateTime today) =>
      calculateStreak(plannedDays: plan, loggedDates: logged, today: today);

  test('today not logged yet does not break the streak', () {
    // Friday 25th, logged Mon + Wed, Friday still in progress.
    expect(streak({'2026-09-21', '2026-09-23'}, DateTime(2026, 9, 25, 8)), 2);
  });

  test('today logged counts', () {
    expect(
        streak({'2026-09-21', '2026-09-23', '2026-09-25'},
            DateTime(2026, 9, 25, 20)),
        3);
  });

  test('rest days are skipped', () {
    // Sunday 27th: Fri logged, weekend is rest.
    expect(streak({'2026-09-23', '2026-09-25'}, DateTime(2026, 9, 27)), 2);
  });

  test('missed past workout day breaks the streak', () {
    // Wednesday 23rd missed.
    expect(streak({'2026-09-21', '2026-09-25'}, DateTime(2026, 9, 25)), 1);
  });

  test('streaks longer than 60 days are counted', () {
    final logged = <String>{};
    var d = DateTime(2026, 1, 1);
    while (!d.isAfter(DateTime(2026, 9, 25))) {
      logged.add(d.toIso8601String().substring(0, 10));
      d = DateTime(d.year, d.month, d.day + 1);
    }
    expect(streak(logged, DateTime(2026, 9, 25)), greaterThan(60 * 3 / 7));
  });

  test('no logs means no streak', () {
    expect(streak({}, DateTime(2026, 9, 25)), 0);
  });
}
