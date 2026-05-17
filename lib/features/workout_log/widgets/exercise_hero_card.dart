import 'package:fit_forge/core/theme/app_colors.dart';
import 'package:fit_forge/data/models/exercise_model.dart';
import 'package:fit_forge/shared/widgets/muscle_group_badge.dart';
import 'package:flutter/material.dart';

class ExerciseHeroCard extends StatelessWidget {
  const ExerciseHeroCard({
    required this.exercise,
    required this.completedSets,
    required this.totalSets,
    required this.onTap,
    this.isActive = false,
    super.key,
  });

  final ExerciseModel exercise;
  final int completedSets;
  final int totalSets;
  final VoidCallback onTap;
  final bool isActive;

  bool get _isDone => completedSets >= totalSets && completedSets > 0;
  double get _progress => totalSets == 0 ? 0 : completedSets / totalSets;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.muscleGroupColor(exercise.muscleGroup);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? AppColors.accent : AppColors.border,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            // Hero banner
            Container(
              height: 72,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.2), AppColors.bg3],
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  MuscleGroupBadge(muscleGroup: exercise.muscleGroup),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(exercise.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text1,
                            )),
                        const SizedBox(height: 2),
                        Text(exercise.muscleGroup,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.text2,
                            )),
                      ],
                    ),
                  ),
                  _StatusBadge(isDone: _isDone, isActive: isActive),
                ],
              ),
            ),

            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: _progress,
                        backgroundColor: AppColors.bg4,
                        valueColor: AlwaysStoppedAnimation(
                          _isDone ? AppColors.green : AppColors.accent,
                        ),
                        minHeight: 4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '$completedSets/$totalSets seta',
                    style:
                        const TextStyle(fontSize: 11, color: AppColors.text3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isDone, required this.isActive});

  final bool isDone;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    if (isDone) {
      return _badge(AppColors.green, Icons.check, 'Gotovo');
    }
    if (isActive) {
      return _badge(AppColors.accent, Icons.radio_button_checked, 'Aktivno');
    }
    return _badge(AppColors.text3, Icons.radio_button_unchecked, 'Ceka');
  }

  Widget _badge(Color color, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
