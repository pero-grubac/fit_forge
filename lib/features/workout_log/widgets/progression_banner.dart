import 'package:fit_forge/core/models/progression_suggestion.dart';
import 'package:fit_forge/core/theme/app_colors.dart';
import 'package:fit_forge/core/utils/l10n_extension.dart';
import 'package:flutter/material.dart';

class ProgressionBanner extends StatelessWidget {
  const ProgressionBanner({super.key, required this.suggestion});

  final ProgressionSuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    final color = switch (suggestion.action) {
      ProgressionAction.increase => AppColors.green,
      ProgressionAction.hold => AppColors.amber,
      ProgressionAction.reduce => AppColors.red,
      ProgressionAction.noData => AppColors.accent,
    };
    final l10n = context.l10n;
    final message = switch ((suggestion.action, suggestion.unit)) {
      (ProgressionAction.increase, ProgressionUnit.kg) =>
        l10n.log_progression_increase(_formatKg(suggestion.increment)),
      (ProgressionAction.increase, ProgressionUnit.reps) =>
        l10n.log_progression_increase_reps(suggestion.increment.round()),
      (ProgressionAction.increase, ProgressionUnit.seconds) =>
        l10n.log_progression_increase_seconds(suggestion.increment.round()),
      (ProgressionAction.hold, ProgressionUnit.kg) => l10n.log_progression_hold,
      (ProgressionAction.hold, _) => l10n.log_progression_hold_reps,
      (ProgressionAction.reduce, ProgressionUnit.kg) =>
        l10n.log_progression_reduce,
      (ProgressionAction.reduce, _) => l10n.log_progression_reduce_reps,
      (ProgressionAction.noData, _) => '',
    };

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.trending_up_rounded, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.log_progression_title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(message,
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.text2)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatKg(double kg) =>
      kg == kg.roundToDouble() ? kg.toStringAsFixed(0) : kg.toString();
}
