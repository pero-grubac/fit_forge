import 'package:fit_forge/core/theme/app_colors.dart';
import 'package:fit_forge/core/utils/l10n_extension.dart';
import 'package:fit_forge/core/utils/plan_schedule.dart';
import 'package:fit_forge/data/models/plan_reschedule_model.dart';
import 'package:flutter/material.dart';

/// The key the localized weekday `select` messages expect.
String weekdayKey(DateTime d) =>
    const ['', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'][d.weekday];

/// "6.11."
String shortDate(DateTime d) => '${d.day}.${d.month}.';

String weekdayName(BuildContext context, DateTime d) {
  final l = context.l10n;
  return [
    '',
    l.days_monday,
    l.days_tuesday,
    l.days_wednesday,
    l.days_thursday,
    l.days_friday,
    l.days_saturday,
    l.days_sunday,
  ][d.weekday];
}

/// Lets the user pick one of [days] for [occurrence]; null if dismissed.
Future<DateTime?> showMoveWorkoutSheet(
  BuildContext context, {
  required String planName,
  required PlanOccurrence occurrence,
  required List<DateTime> days,
  required DateTime today,
}) {
  final latest = addDays(occurrence.regularDate, PlanSchedule.reach);
  final next = addDays(occurrence.regularDate, 7);
  return showModalBottomSheet<DateTime>(
    context: context,
    // Tall enough for every day of the window without scrolling.
    isScrollControlled: true,
    backgroundColor: AppColors.bg2,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.bg4,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(ctx.l10n.home_move_title(planName),
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text1)),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final d in days)
                    ListTile(
                      key: Key('move_to_${dayKey(d)}'),
                      dense: true,
                      title: Text('${weekdayName(ctx, d)} ${shortDate(d)}',
                          style: const TextStyle(color: AppColors.text1)),
                      subtitle: sameDay(d, occurrence.regularDate)
                          ? Text(ctx.l10n.home_move_original,
                              style: const TextStyle(color: AppColors.green))
                          : sameDay(d, today)
                              ? Text(ctx.l10n.home_move_today,
                                  style:
                                      const TextStyle(color: AppColors.accent))
                              : null,
                      onTap: () => Navigator.pop(ctx, d),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                ctx.l10n.home_move_limit(weekdayKey(latest), shortDate(latest),
                    weekdayKey(next), shortDate(next)),
                style: const TextStyle(fontSize: 12, color: AppColors.text3),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
