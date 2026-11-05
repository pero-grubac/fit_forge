import 'package:fit_forge/core/theme/app_colors.dart';
import 'package:fit_forge/core/utils/l10n_extension.dart';
import 'package:fit_forge/core/utils/one_rep_max.dart';
import 'package:fit_forge/core/utils/set_progression.dart';
import 'package:fit_forge/data/models/exercise_model.dart';
import 'package:fit_forge/data/models/workout_log_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class WeightLineChart extends StatelessWidget {
  const WeightLineChart(
      {super.key, required this.logs, required this.exercise, this.onPointTap});

  final List<WorkoutLogModel> logs;
  final ExerciseModel exercise;

  /// Called with the session a chart point belongs to when it's tapped.
  final ValueChanged<WorkoutLogModel>? onPointTap;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.muscleGroupColor(exercise.muscleGroup);
    final sorted = [...logs]..sort((a, b) => a.logDate.compareTo(b.logDate));
    final unit = exercise.progressionUnit;

    final spots = sorted.asMap().entries.map((e) {
      final completed = e.value.sets.where((s) => s.isCompleted);
      final best = unit == ProgressionUnit.kg
          ? completed.map((s) => s.actualWeight).fold(0.0, (m, w) => w > m ? w : m)
          : completed
              .map((s) => s.actualReps.toDouble())
              .fold(0.0, (m, w) => w > m ? w : m);
      return FlSpot(e.key.toDouble(), best);
    }).toList();

    if (spots.isEmpty) return const SizedBox.shrink();

    final chartTitle = switch (unit) {
      ProgressionUnit.kg => context.l10n.progress_chart_weight,
      ProgressionUnit.reps => context.l10n.progress_chart_reps,
      ProgressionUnit.seconds => context.l10n.progress_chart_seconds,
    };

    // Estimated 1RM only means something for weighted exercises.
    final oneRmSpots = exercise.isWeighted
        ? [
            for (final (i, log) in sorted.indexed)
              FlSpot(i.toDouble(), bestOneRepMax(log)),
          ]
        : <FlSpot>[];

    final allY = [...spots, ...oneRmSpots].map((s) => s.y);
    final minY = allY.reduce((a, b) => a < b ? a : b) * 0.9;
    final maxY = allY.reduce((a, b) => a > b ? a : b) * 1.1;

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      padding: const EdgeInsets.fromLTRB(12, 16, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(chartTitle,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text2)),
          if (oneRmSpots.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                _LegendItem(
                    color: color, label: context.l10n.progress_max_weight),
                const SizedBox(width: 16),
                _LegendItem(
                  color: color.withValues(alpha: 0.5),
                  label: context.l10n.progress_one_rep_max,
                  dashed: true,
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    // fl_chart's default tooltip, with the value rounded.
                    getTooltipItems: (spots) => [
                      for (final spot in spots)
                        LineTooltipItem(
                          _formatValue(spot.y),
                          TextStyle(
                            color: spot.bar.color ?? Colors.blueGrey,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                  touchCallback: (event, response) {
                    if (event is! FlTapUpEvent) return;
                    final spots = response?.lineBarSpots;
                    if (spots == null || spots.isEmpty) return;
                    final primary = spots.firstWhere(
                        (s) => s.barIndex == 0, orElse: () => spots.first);
                    final index = primary.spotIndex;
                    if (index >= 0 && index < sorted.length) {
                      onPointTap?.call(sorted[index]);
                    }
                  },
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) =>
                      const FlLine(color: AppColors.border, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (v, _) => Text(
                        '${v.toInt()}',
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.text3),
                      ),
                    ),
                  ),
                  bottomTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: color,
                    barWidth: 2.5,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, _, __, i) => FlDotCirclePainter(
                        radius: i == spots.length - 1 ? 5 : 3,
                        color: color,
                        strokeWidth: 0,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          color.withValues(alpha: 0.2),
                          color.withValues(alpha: 0)
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  if (oneRmSpots.isNotEmpty)
                    LineChartBarData(
                      spots: oneRmSpots,
                      isCurved: true,
                      color: color.withValues(alpha: 0.5),
                      barWidth: 2,
                      dashArray: const [6, 4],
                      dotData: const FlDotData(show: false),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// At most two decimals, without trailing zeros: 75.83, 67.5, 65.
String _formatValue(double v) {
  final s = v.toStringAsFixed(2);
  return s.replaceFirst(RegExp(r'\.?0+$'), '');
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    this.dashed = false,
  });

  final Color color;
  final String label;
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (dashed)
          for (var i = 0; i < 2; i++)
            Container(
              width: 6,
              height: 2,
              margin: const EdgeInsets.only(right: 3),
              color: color,
            )
        else
          Container(width: 15, height: 2.5, color: color),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(fontSize: 11, color: AppColors.text3)),
      ],
    );
  }
}
