import 'package:fit_forge/core/theme/app_colors.dart';
import 'package:fit_forge/core/utils/l10n_extension.dart';
import 'package:flutter/material.dart';

class SetRow {
  final int setNumber;
  final double plannedWeight;
  final int plannedReps;
  bool isDone;
  late final TextEditingController weightCtrl;
  late final TextEditingController repsCtrl;

  SetRow({
    required this.setNumber,
    required this.plannedWeight,
    required this.plannedReps,
    this.isDone = false,
  }) {
    weightCtrl = TextEditingController(text: plannedWeight.toString());
    repsCtrl = TextEditingController(text: plannedReps.toString());
  }

  double get actualWeight => double.tryParse(weightCtrl.text) ?? plannedWeight;

  int get actualReps => int.tryParse(repsCtrl.text) ?? plannedReps;
}

class SetRowWidget extends StatelessWidget {
  const SetRowWidget({
    super.key,
    required this.set,
    required this.onToggle,
    required this.isLast,
  });

  final SetRow set;
  final VoidCallback onToggle;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            children: [
              // Broj seta
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: set.isDone
                      ? AppColors.green.withOpacity(0.15)
                      : AppColors.bg4,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text('${set.setNumber}',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color:
                              set.isDone ? AppColors.green : AppColors.text2)),
                ),
              ),
              const SizedBox(width: 8),

              // Tezina
              Expanded(
                child: TextField(
                  controller: set.weightCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.text1, fontSize: 14),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    fillColor: AppColors.bg3,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9),
                      borderSide: const BorderSide(color: AppColors.border2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9),
                      borderSide: const BorderSide(color: AppColors.border2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Repovi
              Expanded(
                child: TextField(
                  controller: set.repsCtrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.text1, fontSize: 14),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    fillColor: AppColors.bg3,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9),
                      borderSide: const BorderSide(color: AppColors.border2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9),
                      borderSide: const BorderSide(color: AppColors.border2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Check dugme
              GestureDetector(
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: set.isDone
                        ? AppColors.green.withOpacity(0.15)
                        : AppColors.bg3,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: set.isDone ? AppColors.green : AppColors.border2,
                      width: 1.5,
                    ),
                  ),
                  child: set.isDone
                      ? const Icon(Icons.check_rounded,
                          size: 18, color: AppColors.green)
                      : null,
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, color: AppColors.border),
      ],
    );
  }
}

class SetsTable extends StatelessWidget {
  const SetsTable({super.key, required this.sets, required this.onToggle});

  final List<SetRow> sets;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                const SizedBox(width: 30),
                Expanded(
                  child: Text(
                    context.l10n.exercise_weight_label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.text3,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    context.l10n.exercise_reps_label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.text3,
                    ),
                  ),
                ),
                const SizedBox(width: 36),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Setovi
          ...sets.asMap().entries.map((e) {
            final i = e.key;
            final set = e.value;
            return SetRowWidget(
              set: set,
              onToggle: () => onToggle(i),
              isLast: i == sets.length - 1,
            );
          }),
        ],
      ),
    );
  }
}
