import 'package:fit_forge/core/theme/app_colors.dart';
import 'package:fit_forge/data/models/exercise_model.dart';
import 'package:flutter/material.dart';

class ExerciseDropdown extends StatelessWidget {
  const ExerciseDropdown({
    super.key,
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
