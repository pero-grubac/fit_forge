import 'package:fit_forge/data/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final streakProvider = FutureProvider<int>((ref) async {
  final plans = await ref.watch(workoutPlanRepositoryProvider).getAll();
  final loggedDates =
      await ref.watch(workoutLogRepositoryProvider).getLoggedDates();

  return calculateStreak(
    plannedDays: {for (final p in plans) p.dayOfWeek},
    loggedDates: loggedDates,
    today: DateTime.now(),
  );
});

/// Counts consecutive planned workout days that were logged, going back from
/// [today]. Rest days are skipped. Today only breaks the streak once it is
/// over, so an unlogged workout day that is still in progress is ignored.
int calculateStreak({
  required Set<int> plannedDays,
  required Set<String> loggedDates,
  required DateTime today,
}) {
  if (plannedDays.isEmpty || loggedDates.isEmpty) return 0;

  final earliest = loggedDates.reduce((a, b) => a.compareTo(b) < 0 ? a : b);
  var date = DateTime(today.year, today.month, today.day);
  var streak = 0;

  while (true) {
    final dateStr = date.toIso8601String().substring(0, 10);
    if (dateStr.compareTo(earliest) < 0) break;

    if (plannedDays.contains(date.weekday)) {
      if (loggedDates.contains(dateStr)) {
        streak++;
      } else if (!_isSameDay(date, today)) {
        break;
      }
    }
    date = DateTime(date.year, date.month, date.day - 1);
  }

  return streak;
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
