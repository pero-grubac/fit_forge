import 'package:fit_forge/core/theme/app_colors.dart';
import 'package:fit_forge/core/utils/l10n_extension.dart';
import 'package:fit_forge/data/models/workout_log_model.dart';
import 'package:flutter/material.dart';

class PersonalRecords extends StatelessWidget {
  const PersonalRecords({super.key, required this.logs});

  final List<WorkoutLogModel> logs;

  @override
  Widget build(BuildContext context) {
    // Nadji max tezinu i datum
    WorkoutLogModel? bestLog;
    double bestWeight = 0;

    for (final log in logs) {
      for (final s in log.sets) {
        if (s.isCompleted && s.actualWeight > bestWeight) {
          bestWeight = s.actualWeight;
          bestLog = log;
        }
      }
    }

    if (bestLog == null) return const SizedBox.shrink();

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
              color: AppColors.amber.withOpacity(0.15),
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
                Text('${bestWeight.toStringAsFixed(1)} kg',
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text1)),
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
