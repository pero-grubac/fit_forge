import 'package:fit_forge/core/theme/app_colors.dart';
import 'package:fit_forge/core/utils/l10n_extension.dart';
import 'package:fit_forge/data/models/default_set_model.dart';
import 'package:fit_forge/data/repositories/exercise_repository.dart';
import 'package:fit_forge/features/workout_plan/providers/workout_plan_provider.dart';
import 'package:fit_forge/shared/widgets/stepper_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class AddExerciseSheet extends StatefulWidget {
  const AddExerciseSheet({super.key, required this.planId, required this.ref});

  final String planId;
  final WidgetRef ref;

  @override
  State<AddExerciseSheet> createState() => AddExerciseSheetState();
}

class AddExerciseSheetState extends State<AddExerciseSheet> {
  final _nameCtrl = TextEditingController();
  String _muscleGroup = 'Chest';
  int _sets = 3;
  int _reps = 10;
  double _weight = 0;
  double _increment = 2.5;
  bool _loading = false;
  final _descCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
    _descCtrl.dispose();
    _urlCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final muscleGroups = [
      (key: 'Chest', label: context.l10n.muscle_chest),
      (key: 'Back', label: context.l10n.muscle_back),
      (key: 'Shoulders', label: context.l10n.muscle_shoulders),
      (key: 'Biceps', label: context.l10n.muscle_biceps),
      (key: 'Triceps', label: context.l10n.muscle_triceps),
      (key: 'Legs', label: context.l10n.muscle_legs),
      (key: 'Core', label: context.l10n.muscle_core),
    ];
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.bg4, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Text(context.l10n.exercise_new,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text1)),
          const SizedBox(height: 16),

          // Naziv
          Text(context.l10n.exercise_name_label,
              style: const TextStyle(fontSize: 12, color: AppColors.text2)),
          const SizedBox(height: 6),
          TextField(
            controller: _nameCtrl,
            style: const TextStyle(color: AppColors.text1),
            decoration: const InputDecoration(hintText: 'npr. Bench Press'),
          ),
          const SizedBox(height: 16),

          // Misicna grupa
          Text(context.l10n.exercise_muscle_label,
              style: const TextStyle(fontSize: 12, color: AppColors.text2)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: muscleGroups.map((g) {
              final selected = _muscleGroup == g.key;
              final color = AppColors.muscleGroupColor(g.key);
              return GestureDetector(
                onTap: () => setState(() => _muscleGroup = g.key),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected ? color.withOpacity(0.2) : AppColors.bg3,
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: selected ? color : AppColors.border2),
                  ),
                  child: Text(g.label,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: selected ? color : AppColors.text2)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Setovi, repovi, tezina, inkrement
          Row(
            children: [
              Expanded(
                  child: StepperField(
                      label: context.l10n.exercise_sets_label,
                      value: _sets,
                      onChanged: (v) => setState(() => _sets = v))),
              const SizedBox(width: 10),
              Expanded(
                  child: StepperField(
                      label: context.l10n.exercise_reps_label,
                      value: _reps,
                      onChanged: (v) => setState(() => _reps = v))),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: _DoubleField(
                      label: context.l10n.exercise_weight_label,
                      value: _weight,
                      onChanged: (v) => setState(() => _weight = v))),
              const SizedBox(width: 10),
              Expanded(
                  child: _DoubleField(
                      label: context.l10n.exercise_increment_label,
                      value: _increment,
                      onChanged: (v) => setState(() => _increment = v))),
            ],
          ),
          const SizedBox(height: 16),
          Text(context.l10n.exercise_description_label,
              style: const TextStyle(fontSize: 12, color: AppColors.text2)),
          const SizedBox(height: 6),
          TextField(
            controller: _descCtrl,
            maxLines: 3,
            style: const TextStyle(color: AppColors.text1),
            decoration: InputDecoration(
              hintText: context.l10n.exercise_description_hint,
            ),
          ),
          const SizedBox(height: 16),
          Text(context.l10n.exercise_youtube_label,
              style: const TextStyle(fontSize: 12, color: AppColors.text2)),
          const SizedBox(height: 6),
          TextField(
            controller: _urlCtrl,
            style: const TextStyle(color: AppColors.text1),
            decoration: const InputDecoration(
              hintText: 'https://youtube.com/watch?v=...',
              prefixIcon: Icon(Icons.play_circle_outline,
                  color: AppColors.red, size: 20),
            ),
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _save,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(context.l10n.exercise_save),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);

    final defaultSets = List.generate(
        _sets,
        (i) => DefaultSetModel(
              id: const Uuid().v4(),
              exerciseId: '',
              setNumber: i + 1,
              reps: _reps,
              weight: _weight,
              increment: _increment,
            ));

    await ExerciseRepository().create(
      planId: widget.planId,
      name: _nameCtrl.text.trim(),
      muscleGroup: _muscleGroup,
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      youTubeUrl: _urlCtrl.text.trim().isEmpty ? null : _urlCtrl.text.trim(),
      sortOrder: 0,
      sets: defaultSets
          .map((s) => (
                reps: s.reps,
                weight: s.weight,
                increment: s.increment,
              ))
          .toList(),
    );
    widget.ref.invalidate(exercisesProvider(widget.planId));
    if (mounted) Navigator.pop(context);
  }
}

class _DoubleField extends StatelessWidget {
  const _DoubleField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: AppColors.text2)),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: value.toString(),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: AppColors.text1),
          decoration: const InputDecoration(),
          onChanged: (v) => onChanged(double.tryParse(v) ?? 0),
        ),
      ],
    );
  }
}
