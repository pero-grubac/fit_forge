import 'package:fit_forge/core/theme/app_colors.dart';
import 'package:fit_forge/data/models/default_set_model.dart';
import 'package:fit_forge/data/models/exercise_model.dart';
import 'package:fit_forge/data/repositories/exercise_repository.dart';
import 'package:fit_forge/features/workout_plan/providers/workout_plan_provider.dart';
import 'package:fit_forge/features/workout_plan/widgets/exercise_image_widget.dart';
import 'package:fit_forge/shared/widgets/muscle_group_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

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
        error: (e, _) => Center(child: Text('Greska: $e')),
        data: (list) => list.isEmpty
            ? _EmptyState()
            : _ExerciseList(exercises: list, planId: planId, ref: ref),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddExercise(context, ref),
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Dodaj vjezbu',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
      builder: (_) => _AddExerciseSheet(planId: planId, ref: ref),
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
                            '${ex.muscleGroup}  ·  ${ex.defaultSets.length} seta',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.text2),
                          ),
                        ],
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
                height: 90,
                editable: true,
              ),
              // Default setovi info
              if (ex.defaultSets.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                  child: Row(
                    children: [
                      _InfoChip(
                          label: '${ex.defaultSets.length} seta',
                          icon: Icons.repeat),
                      const SizedBox(width: 8),
                      _InfoChip(
                          label: '${ex.defaultSets.first.reps} reps',
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
        title: const Text('Obriši vježbu',
            style: TextStyle(color: AppColors.text1)),
        content: Text('Jesi siguran da želiš obrisati "${ex.name}"?',
            style: const TextStyle(color: AppColors.text2)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Odustani',
                style: TextStyle(color: AppColors.text2)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await ExerciseRepository().delete(ex.id);
              ref.invalidate(exercisesProvider(planId));
            },
            child: const Text('Obriši', style: TextStyle(color: AppColors.red)),
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

class _AddExerciseSheet extends StatefulWidget {
  const _AddExerciseSheet({required this.planId, required this.ref});

  final String planId;
  final WidgetRef ref;

  @override
  State<_AddExerciseSheet> createState() => _AddExerciseSheetState();
}

class _AddExerciseSheetState extends State<_AddExerciseSheet> {
  final _nameCtrl = TextEditingController();
  String _muscleGroup = 'Chest';
  int _sets = 3;
  int _reps = 10;
  double _weight = 0;
  double _increment = 2.5;
  bool _loading = false;

  static const _muscleGroups = [
    'Chest',
    'Back',
    'Shoulders',
    'Biceps',
    'Triceps',
    'Legs',
    'Core'
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          const Text('Nova vježba',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text1)),
          const SizedBox(height: 16),

          // Naziv
          const Text('Naziv vježbe',
              style: TextStyle(fontSize: 12, color: AppColors.text2)),
          const SizedBox(height: 6),
          TextField(
            controller: _nameCtrl,
            style: const TextStyle(color: AppColors.text1),
            decoration: const InputDecoration(hintText: 'npr. Bench Press'),
          ),
          const SizedBox(height: 16),

          // Misicna grupa
          const Text('Mišićna grupa',
              style: TextStyle(fontSize: 12, color: AppColors.text2)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _muscleGroups.map((g) {
              final selected = _muscleGroup == g;
              final color = AppColors.muscleGroupColor(g);
              return GestureDetector(
                onTap: () => setState(() => _muscleGroup = g),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected ? color.withOpacity(0.2) : AppColors.bg3,
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: selected ? color : AppColors.border2),
                  ),
                  child: Text(g,
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
                  child: _StepperField(
                      label: 'Setovi',
                      value: _sets,
                      onChanged: (v) => setState(() => _sets = v))),
              const SizedBox(width: 10),
              Expanded(
                  child: _StepperField(
                      label: 'Repovi',
                      value: _reps,
                      onChanged: (v) => setState(() => _reps = v))),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                  child: _DoubleField(
                      label: 'Pocetna tezina (kg)',
                      value: _weight,
                      onChanged: (v) => setState(() => _weight = v))),
              const SizedBox(width: 10),
              Expanded(
                  child: _DoubleField(
                      label: 'Inkrement (kg)',
                      value: _increment,
                      onChanged: (v) => setState(() => _increment = v))),
            ],
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
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Spremi vježbu'),
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

class _StepperField extends StatelessWidget {
  const _StepperField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: AppColors.text2)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bg3,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: AppColors.border2),
          ),
          child: Row(
            children: [
              IconButton(
                icon:
                    const Icon(Icons.remove, size: 18, color: AppColors.text2),
                onPressed: value > 1 ? () => onChanged(value - 1) : null,
              ),
              Expanded(
                child: Text('$value',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text1)),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 18, color: AppColors.text2),
                onPressed: () => onChanged(value + 1),
              ),
            ],
          ),
        ),
      ],
    );
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

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fitness_center, size: 64, color: AppColors.text3),
          SizedBox(height: 16),
          Text('Nema vježbi u planu',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text2)),
          SizedBox(height: 8),
          Text('Dodaj prvu vježbu',
              style: TextStyle(fontSize: 14, color: AppColors.text3)),
        ],
      ),
    );
  }
}
