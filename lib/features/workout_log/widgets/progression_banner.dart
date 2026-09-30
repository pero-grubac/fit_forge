import 'package:fit_forge/core/theme/app_colors.dart';
import 'package:fit_forge/core/utils/l10n_extension.dart';
import 'package:fit_forge/core/utils/set_progression.dart';
import 'package:flutter/material.dart';

/// Shows how many successful sets at the current level are done and what
/// comes next, e.g. "6/8 sets at 10 kg — then 12.5 kg". While moving up to a
/// new level: "Moving up to 12.5 kg: 2 of 3 sets this workout".
class ProgressionBanner extends StatelessWidget {
  const ProgressionBanner({
    super.key,
    required this.rule,
    required this.state,
    required this.unit,
    this.transition,
    this.setsInWorkout = 0,
  });

  final SetProgression rule;
  final ProgressionState state;
  final ProgressionUnit unit;
  final Transition? transition;
  final int setsInWorkout;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final moving = transition;
    final ready = moving != null || rule.setsLeft(state) == 0;
    final color = ready ? AppColors.green : AppColors.accent;
    final current = formatLevel(context, state.level, unit);
    final next = formatLevel(context, state.level + rule.increment, unit);
    final message = moving != null
        ? l10n.progression_moving(formatLevel(context, moving.to, unit),
            moving.heavySets, setsInWorkout)
        : ready
            ? l10n.progression_ready(next)
            : l10n.progression_counter(
                state.streak, rule.setsToProgress, current, next);
    final progress = moving != null
        ? (setsInWorkout == 0 ? 1.0 : moving.heavySets / setsInWorkout)
        : rule.setsToProgress == 0
            ? 1.0
            : state.streak.clamp(0, rule.setsToProgress) / rule.setsToProgress;

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
                  l10n.log_progression_title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(message,
                    key: const Key('progression_message'),
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.text2)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 5,
                    color: color,
                    backgroundColor: AppColors.bg4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "12.5 kg", "8 reps" or "30 s".
String formatLevel(BuildContext context, double level, ProgressionUnit unit) {
  return switch (unit) {
    ProgressionUnit.kg => level == level.roundToDouble()
        ? '${level.toStringAsFixed(0)} kg'
        : '${level.toStringAsFixed(level * 10 % 1 == 0 ? 1 : 2)} kg',
    ProgressionUnit.reps => context.l10n.progression_reps(level.round()),
    ProgressionUnit.seconds => '${level.round()} s',
  };
}
