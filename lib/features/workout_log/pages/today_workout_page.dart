import 'package:fit_forge/core/theme/app_colors.dart';
import 'package:fit_forge/core/utils/l10n_extension.dart';
import 'package:fit_forge/data/models/plan_exercise_model.dart';
import 'package:fit_forge/data/models/workout_plan_model.dart';
import 'package:fit_forge/features/settings/providers/quote_provider.dart';
import 'package:fit_forge/features/settings/widgets/motivational_banner.dart';
import 'package:fit_forge/features/workout_log/pages/log_session_page.dart';
import 'package:fit_forge/features/workout_log/providers/streak_provider.dart';
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
    final todayPlans = ref.watch(todayPlansProvider);

    return Scaffold(
      body: SafeArea(
        child: todayPlans.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ErrorState(
            onRetry: () => ref.invalidate(todayPlansProvider),
          ),
          data: (plans) =>
              plans.isEmpty ? _EmptyState() : _PlansContent(plans: plans),
        ),
      ),
    );
  }
}

class _PlansContent extends ConsumerWidget {
  const _PlansContent({required this.plans});

  final List<WorkoutPlanModel> plans;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _greeting(context),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 13, color: AppColors.text2),
                          const SizedBox(width: 5),
                          Text(
                            _dayName(context),
                            style: const TextStyle(
                                fontSize: 13, color: AppColors.text2),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _StreakBadge(),
              ],
            ),
          ),
        ),

        // Motivational quote
        const SliverToBoxAdapter(
          child: MotivationBanner(),
        ),

        // One section per plan
        ...plans.map((plan) => _PlanSection(
              planId: plan.id,
              planName: plan.name,
            )),

        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  Widget _greeting(BuildContext context) {
    final hour = DateTime.now().hour;
    final greet = hour < 12
        ? context.l10n.greeting_morning
        : hour < 18
            ? context.l10n.greeting_afternoon
            : context.l10n.greeting_evening;
    return Text(greet,
        style: const TextStyle(
            fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.text1));
  }

  String _dayName(BuildContext context) {
    final days = [
      '',
      context.l10n.days_monday,
      context.l10n.days_tuesday,
      context.l10n.days_wednesday,
      context.l10n.days_thursday,
      context.l10n.days_friday,
      context.l10n.days_saturday,
      context.l10n.days_sunday,
    ];
    return days[DateTime.now().weekday];
  }
}

class _PlanSection extends ConsumerWidget {
  const _PlanSection({required this.planId, required this.planName});

  final String planId;
  final String planName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercises = ref.watch(planExercisesProvider(planId));

    return exercises.when(
      loading: () => const SliverToBoxAdapter(
          child: Center(child: CircularProgressIndicator())),
      error: (e, _) => SliverToBoxAdapter(
          child: ErrorState(
              onRetry: () => ref.invalidate(planExercisesProvider(planId)))),
      data: (list) {
        final joined = list.map((pe) => pe.id).join(',');
        final completedAsync = ref.watch(completedSetsTodayProvider(joined));

        return completedAsync.when(
          loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator())),
          error: (e, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
          data: (completed) => SliverList(
            delegate: SliverChildListDelegate([
              // Plan name header
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 4),
                child: Text(planName,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text2)),
              ),
              ...list.map((pe) {
                final completedSets = completed[pe.id] ?? 0;
                final totalSets = pe.defaultSets.length;
                final isDone = completedSets >= totalSets && completedSets > 0;
                final isActive = completedSets > 0 && !isDone;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: ExerciseHeroCard(
                    exercise: pe.exercise,
                    completedSets: completedSets,
                    totalSets: totalSets,
                    isActive: isActive,
                    onTap: () => _openLogSession(context, ref, pe, joined),
                  ),
                );
              }),
            ]),
          ),
        );
      },
    );
  }

  void _openLogSession(BuildContext context, WidgetRef ref,
      PlanExerciseModel planExercise, String joined) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LogSessionPage(planExerciseId: planExercise.id),
      ),
    ).then((_) {
      ref.invalidate(completedSetsTodayProvider(joined));
      // Home is visible again: time for a new quote.
      ref.read(quoteRotationProvider.notifier).next();
    });
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.fitness_center, size: 64, color: AppColors.text3),
          const SizedBox(height: 16),
          Text(
            context.l10n.home_noplan,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.text2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.home_noplan_sub,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.text3,
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakBadge extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streakProvider);

    return streak.maybeWhen(
      data: (days) => days == 0
          ? const SizedBox.shrink()
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: AppColors.amber.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department_rounded,
                      size: 16, color: AppColors.amber),
                  const SizedBox(width: 4),
                  Text(
                    '$days',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.amber),
                  ),
                ],
              ),
            ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}
