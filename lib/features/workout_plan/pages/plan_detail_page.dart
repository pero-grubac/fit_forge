import 'package:fit_forge/core/theme/app_colors.dart';
import 'package:fit_forge/core/utils/l10n_extension.dart';
import 'package:fit_forge/data/models/exercise_model.dart';
import 'package:fit_forge/data/repositories/exercise_repository.dart';
import 'package:fit_forge/features/workout_plan/providers/workout_plan_provider.dart';
import 'package:fit_forge/features/workout_plan/widgets/add_exercise_sheet.dart';
import 'package:fit_forge/features/workout_plan/widgets/exercise_image_widget.dart';
import 'package:fit_forge/shared/widgets/error_state.dart';
import 'package:fit_forge/shared/widgets/muscle_group_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/exercise_info_sheet.dart';

class PlanDetailPage extends ConsumerWidget {
  const PlanDetailPage(
      {required this.planId, required this.planName, super.key});

  final String planId;
  final String planName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercises = ref.watch(exercisesProvider(planId));

    return Scaffold(
      appBar: AppBar(
        title: Text(planName),
        backgroundColor: AppColors.bg,
      ),
      body: exercises.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorState(
          onRetry: () => ref.invalidate(exercisesProvider(planId)),
        ),
        data: (list) => list.isEmpty
            ? _EmptyState()
            : _ExerciseList(exercises: list, planId: planId, ref: ref),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddExercise(context, ref),
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          context.l10n.exercise_add,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showAddExercise(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddExerciseSheet(planId: planId, ref: ref),
    );
  }
}

class _ExerciseList extends StatelessWidget {
  const _ExerciseList({
    required this.exercises,
    required this.planId,
    required this.ref,
  });

  final List<ExerciseModel> exercises;
  final String planId;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 100),
      itemCount: exercises.length,
      itemBuilder: (context, i) {
        final ex = exercises[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              // Hero banner
              Container(
                height: 64,
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(14)),
                  gradient: LinearGradient(colors: [
                    AppColors.muscleGroupColor(ex.muscleGroup).withOpacity(0.2),
                    AppColors.bg3,
                  ]),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    MuscleGroupBadge(muscleGroup: ex.muscleGroup),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ex.name,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.text1)),
                          Text(
                            '${ex.muscleGroup}  ·  ${ex.defaultSets.length}  ${context.l10n.exercise_sets_label.toLowerCase()}',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.text2),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.info_outline,
                          color: AppColors.accent, size: 20),
                      onPressed: () => showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: AppColors.bg2,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (_) => ExerciseInfoSheet(exercise: ex),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: AppColors.red, size: 20),
                      onPressed: () => _confirmDelete(context, ex),
                    ),
                  ],
                ),
              ),
              ExerciseImageWidget(
                exercise: ex,
                height: 160,
                editable: true,
              ),
              // Default setovi info
              if (ex.defaultSets.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                  child: Row(
                    children: [
                      _InfoChip(
                          label:
                              '${ex.defaultSets.length}  ${context.l10n.exercise_sets_label.toLowerCase()}',
                          icon: Icons.repeat),
                      const SizedBox(width: 8),
                      _InfoChip(
                          label:
                              '${ex.defaultSets.first.reps}  ${context.l10n.exercise_reps_label.toLowerCase()}',
                          icon: Icons.fitness_center),
                      const SizedBox(width: 8),
                      _InfoChip(
                          label: '${ex.defaultSets.first.weight} kg',
                          icon: Icons.monitor_weight_outlined),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, ExerciseModel ex) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.bg2,
        title: Text(
          context.l10n.exercise_delete_title,
          style: const TextStyle(
            color: AppColors.text1,
          ),
        ),
        content: Text(
          context.l10n.exercise_delete_confirm(ex.name),
          style: const TextStyle(
            color: AppColors.text2,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              context.l10n.btn_cancel,
              style: const TextStyle(
                color: AppColors.text2,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ExerciseRepository().delete(ex.id);
              ref.invalidate(exercisesProvider(planId));
            },
            child: Text(context.l10n.btn_delete,
                style: const TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.bg3,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.text2),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(fontSize: 12, color: AppColors.text2)),
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
          Text(context.l10n.exercise_no_exercises,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text2)),
          const SizedBox(height: 8),
          Text(context.l10n.exercise_no_exercises_sub,
              style: const TextStyle(fontSize: 14, color: AppColors.text3)),
        ],
      ),
    );
  }
}
