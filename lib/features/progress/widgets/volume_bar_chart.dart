import 'package:fit_forge/core/theme/app_colors.dart';
import 'package:fit_forge/core/utils/l10n_extension.dart';
import 'package:fit_forge/data/models/workout_log_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class VolumeBarChart extends StatelessWidget {
  const VolumeBarChart({super.key, required this.logs});

  final List<WorkoutLogModel> logs;

  @override
  Widget build(BuildContext context) {
    final sorted = [...logs]..sort((a, b) => a.logDate.compareTo(b.logDate));
    final last7 =
        sorted.length > 7 ? sorted.sublist(sorted.length - 7) : sorted;

    final bars = last7.asMap().entries.map((e) {
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: e.value.totalVolume,
            color: e.key == last7.length - 1 ? AppColors.accent : AppColors.bg4,
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    if (bars.isEmpty) return const SizedBox.shrink();

    final maxVol =
        last7.map((l) => l.totalVolume).fold(0.0, (a, b) => a > b ? a : b);

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
          Text(context.l10n.progress_chart_volume,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text2)),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: BarChart(
              BarChartData(
                maxY: maxVol * 1.2,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i >= last7.length) return const SizedBox.shrink();
                        final d = last7[i].logDate;
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text('${d.day}/${d.month}',
                              style: const TextStyle(
                                  fontSize: 9, color: AppColors.text3)),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                barGroups: bars,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
