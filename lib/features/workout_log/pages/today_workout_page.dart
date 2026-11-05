import 'package:fit_forge/core/theme/app_colors.dart';
import 'package:fit_forge/core/utils/l10n_extension.dart';
import 'package:fit_forge/core/utils/plan_schedule.dart';
import 'package:fit_forge/data/models/plan_exercise_model.dart';
import 'package:fit_forge/data/models/plan_reschedule_model.dart';
import 'package:fit_forge/features/settings/providers/quote_provider.dart';
import 'package:fit_forge/features/settings/widgets/motivational_banner.dart';
import 'package:fit_forge/features/workout_log/pages/log_session_page.dart';
import 'package:fit_forge/features/workout_log/providers/streak_provider.dart';
import 'package:fit_forge/features/workout_log/providers/workout_log_provider.dart';
import 'package:fit_forge/features/workout_log/widgets/exercise_hero_card.dart';
import 'package:fit_forge/features/workout_log/widgets/move_workout_sheet.dart';
import 'package:fit_forge/features/workout_log/widgets/weekly_summary_card.dart';
import 'package:fit_forge/features/workout_plan/providers/workout_plan_provider.dart';
import 'package:fit_forge/shared/widgets/error_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TodayWorkoutPage extends ConsumerWidget {
  const TodayWorkoutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(homeScheduleProvider);

    return Scaffold(
      body: SafeArea(
        child: home.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ErrorState(
            onRetry: () => ref.invalidate(homeScheduleProvider),
          ),
          data: (home) =>
              home.plans.isEmpty ? _EmptyState() : _PlansContent(home: home),
        ),
      ),
    );
  }
}

/// Opens the day picker for [o] and moves it to the chosen day.
Future<void> _moveWorkout(BuildContext context, WidgetRef ref,
    HomeSchedule home, PlanOccurrence o) async {
  final days = home.schedule.targetDays(o, home.today);
  if (days.isEmpty) return;
  final to = await showMoveWorkoutSheet(
    context,
    planName: home.plans[o.planId]!.name,
    occurrence: o,
    days: days,
    today: home.today,
  );
  if (to == null) return;
  await ref.read(workoutPlanNotifierProvider.notifier).moveWorkout(o, to);
}

class _PlansContent extends ConsumerWidget {
  const _PlansContent({required this.home});

  final HomeSchedule home;

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

        // This week's progress, if any
        const SliverToBoxAdapter(
          child: WeeklySummaryCard(),
        ),

        // One section per workout due today
        for (final o in home.dueToday)
          _PlanSection(
            home: home,
            occurrence: o,
            planName: home.plans[o.planId]!.name,
          ),

        // Today's workouts moved to another day
        for (final o in home.movedAway)
          SliverToBoxAdapter(child: _MovedAwayStrip(home: home, occurrence: o)),

        if (home.dueToday.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
              child: Text(context.l10n.home_noplan,
                  style: const TextStyle(fontSize: 14, color: AppColors.text2)),
            ),
          ),

        if (home.upcoming.isNotEmpty)
          SliverToBoxAdapter(child: _UpcomingSection(home: home)),

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
  const _PlanSection({
    required this.home,
    required this.occurrence,
    required this.planName,
  });

  final HomeSchedule home;
  final PlanOccurrence occurrence;
  final String planName;

  String get planId => occurrence.planId;

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
              // Plan name header; started workouts can't be moved.
              _PlanHeader(
                planName: planName,
                occurrence: occurrence,
                onMove: completed.values.any((n) => n > 0) ||
                        home.schedule.targetDays(occurrence, home.today).isEmpty
                    ? null
                    : () => _moveWorkout(context, ref, home, occurrence),
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

/// "Full Body · from Thursday 5.11.  [⇄]"
class _PlanHeader extends StatelessWidget {
  const _PlanHeader({
    required this.planName,
    required this.occurrence,
    required this.onMove,
  });

  final String planName;
  final PlanOccurrence occurrence;

  /// Null hides the move button.
  final VoidCallback? onMove;

  @override
  Widget build(BuildContext context) {
    final from = occurrence.regularDate;
    return Padding(
      padding: EdgeInsets.fromLTRB(18, 8, onMove == null ? 18 : 6, 4),
      child: Row(
        children: [
          Expanded(
            child: Text.rich(
              TextSpan(children: [
                TextSpan(
                  text: planName,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text2),
                ),
                if (occurrence.isMoved)
                  TextSpan(
                    text:
                        '  ·  ${context.l10n.home_moved_from(weekdayKey(from), shortDate(from))}',
                    style: const TextStyle(fontSize: 12, color: AppColors.text3),
                  ),
              ]),
            ),
          ),
          if (onMove != null)
            IconButton(
              key: Key('move_${occurrence.planId}'),
              tooltip: context.l10n.home_move,
              onPressed: onMove,
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.swap_horiz_rounded,
                  size: 20, color: AppColors.text2),
            ),
        ],
      ),
    );
  }
}

/// A workout of today moved to another day; tap to change or undo the move.
class _MovedAwayStrip extends ConsumerWidget {
  const _MovedAwayStrip({required this.home, required this.occurrence});

  final HomeSchedule home;
  final PlanOccurrence occurrence;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final to = occurrence.dueDate;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
      child: Material(
        color: AppColors.bg2,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          key: Key('moved_away_${occurrence.planId}'),
          borderRadius: BorderRadius.circular(12),
          onTap: () => _moveWorkout(context, ref, home, occurrence),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text.rich(
                    TextSpan(children: [
                      TextSpan(
                        text: home.plans[occurrence.planId]!.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, color: AppColors.text3),
                      ),
                      TextSpan(
                        text:
                            '  ·  ${context.l10n.home_moved_to(weekdayKey(to), shortDate(to))}',
                        style: const TextStyle(color: AppColors.text3),
                      ),
                    ]),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                const Icon(Icons.swap_horiz_rounded,
                    size: 20, color: AppColors.text3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Workouts of the next days, each movable — e.g. to do one today.
class _UpcomingSection extends ConsumerWidget {
  const _UpcomingSection({required this.home});

  final HomeSchedule home;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Text(context.l10n.home_upcoming,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: AppColors.text3)),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                for (final (i, o) in home.upcoming.indexed) ...[
                  if (i > 0) const Divider(height: 1, color: AppColors.border),
                  _UpcomingRow(home: home, occurrence: o),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingRow extends ConsumerWidget {
  const _UpcomingRow({required this.home, required this.occurrence});

  final HomeSchedule home;
  final PlanOccurrence occurrence;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final due = occurrence.dueDate;
    final canMove = home.schedule.targetDays(occurrence, home.today).isNotEmpty;
    return Padding(
      padding: EdgeInsets.fromLTRB(14, canMove ? 2 : 14, 4, canMove ? 2 : 14),
      child: Row(
        children: [
          SizedBox(
            width: 128,
            child: Text('${weekdayName(context, due)} ${shortDate(due)}',
                style: const TextStyle(fontSize: 13, color: AppColors.text2)),
          ),
          Expanded(
            child: Text.rich(
              TextSpan(children: [
                TextSpan(
                  text: home.plans[occurrence.planId]!.name,
                  style: const TextStyle(color: AppColors.text1),
                ),
                if (occurrence.isMoved)
                  TextSpan(
                    text: '  ·  ${context.l10n.home_moved_tag}',
                    style: const TextStyle(color: AppColors.text3),
                  ),
              ]),
              style: const TextStyle(fontSize: 13),
            ),
          ),
          if (canMove)
            IconButton(
              key: Key(
                  'move_${occurrence.planId}_${dayKey(occurrence.regularDate)}'),
              tooltip: context.l10n.home_move,
              onPressed: () => _moveWorkout(context, ref, home, occurrence),
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.swap_horiz_rounded,
                  size: 20, color: AppColors.text2),
            ),
        ],
      ),
    );
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
