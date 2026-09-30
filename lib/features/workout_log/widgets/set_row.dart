import 'package:fit_forge/core/theme/app_colors.dart';
import 'package:fit_forge/core/utils/l10n_extension.dart';
import 'package:flutter/material.dart';

class SetRow {
  final int setNumber;
  double plannedWeight;
  int plannedReps;
  bool isDone;

  /// Set once the user types a value; automatic progression then leaves that
  /// field alone.
  bool weightEdited = false;
  bool repsEdited = false;
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

  /// The same set under a new number, keeping what was typed. The caller
  /// disposes this row once it is off screen.
  SetRow renumbered(int number) {
    final copy = SetRow(
      setNumber: number,
      plannedWeight: plannedWeight,
      plannedReps: plannedReps,
      isDone: isDone,
    )
      ..weightEdited = weightEdited
      ..repsEdited = repsEdited;
    copy.weightCtrl.text = weightCtrl.text;
    copy.repsCtrl.text = repsCtrl.text;
    return copy;
  }

  void dispose() {
    weightCtrl.dispose();
    repsCtrl.dispose();
  }

  /// Updates the target (and the fields) unless the user typed their own.
  void setTarget({double? weight, int? reps}) {
    if (weight != null && !weightEdited) {
      plannedWeight = weight;
      weightCtrl.text = weight.toString();
    }
    if (reps != null && !repsEdited) {
      plannedReps = reps;
      repsCtrl.text = reps.toString();
    }
  }
}

class SetRowWidget extends StatelessWidget {
  const SetRowWidget({
    super.key,
    required this.set,
    required this.onToggle,
    required this.isLast,
    this.onDelete,
    this.exerciseType = 'weighted',
  });

  final SetRow set;
  final VoidCallback onToggle;
  final bool isLast;
  final VoidCallback? onDelete;
  final String exerciseType;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Dismissible(
          key: Key('set_${set.setNumber}_${set.hashCode}'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            color: AppColors.red.withValues(alpha: 0.2),
            child: const Icon(Icons.delete_outline, color: AppColors.red),
          ),
          onDismissed: (_) => onDelete?.call(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              children: [
                // Set number
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.bg4,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text('${set.setNumber}',
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text2)),
                  ),
                ),
                const SizedBox(width: 8),

                // Weight — weighted exercises only
                if (exerciseType == 'weighted') ...[
                  Expanded(
                    child: TextField(
                      key: Key('set_weight_${set.setNumber}'),
                      controller: set.weightCtrl,
                      onChanged: (_) => set.weightEdited = true,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      style:
                          const TextStyle(fontSize: 14, color: AppColors.text1),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.bg3,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AppColors.border2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: AppColors.border2),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],

                // Reps or seconds
                Expanded(
                  child: TextField(
                    key: Key('set_reps_${set.setNumber}'),
                    controller: set.repsCtrl,
                    onChanged: (_) => set.repsEdited = true,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style:
                        const TextStyle(fontSize: 14, color: AppColors.text1),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.bg3,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.border2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.border2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Checkmark
                GestureDetector(
                  key: Key('set_toggle_${set.setNumber}'),
                  onTap: onToggle,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: set.isDone
                          ? AppColors.green.withValues(alpha: 0.15)
                          : AppColors.bg3,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: set.isDone ? AppColors.green : AppColors.border2,
                      ),
                    ),
                    child: set.isDone
                        ? const Icon(Icons.check,
                            size: 16, color: AppColors.green)
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!isLast) const Divider(height: 1, color: AppColors.border),
      ],
    );
  }
}

class SetsTable extends StatelessWidget {
  const SetsTable({
    super.key,
    required this.sets,
    required this.onToggle,
    required this.onDelete,
    this.exerciseType = 'weighted',
  });

  final List<SetRow> sets;
  final ValueChanged<int> onToggle;
  final ValueChanged<int> onDelete;
  final String exerciseType;

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
                if (exerciseType == 'weighted')
                  Expanded(
                    child: Text(
                      context.l10n.exercise_weight_label,
                      textAlign: TextAlign.center,
                      style:
                          const TextStyle(fontSize: 11, color: AppColors.text3),
                    ),
                  ),
                Expanded(
                  child: Text(
                    exerciseType == 'timed'
                        ? context.l10n.exercise_seconds_label
                        : context.l10n.exercise_reps_label,
                    textAlign: TextAlign.center,
                    style:
                        const TextStyle(fontSize: 11, color: AppColors.text3),
                  ),
                ),
                const SizedBox(width: 36),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Sets
          ...sets.asMap().entries.map((e) {
            final i = e.key;
            final set = e.value;
            return SetRowWidget(
              set: set,
              onToggle: () => onToggle(i),
              onDelete: () => onDelete(i),
              isLast: i == sets.length - 1,
              exerciseType: exerciseType,
            );
          }),
        ],
      ),
    );
  }
}
