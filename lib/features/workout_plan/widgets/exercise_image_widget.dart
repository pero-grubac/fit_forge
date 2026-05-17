import 'dart:io';
import 'package:fit_forge/core/theme/app_colors.dart';
import 'package:fit_forge/data/models/exercise_model.dart';
import 'package:fit_forge/data/repositories/exercise_repository.dart';
import 'package:fit_forge/features/workout_plan/providers/workout_plan_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExerciseImageWidget extends ConsumerWidget {
  const ExerciseImageWidget({
    required this.exercise,
    required this.height,
    this.editable = false,
    super.key,
  });

  final ExerciseModel exercise;
  final double        height;
  final bool          editable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = AppColors.muscleGroupColor(exercise.muscleGroup);

    return GestureDetector(
      onTap: editable ? () => _pickImage(ref) : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width:  double.infinity,
          height: height,
          child:  exercise.hasCustomImage
              ? _RealImage(path: exercise.imagePath!, onRemove: editable
              ? () => _removeImage(ref)
              : null)
              : _PlaceholderImage(exercise: exercise, color: color, editable: editable),
        ),
      ),
    );
  }

  Future<void> _pickImage(WidgetRef ref) async {
    await ExerciseRepository().pickAndSaveImage(exercise.id);
    ref.invalidate(exercisesProvider(exercise.planId));
  }

  Future<void> _removeImage(WidgetRef ref) async {
    await ExerciseRepository().removeImage(exercise.id, exercise.imagePath!);
    ref.invalidate(exercisesProvider(exercise.planId));
  }
}

class _RealImage extends StatelessWidget {
  const _RealImage({required this.path, this.onRemove});
  final String       path;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.file(File(path), fit: BoxFit.cover),
        if (onRemove != null)
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              color: Colors.black54,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Promijeni sliku',
                      style: TextStyle(fontSize: 12, color: Colors.white)),
                  GestureDetector(
                    onTap: onRemove,
                    child: const Icon(Icons.delete_outline,
                        size: 18, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  const _PlaceholderImage({
    required this.exercise,
    required this.color,
    required this.editable,
  });
  final ExerciseModel exercise;
  final Color         color;
  final bool          editable;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color.withOpacity(0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_muscleIcon(), size: 40, color: color.withOpacity(0.6)),
          const SizedBox(height: 8),
          Text(
            editable ? 'Tapni za dodavanje slike' : exercise.muscleGroup,
            style: TextStyle(fontSize: 12, color: color.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }

  IconData _muscleIcon() => switch (exercise.muscleGroup) {
    'Chest'     => Icons.fitness_center,
    'Back'      => Icons.accessibility_new,
    'Shoulders' => Icons.sports_handball,
    'Biceps'    => Icons.sports_gymnastics,
    'Triceps'   => Icons.sports_martial_arts,
    'Legs'      => Icons.directions_run,
    'Core'      => Icons.circle_outlined,
    _           => Icons.fitness_center,
  };
}