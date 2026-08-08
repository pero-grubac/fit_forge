import 'package:fit_forge/data/local/database_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final streakProvider = FutureProvider<int>((ref) async {
  final db = DatabaseHelper.instance.database;

  final plans = await db.query('workout_plans');
  if (plans.isEmpty) return 0;

  final plannedDays = plans.map((p) => p['day_of_week'] as int).toSet();

  final logs = await db.query(
    'workout_logs',
    orderBy: 'log_date DESC',
  );

  final loggedDates = <String>{};
  for (final log in logs) {
    final date = (log['log_date'] as String).substring(0, 10);
    loggedDates.add(date);
  }

  int streak = 0;
  var date = DateTime.now();

  for (int i = 0; i < 60; i++) {
    final dayOfWeek = date.weekday;
    final dateStr = date.toIso8601String().substring(0, 10);

    if (!plannedDays.contains(dayOfWeek)) {
      date = date.subtract(const Duration(days: 1));
      continue;
    }

    if (!loggedDates.contains(dateStr)) break;

    streak++;
    date = date.subtract(const Duration(days: 1));
  }

  return streak;
});
