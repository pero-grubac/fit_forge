import 'package:fit_forge/core/constants/exercise_library.dart';
import 'package:fit_forge/core/theme/app_colors.dart';
import 'package:fit_forge/core/utils/l10n_extension.dart';
import 'package:fit_forge/data/models/exercise_model.dart';
import 'package:fit_forge/data/models/plan_exercise_model.dart';
import 'package:fit_forge/data/providers.dart';
import 'package:fit_forge/features/workout_plan/providers/workout_plan_provider.dart';
import 'package:fit_forge/shared/widgets/stepper_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddExerciseSheet extends StatefulWidget {
  const AddExerciseSheet({super.key, required this.planId, required this.ref});

  final String planId;
  final WidgetRef ref;

  @override
  State<AddExerciseSheet> createState() => AddExerciseSheetState();
}

class AddExerciseSheetState extends State<AddExerciseSheet> {
  String _muscleGroup = 'Chest';
  ExerciseDefinition? _selectedExercise;
  String _searchQuery = '';
  int _sets = 3;
  int _reps = 10;
  int _seconds = 30;
  double _weight = 0;
  double _increment = 2.5;
  bool _loading = false;

  /// Exercises already in the catalogue (from any plan).
  List<ExerciseModel> _catalogue = [];

  @override
  void initState() {
    super.initState();
    widget.ref.read(exerciseRepositoryProvider).getAll().then((list) {
      if (mounted) setState(() => _catalogue = list);
    });
  }

  /// Library exercises of the selected group plus catalogue exercises of
  /// that group that aren't in the library (custom ones).
  List<ExerciseDefinition> get _filtered {
    final library = ExerciseLibrary.getExercises(_muscleGroup);
    final libraryNames = library.map((e) => e.name.toLowerCase()).toSet();
    final custom = _catalogue
        .where((e) =>
            e.muscleGroup == _muscleGroup &&
            !libraryNames.contains(e.name.toLowerCase()))
        .map((e) => ExerciseDefinition(e.name, _typeOf(e.exerciseType)));
    final all = [...library, ...custom];
    if (_searchQuery.isEmpty) return all;
    return all
        .where((e) => e.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  /// Names (lowercase) of exercises already in this plan.
  Set<String> get _inPlan => {
        for (final pe in widget.ref
                .read(planExercisesProvider(widget.planId))
                .valueOrNull ??
            const <PlanExerciseModel>[])
          pe.exercise.name.toLowerCase(),
      };

  /// Search text that can be added as a new custom exercise, or null if an
  /// exercise with that name already exists anywhere.
  String? get _newExerciseName {
    final query = _searchQuery.trim();
    if (query.isEmpty) return null;
    final lower = query.toLowerCase();
    final exists = ExerciseLibrary.exercises.values
            .expand((l) => l)
            .any((e) => e.name.toLowerCase() == lower) ||
        _catalogue.any((e) => e.name.toLowerCase() == lower);
    return exists ? null : query;
  }

  static ExerciseType _typeOf(String type) => ExerciseType.values
      .firstWhere((t) => t.name == type, orElse: () => ExerciseType.weighted);

  @override
  Widget build(BuildContext context) {
    final muscleGroups = [
      (
        key: 'Chest',
        label: context.l10n.muscle_chest,
        icon: Icons.fitness_center
      ),
      (
        key: 'Back',
        label: context.l10n.muscle_back,
        icon: Icons.accessibility_new
      ),
      (
        key: 'Shoulders',
        label: context.l10n.muscle_shoulders,
        icon: Icons.sports_handball
      ),
      (
        key: 'Biceps',
        label: context.l10n.muscle_biceps,
        icon: Icons.sports_gymnastics
      ),
      (
        key: 'Triceps',
        label: context.l10n.muscle_triceps,
        icon: Icons.sports_martial_arts
      ),
      (
        key: 'Legs',
        label: context.l10n.muscle_legs,
        icon: Icons.directions_run
      ),
      (
        key: 'Core',
        label: context.l10n.muscle_core,
        icon: Icons.circle_outlined
      ),
      (
        key: 'Forearms',
        label: context.l10n.muscle_forearms,
        icon: Icons.back_hand_outlined
      ),
      (
        key: 'Bodyweight',
        label: context.l10n.muscle_bodyweight,
        icon: Icons.self_improvement
      ),
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) => Column(
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.bg4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Text(context.l10n.exercise_new,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text1)),
                const Spacer(),
                if (_selectedExercise != null)
                  TextButton(
                    onPressed: () => setState(() => _selectedExercise = null),
                    child: Text(context.l10n.btn_cancel,
                        style: const TextStyle(color: AppColors.text2)),
                  ),
              ],
            ),
          ),

          Expanded(
            child: _selectedExercise == null
                ? _ExercisePicker(
                    muscleGroups: muscleGroups,
                    selectedGroup: _muscleGroup,
                    searchQuery: _searchQuery,
                    filtered: _filtered,
                    inPlan: _inPlan,
                    newExerciseName: _newExerciseName,
                    onGroupChanged: (g) => setState(() {
                      _muscleGroup = g;
                      _searchQuery = '';
                      _selectedExercise = null;
                    }),
                    onSearchChanged: (q) => setState(() => _searchQuery = q),
                    onExerciseSelected: (ex) =>
                        setState(() => _selectedExercise = ex),
                    scrollController: controller,
                  )
                : _ExerciseForm(
                    exercise: _selectedExercise!,
                    sets: _sets,
                    reps: _reps,
                    seconds: _seconds,
                    weight: _weight,
                    increment: _increment,
                    loading: _loading,
                    onSetsChanged: (v) => setState(() => _sets = v),
                    onRepsChanged: (v) => setState(() => _reps = v),
                    onSecondsChanged: (v) => setState(() => _seconds = v),
                    onWeightChanged: (v) => setState(() => _weight = v),
                    onIncrementChanged: (v) => setState(() => _increment = v),
                    onSave: _save,
                    scrollController: controller,
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_selectedExercise == null) return;
    setState(() => _loading = true);

    final ex = _selectedExercise!;
    final isWeighted = ex.type == ExerciseType.weighted;
    final isBodyweight = ex.type == ExerciseType.bodyweight;

    final exercise =
        await widget.ref.read(exerciseRepositoryProvider).findOrCreate(
              name: ex.name,
              muscleGroup: _muscleGroup,
              exerciseType: ex.type.name,
            );
    final added = await widget.ref.read(planExerciseRepositoryProvider).add(
          planId: widget.planId,
          exercise: exercise,
          sets: List.generate(
            _sets,
            (_) => (
              reps: isWeighted || isBodyweight ? _reps : _seconds,
              weight: isWeighted ? _weight : 0.0,
              increment: isWeighted ? _increment : 0.0,
            ),
          ),
        );

    if (!mounted) return;
    if (added == null) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.exercise_already_in_plan)),
      );
      return;
    }
    widget.ref.invalidate(planExercisesProvider(widget.planId));
    Navigator.pop(context);
  }
}

class _ExercisePicker extends StatelessWidget {
  const _ExercisePicker({
    required this.muscleGroups,
    required this.selectedGroup,
    required this.searchQuery,
    required this.filtered,
    required this.inPlan,
    required this.newExerciseName,
    required this.onGroupChanged,
    required this.onSearchChanged,
    required this.onExerciseSelected,
    required this.scrollController,
  });

  final List<({String key, String label, IconData icon})> muscleGroups;
  final String selectedGroup;
  final String searchQuery;
  final List<ExerciseDefinition> filtered;
  final Set<String> inPlan;
  final String? newExerciseName;
  final ValueChanged<String> onGroupChanged;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<ExerciseDefinition> onExerciseSelected;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        // Muscle group pills
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: muscleGroups.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final g = muscleGroups[i];
              final selected = selectedGroup == g.key;
              final color = AppColors.muscleGroupColor(g.key);
              return GestureDetector(
                onTap: () => onGroupChanged(g.key),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color:
                        selected ? color.withValues(alpha: 0.2) : AppColors.bg3,
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: selected ? color : AppColors.border2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(g.icon,
                          size: 14, color: selected ? color : AppColors.text3),
                      const SizedBox(width: 6),
                      Text(g.label,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: selected ? color : AppColors.text2)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),

        // Search
        TextField(
          onChanged: onSearchChanged,
          style: const TextStyle(color: AppColors.text1),
          decoration: InputDecoration(
            hintText: context.l10n.exercise_search_hint,
            prefixIcon: const Icon(Icons.search, color: AppColors.text3),
            filled: true,
            fillColor: AppColors.bg3,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
        const SizedBox(height: 8),

        // Create a custom exercise from the search text
        if (newExerciseName != null)
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add, size: 18, color: AppColors.accent),
            ),
            title: Text(context.l10n.exercise_create_custom(newExerciseName!),
                style: const TextStyle(fontSize: 14, color: AppColors.accent)),
            onTap: () => onExerciseSelected(
                ExerciseDefinition(newExerciseName!, ExerciseType.weighted)),
          ),

        // Exercise list
        ...filtered.map((ex) {
          final alreadyInPlan = inPlan.contains(ex.name.toLowerCase());
          final typeIcon = switch (ex.type) {
            ExerciseType.weighted => Icons.fitness_center,
            ExerciseType.bodyweight => Icons.accessibility_new,
            ExerciseType.timed => Icons.timer_outlined,
          };
          final typeColor = switch (ex.type) {
            ExerciseType.weighted => AppColors.accent,
            ExerciseType.bodyweight => AppColors.green,
            ExerciseType.timed => AppColors.amber,
          };
          return ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(typeIcon, size: 18, color: typeColor),
            ),
            title: Text(ex.name,
                style: TextStyle(
                    fontSize: 14,
                    color: alreadyInPlan ? AppColors.text3 : AppColors.text1)),
            subtitle: alreadyInPlan
                ? Text(context.l10n.exercise_in_plan,
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.text3))
                : null,
            trailing: Icon(alreadyInPlan ? Icons.check : Icons.chevron_right,
                color: AppColors.text3, size: 18),
            onTap: alreadyInPlan ? null : () => onExerciseSelected(ex),
          );
        }),
      ],
    );
  }
}

class _ExerciseForm extends StatelessWidget {
  const _ExerciseForm({
    required this.exercise,
    required this.sets,
    required this.reps,
    required this.seconds,
    required this.weight,
    required this.increment,
    required this.loading,
    required this.onSetsChanged,
    required this.onRepsChanged,
    required this.onSecondsChanged,
    required this.onWeightChanged,
    required this.onIncrementChanged,
    required this.onSave,
    required this.scrollController,
  });

  final ExerciseDefinition exercise;
  final int sets;
  final int reps;
  final int seconds;
  final double weight;
  final double increment;
  final bool loading;
  final ValueChanged<int> onSetsChanged;
  final ValueChanged<int> onRepsChanged;
  final ValueChanged<int> onSecondsChanged;
  final ValueChanged<double> onWeightChanged;
  final ValueChanged<double> onIncrementChanged;
  final VoidCallback onSave;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final isWeighted = exercise.type == ExerciseType.weighted;
    final isBodyweight = exercise.type == ExerciseType.bodyweight;
    final isTimed = exercise.type == ExerciseType.timed;

    final typeColor = switch (exercise.type) {
      ExerciseType.weighted => AppColors.accent,
      ExerciseType.bodyweight => AppColors.green,
      ExerciseType.timed => AppColors.amber,
    };
    final typeLabel = switch (exercise.type) {
      ExerciseType.weighted => context.l10n.exercise_type_weighted,
      ExerciseType.bodyweight => context.l10n.exercise_type_bodyweight,
      ExerciseType.timed => context.l10n.exercise_type_timed,
    };

    return ListView(
      controller: scrollController,
      padding: EdgeInsets.fromLTRB(
          16, 0, 16, MediaQuery.of(context).viewInsets.bottom + 24),
      children: [
        // Exercise name
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: typeColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: typeColor.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Icon(
                switch (exercise.type) {
                  ExerciseType.weighted => Icons.fitness_center,
                  ExerciseType.bodyweight => Icons.accessibility_new,
                  ExerciseType.timed => Icons.timer_outlined,
                },
                color: typeColor,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(exercise.name,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text1)),
                    Text(typeLabel,
                        style: TextStyle(fontSize: 12, color: typeColor)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Sets — always
        StepperField(
          label: context.l10n.exercise_sets_label,
          value: sets,
          onChanged: onSetsChanged,
        ),
        const SizedBox(height: 12),

        // Reps — weighted and bodyweight
        if (isWeighted || isBodyweight) ...[
          StepperField(
            label: context.l10n.exercise_reps_label,
            value: reps,
            onChanged: onRepsChanged,
          ),
          const SizedBox(height: 12),
        ],

        // Seconds — timed
        if (isTimed) ...[
          StepperField(
            label: context.l10n.exercise_seconds_label,
            value: seconds,
            onChanged: onSecondsChanged,
          ),
          const SizedBox(height: 12),
        ],

        // Weight and increment — weighted only
        if (isWeighted) ...[
          Row(
            children: [
              Expanded(
                child: _DoubleField(
                  label: context.l10n.exercise_weight_label,
                  value: weight,
                  onChanged: onWeightChanged,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DoubleField(
                  label: context.l10n.exercise_increment_label,
                  value: increment,
                  onChanged: onIncrementChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],

        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: loading ? null : onSave,
            child: loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Text(context.l10n.exercise_save),
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
