import 'package:fit_forge/core/theme/app_colors.dart';
import 'package:fit_forge/core/utils/l10n_extension.dart';
import 'package:fit_forge/data/models/exercise_model.dart';
import 'package:fit_forge/data/models/workout_log_model.dart';
import 'package:fit_forge/features/progress/providers/progress_provider.dart';
import 'package:fit_forge/features/progress/widgets/exercise_dropdown.dart';
import 'package:fit_forge/features/progress/widgets/period_filter.dart';
import 'package:fit_forge/features/progress/widgets/personal_records.dart';
import 'package:fit_forge/features/progress/widgets/stat_cards.dart';
import 'package:fit_forge/features/progress/widgets/volume_bar_chart.dart';
import 'package:fit_forge/features/progress/widgets/weight_line_chart.dart';
import 'package:fit_forge/features/workout_plan/providers/workout_plan_provider.dart';
import 'package:fit_forge/shared/widgets/error_state.dart';
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
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                child: Text(
                  context.l10n.progress_title,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text1),
                ),
              ),
            ),

            // Dropdown za vjezbu
            SliverToBoxAdapter(
              child: allExercises.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => ErrorState(
                  onRetry: () => ref.invalidate(allExercisesProvider),
                ),
                data: (list) => list.isEmpty
                    ? _EmptyState()
                    : ExerciseDropdown(
                        exercises: list,
                        selected: _selectedExercise ?? list.first,
                        onChanged: (ex) =>
                            setState(() => _selectedExercise = ex),
                      ),
              ),
            ),

            // Period filter
            if (allExercises.value?.isNotEmpty == true)
              SliverToBoxAdapter(
                child: PeriodFilter(
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
      error: (e, _) => SliverToBoxAdapter(
        child: ErrorState(
          onRetry: () =>
              ref.invalidate(exerciseLogsByNameProvider(exercise.name)),
        ),
      ),
      data: (allLogs) {
        final cutoff = DateTime.now().subtract(Duration(days: periodDays));
        final filtered = periodDays == 9999
            ? allLogs
            : allLogs.where((l) => l.logDate.isAfter(cutoff)).toList();

        if (filtered.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Text(context.l10n.progress_no_data,
                    style: const TextStyle(color: AppColors.text2)),
              ),
            ),
          );
        }

        final maxWeight = _maxWeight(filtered);
        final totalSessions = filtered.length;

        return SliverList(
          delegate: SliverChildListDelegate([
            // Stat kartice
            StatCards(
              maxWeight: maxWeight,
              totalSessions: totalSessions,
              logs: filtered,
            ),
            // Line chart
            WeightLineChart(logs: filtered, exercise: exercise),
            // Bar chart
            VolumeBarChart(logs: filtered),
            // Licni rekordi
            PersonalRecords(logs: allLogs),
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

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(60),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bar_chart_rounded,
                size: 64, color: AppColors.text3),
            const SizedBox(height: 16),
            Text(context.l10n.progress_no_workouts,
                style: const TextStyle(fontSize: 16, color: AppColors.text2)),
            const SizedBox(height: 8),
            Text(context.l10n.progress_no_workouts_sub,
                style: const TextStyle(fontSize: 13, color: AppColors.text3)),
          ],
        ),
      ),
    );
  }
}
