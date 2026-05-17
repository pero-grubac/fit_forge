import 'package:fit_forge/core/theme/app_colors.dart';
import 'package:fit_forge/data/models/exercise_model.dart';
import 'package:fit_forge/data/models/workout_log_model.dart';
import 'package:fit_forge/features/progress/providers/progress_provider.dart';
import 'package:fit_forge/features/workout_plan/providers/workout_plan_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProgressPage extends ConsumerStatefulWidget {
  const ProgressPage({super.key});

  @override
  ConsumerState<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends ConsumerState<ProgressPage> {
  ExerciseModel? _selectedExercise;
  int _periodDays = 90; // default 3 mj

  @override
  Widget build(BuildContext context) {
    final allExercises = ref.watch(allExercisesProvider);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(18, 16, 18, 16),
                child: Text('Progres',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text1)),
              ),
            ),

            // Dropdown za vjezbu
            SliverToBoxAdapter(
              child: allExercises.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => const SizedBox.shrink(),
                data: (list) => list.isEmpty
                    ? _EmptyState()
                    : _ExerciseDropdown(
                        exercises: list,
                        selected: _selectedExercise ?? list.first,
                        onChanged: (ex) =>
                            setState(() => _selectedExercise = ex),
                      ),
              ),
            ),

            // Period filter
            SliverToBoxAdapter(
              child: _PeriodFilter(
                selected: _periodDays,
                onChanged: (d) => setState(() => _periodDays = d),
              ),
            ),

            // Grafovi i statistike
            if (_selectedExercise != null ||
                allExercises.value?.isNotEmpty == true)
              _ProgressContent(
                exercise: _selectedExercise ?? allExercises.value!.first,
                periodDays: _periodDays,
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}

// ── Exercise dropdown ─────────────────────────────────────────────────────────
class _ExerciseDropdown extends StatelessWidget {
  const _ExerciseDropdown({
    required this.exercises,
    required this.selected,
    required this.onChanged,
  });

  final List<ExerciseModel> exercises;
  final ExerciseModel selected;
  final ValueChanged<ExerciseModel> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<ExerciseModel>(
            value: selected,
            isExpanded: true,
            dropdownColor: AppColors.bg2,
            style: const TextStyle(color: AppColors.text1, fontSize: 14),
            icon: const Icon(Icons.expand_more, color: AppColors.text2),
            items: exercises
                .map((ex) => DropdownMenuItem(
                      value: ex,
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppColors.muscleGroupColor(ex.muscleGroup),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(ex.name),
                        ],
                      ),
                    ))
                .toList(),
            onChanged: (ex) {
              if (ex != null) onChanged(ex);
            },
          ),
        ),
      ),
    );
  }
}

// ── Period filter ─────────────────────────────────────────────────────────────

class _PeriodFilter extends StatelessWidget {
  const _PeriodFilter({required this.selected, required this.onChanged});

  final int selected;
  final ValueChanged<int> onChanged;

  static const _options = [
    (label: '1 mj', days: 30),
    (label: '3 mj', days: 90),
    (label: '6 mj', days: 180),
    (label: 'Sve', days: 9999),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
      child: Row(
        children: _options.map((opt) {
          final active = selected == opt.days;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(opt.days),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: active ? AppColors.accent : AppColors.bg3,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: active ? AppColors.accent : AppColors.border2),
                ),
                child: Text(opt.label,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: active ? Colors.white : AppColors.text2)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Progress content ──────────────────────────────────────────────────────────

class _ProgressContent extends ConsumerWidget {
  const _ProgressContent({
    required this.exercise,
    required this.periodDays,
  });

  final ExerciseModel exercise;
  final int periodDays;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(exerciseLogsByNameProvider(exercise.name));

    return logs.when(
      loading: () => const SliverToBoxAdapter(
          child: Center(child: CircularProgressIndicator())),
      error: (e, _) =>
          SliverToBoxAdapter(child: Center(child: Text('Greska: $e'))),
      data: (allLogs) {
        final cutoff = DateTime.now().subtract(Duration(days: periodDays));
        final filtered = periodDays == 9999
            ? allLogs
            : allLogs.where((l) => l.logDate.isAfter(cutoff)).toList();

        if (filtered.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: Text('Nema podataka za odabrani period',
                    style: TextStyle(color: AppColors.text2)),
              ),
            ),
          );
        }

        final maxWeight = _maxWeight(filtered);
        final totalSessions = filtered.length;

        return SliverList(
          delegate: SliverChildListDelegate([
            // Stat kartice
            _StatCards(
              maxWeight: maxWeight,
              totalSessions: totalSessions,
              logs: filtered,
            ),
            // Line chart
            _WeightLineChart(logs: filtered, exercise: exercise),
            // Bar chart
            _VolumeBarChart(logs: filtered),
            // Osobni rekordi
            _PersonalRecords(logs: allLogs),
          ]),
        );
      },
    );
  }

  double _maxWeight(List<WorkoutLogModel> logs) {
    if (logs.isEmpty) return 0;
    return logs
        .expand((l) => l.sets)
        .where((s) => s.isCompleted)
        .map((s) => s.actualWeight)
        .fold(0.0, (max, w) => w > max ? w : max);
  }
}

// ── Stat cards ────────────────────────────────────────────────────────────────

class _StatCards extends StatelessWidget {
  const _StatCards({
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
                  label: 'Max tezina')),
          const SizedBox(width: 8),
          Expanded(
              child: _StatCard(value: '$totalSessions', label: 'Treninga')),
          const SizedBox(width: 8),
          Expanded(
              child: _StatCard(
            value: growth == null ? '-' : '${growth.toStringAsFixed(0)}%',
            label: 'Rast snage',
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

// ── Line chart ────────────────────────────────────────────────────────────────

class _WeightLineChart extends StatelessWidget {
  const _WeightLineChart({required this.logs, required this.exercise});

  final List<WorkoutLogModel> logs;
  final ExerciseModel exercise;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.muscleGroupColor(exercise.muscleGroup);
    final sorted = [...logs]..sort((a, b) => a.logDate.compareTo(b.logDate));

    final spots = sorted.asMap().entries.map((e) {
      final maxW = e.value.sets
          .where((s) => s.isCompleted)
          .map((s) => s.actualWeight)
          .fold(0.0, (max, w) => w > max ? w : max);
      return FlSpot(e.key.toDouble(), maxW);
    }).toList();

    if (spots.isEmpty) return const SizedBox.shrink();

    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b) * 0.9;
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.1;

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
          const Text('Max tezina po treningu',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text2)),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: AppColors.border, strokeWidth: 1),
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
                  bottomTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                        colors: [color.withOpacity(0.2), color.withOpacity(0)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
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

// ── Bar chart ─────────────────────────────────────────────────────────────────

class _VolumeBarChart extends StatelessWidget {
  const _VolumeBarChart({required this.logs});

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
          const Text('Volumen po treningu',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text2)),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: BarChart(
              BarChartData(
                maxY: maxVol * 1.2,
                gridData: FlGridData(show: false),
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
                  leftTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
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

// ── Personal records ──────────────────────────────────────────────────────────

class _PersonalRecords extends StatelessWidget {
  const _PersonalRecords({required this.logs});

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
                const Text('Osobni rekord',
                    style: TextStyle(fontSize: 12, color: AppColors.text2)),
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

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(60),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.bar_chart_rounded, size: 64, color: AppColors.text3),
              SizedBox(height: 16),
              Text('Nemas jos nikakav trening',
                  style: TextStyle(fontSize: 16, color: AppColors.text2)),
              SizedBox(height: 8),
              Text('Pokreni trening na Home ekranu',
                  style: TextStyle(fontSize: 13, color: AppColors.text3)),
            ],
          ),
        ),
      ),
    );
  }
}
