import 'package:fit_forge/core/theme/app_colors.dart';
import 'package:fit_forge/core/utils/l10n_extension.dart';
import 'package:fit_forge/data/models/workout_log_model.dart';
import 'package:flutter/material.dart';

class StatCards extends StatelessWidget {
  const StatCards({
    super.key,
    required this.maxWeight,
    required this.totalSessions,
    required this.logs,
  });

  final double maxWeight;
  final int totalSessions;
  final List<WorkoutLogModel> logs;

  @override
  Widget build(BuildContext context) {
    final growth = _growthPercent();

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: Row(
        children: [
          Expanded(
              child: _StatCard(
                  value: '${maxWeight.toStringAsFixed(1)} kg',
                  label: context.l10n.progress_max_weight)),
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
    final oldest = _maxForLog(sorted.first); // najstariji
    final newest = _maxForLog(sorted.last); // najnoviji

    if (oldest == 0) return null;
    return ((newest - oldest) / oldest) * 100;
  }

  double _maxForLog(WorkoutLogModel log) {
    if (log.sets.isEmpty) return 0;
    return log.sets
        .where((s) => s.isCompleted)
        .map((s) => s.actualWeight)
        .fold(0.0, (max, w) => w > max ? w : max);
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
