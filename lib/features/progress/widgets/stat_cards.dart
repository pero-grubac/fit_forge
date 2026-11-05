import 'package:fit_forge/core/theme/app_colors.dart';
import 'package:fit_forge/core/utils/l10n_extension.dart';
import 'package:fit_forge/core/utils/set_progression.dart';
import 'package:fit_forge/data/models/workout_log_model.dart';
import 'package:fit_forge/features/workout_log/widgets/progression_banner.dart';
import 'package:flutter/material.dart';

class StatCards extends StatelessWidget {
  const StatCards({
    super.key,
    required this.bestMetric,
    required this.unit,
    required this.totalSessions,
    required this.logs,
  });

  /// Max weight (kg), reps, or seconds for the period, matching [unit].
  final double bestMetric;
  final ProgressionUnit unit;
  final int totalSessions;
  final List<WorkoutLogModel> logs;

  @override
  Widget build(BuildContext context) {
    final growth = _growthPercent();
    final bestLabel = switch (unit) {
      ProgressionUnit.kg => context.l10n.progress_max_weight,
      ProgressionUnit.reps => context.l10n.progress_max_reps,
      ProgressionUnit.seconds => context.l10n.progress_max_seconds,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: Row(
        children: [
          Expanded(
              child: _StatCard(
                  value: formatLevel(context, bestMetric, unit),
                  label: bestLabel)),
          const SizedBox(width: 8),
          Expanded(
              child: _StatCard(
                  value: '$totalSessions',
                  label: context.l10n.progress_sessions)),
          const SizedBox(width: 8),
          Expanded(
              child: _StatCard(
            value: growth == null ? '-' : '${growth.toStringAsFixed(0)}%',
            label: context.l10n.progress_growth,
            valueColor: growth != null && growth > 0 ? AppColors.green : null,
          )),
        ],
      ),
    );
  }

  double? _growthPercent() {
    if (logs.length < 2) return null;

    final sorted = [...logs]..sort((a, b) => a.logDate.compareTo(b.logDate));
    final oldest = _maxForLog(sorted.first); // oldest
    final newest = _maxForLog(sorted.last); // newest

    if (oldest == 0) return null;
    return ((newest - oldest) / oldest) * 100;
  }

  double _maxForLog(WorkoutLogModel log) {
    final completed = log.sets.where((s) => s.isCompleted);
    if (completed.isEmpty) return 0;
    return unit == ProgressionUnit.kg
        ? completed.map((s) => s.actualWeight).fold(0.0, (m, w) => w > m ? w : m)
        : completed
            .map((s) => s.actualReps.toDouble())
            .fold(0.0, (m, w) => w > m ? w : m);
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label, this.valueColor});

  final String value;
  final String label;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: valueColor ?? AppColors.text1)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(fontSize: 11, color: AppColors.text3),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
