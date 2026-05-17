import 'package:fit_forge/core/theme/app_colors.dart';
import 'package:fit_forge/data/models/exercise_model.dart';
import 'package:fit_forge/features/workout_log/pages/log_session_page.dart';
import 'package:fit_forge/features/workout_log/providers/workout_log_provider.dart';
import 'package:fit_forge/features/workout_log/widgets/exercise_hero_card.dart';
import 'package:fit_forge/features/workout_plan/providers/workout_plan_provider.dart';
import 'package:fit_forge/shared/widgets/error_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TodayWorkoutPage extends ConsumerWidget {
  const TodayWorkoutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayPlan = ref.watch(todayPlanProvider);

    return Scaffold(
      body: SafeArea(
        child: todayPlan.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ErrorState(
            onRetry: () => ref.invalidate(todayPlanProvider),
          ),
          data: (plan) => plan == null
              ? _EmptyState()
              : _PlanContent(planId: plan.id, planName: plan.name),
        ),
      ),
    );
  }
}

class _PlanContent extends ConsumerWidget {
  const _PlanContent({required this.planId, required this.planName});

  final String planId;
  final String planName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercises = ref.watch(exercisesProvider(planId));

    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _greeting(),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 13, color: AppColors.text2),
                    const SizedBox(width: 5),
                    Text(
                      '${_dayName()}  ·  $planName',
                      style:
                          const TextStyle(fontSize: 13, color: AppColors.text2),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Motivaciona poruka
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                AppColors.accent.withOpacity(0.1),
                AppColors.green.withOpacity(0.06),
              ]),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.accent.withOpacity(0.18)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Motivacija dana',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accent)),
                const SizedBox(height: 4),
                Text(
                  _motivationMessage(),
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.text2,
                      fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ),

        // Lista vjezbi
        exercises.when(
          loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator())),
          error: (e, _) => ErrorState(
            onRetry: () => ref.invalidate(exercisesProvider),
          ),
          data: (list) {
            final exerciseIds = list.map((e) => e.id).toList();
            final joined = exerciseIds.join(',');
            final completedAsync =
                ref.watch(completedSetsTodayProvider(joined));

            return completedAsync.when(
              loading: () => const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator())),
              error: (e, _) => ErrorState(
                onRetry: () => ref.invalidate(exercisesProvider),
              ),
              data: (completed) => SliverPadding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final ex = list[i];
                      final completedSets = completed[ex.id] ?? 0;
                      final totalSets = ex.defaultSets.length;
                      final isDone =
                          completedSets >= totalSets && completedSets > 0;
                      final isActive = completedSets > 0 && !isDone;

                      return ExerciseHeroCard(
                        exercise: ex,
                        completedSets: completedSets,
                        totalSets: totalSets,
                        isActive: isActive,
                        onTap: () => _openLogSession(context, ref, ex, joined),
                      );
                    },
                    childCount: list.length,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _openLogSession(BuildContext context, WidgetRef ref,
      ExerciseModel exercise, String joined) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LogSessionPage(exerciseId: exercise.id),
      ),
    ).then((_) {
      ref.invalidate(completedSetsTodayProvider(joined));
    });
  }

  Widget _greeting() {
    final hour = DateTime.now().hour;
    final greet = hour < 12
        ? 'Dobro jutro'
        : hour < 18
            ? 'Dobar dan'
            : 'Dobro vece';
    return Text(
      greet,
      style: const TextStyle(
          fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.text1),
    );
  }

  String _dayName() {
    const days = [
      '',
      'Ponedjeljak',
      'Utorak',
      'Srijeda',
      'Cetvrtak',
      'Petak',
      'Subota',
      'Nedjelja'
    ];
    return days[DateTime.now().weekday];
  }

  String _motivationMessage() {
    const messages = [
      'Svaki kilogram koji dignes je dokaz tvoje snage.',
      'Ne pitaj se kako ces — pitaj se zasto neces.',
      'Snaga se ne gradi za jedan dan. Gradi se trening po trening.',
      'Tezina ne laze. Niti ti.',
      'Svaki trening je investicija u sebe.',
    ];
    final index = DateTime.now().day % messages.length;
    return '"${messages[index]}"';
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fitness_center, size: 64, color: AppColors.text3),
          SizedBox(height: 16),
          Text(
            'Nemas plan za danas',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.text2),
          ),
          SizedBox(height: 8),
          Text(
            'Kreiraj plan u Plan editoru',
            style: TextStyle(fontSize: 14, color: AppColors.text3),
          ),
        ],
      ),
    );
  }
}
