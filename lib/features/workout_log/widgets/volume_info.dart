import 'package:fit_forge/core/theme/app_colors.dart';
import 'package:fit_forge/features/workout_log/widgets/set_row.dart';
import 'package:flutter/material.dart';

class VolumeInfo extends StatelessWidget {
  const VolumeInfo({super.key, required this.sets});

  final List<SetRow> sets;

  @override
  Widget build(BuildContext context) {
    final doneSets = sets.where((s) => s.isDone).toList();
    final volume =
        doneSets.fold(0.0, (sum, s) => sum + s.actualWeight * s.actualReps);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Ukupni volumen',
              style: TextStyle(fontSize: 13, color: AppColors.text2)),
          Text('${volume.toStringAsFixed(1)} kg',
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text1)),
        ],
      ),
    );
  }
}
