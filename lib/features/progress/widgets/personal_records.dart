import 'package:fit_forge/core/theme/app_colors.dart';
import 'package:fit_forge/core/utils/l10n_extension.dart';
import 'package:fit_forge/core/utils/one_rep_max.dart';
import 'package:fit_forge/core/utils/set_progression.dart';
import 'package:fit_forge/data/models/workout_log_model.dart';
import 'package:fit_forge/features/workout_log/widgets/progression_banner.dart';
import 'package:flutter/material.dart';

class PersonalRecords extends StatelessWidget {
  const PersonalRecords({
    super.key,
    required this.logs,
    required this.unit,
    this.showOneRepMax = false,
  });

  final List<WorkoutLogModel> logs;
  final ProgressionUnit unit;

  /// Also show the best estimated one-rep max (weighted exercises).
  final bool showOneRepMax;

  @override
  Widget build(BuildContext context) {
    // Find the best set (weight, reps, or seconds depending on [unit]) and
    // its date.
    WorkoutLogModel? bestLog;
    double bestValue = 0;

    for (final log in logs) {
      for (final s in log.sets) {
        if (!s.isCompleted) continue;
        final value = unit == ProgressionUnit.kg
            ? s.actualWeight
            : s.actualReps.toDouble();
        if (value > bestValue) {
          bestValue = value;
          bestLog = log;
        }
      }
    }

    if (bestLog == null) return const SizedBox.shrink();

    final bestOneRm = showOneRepMax
        ? logs.map(bestOneRepMax).fold(0.0, (max, v) => v > max ? v : max)
        : 0.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.emoji_events_rounded,
                color: AppColors.amber, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.l10n.progress_personal_record,
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.text2)),
                const SizedBox(height: 2),
                Text(formatLevel(context, bestValue, unit),
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text1)),
                if (bestOneRm > 0)
                  Text(
                    '${context.l10n.progress_one_rep_max}: '
                    '${bestOneRm.toStringAsFixed(1)} kg',
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.text2),
                  ),
              ],
            ),
          ),
          Text(
            '${bestLog.logDate.day}.${bestLog.logDate.month}.${bestLog.logDate.year}',
            style: const TextStyle(fontSize: 12, color: AppColors.text3),
          ),
        ],
      ),
    );
  }
}
