import 'package:fit_forge/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class MuscleGroupBadge extends StatelessWidget {
  const MuscleGroupBadge({
    required this.muscleGroup,
    this.size = 40,
    super.key,
  });

  final String muscleGroup;
  final double size;

  IconData get _icon => switch (muscleGroup) {
        'Chest' => Icons.fitness_center,
        'Back' => Icons.accessibility_new,
        'Shoulders' => Icons.sports_handball,
        'Biceps' => Icons.sports_gymnastics,
        'Triceps' => Icons.sports_martial_arts,
        'Legs' => Icons.directions_run,
        'Core' => Icons.circle,
        _ => Icons.fitness_center,
      };

  @override
  Widget build(BuildContext context) {
    final color = AppColors.muscleGroupColor(muscleGroup);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      child: Icon(_icon, color: color, size: size * 0.55),
    );
  }
}
