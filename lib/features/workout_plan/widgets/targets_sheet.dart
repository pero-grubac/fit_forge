import 'package:fit_forge/core/theme/app_colors.dart';
import 'package:fit_forge/core/utils/l10n_extension.dart';
import 'package:fit_forge/core/utils/set_progression.dart';
import 'package:fit_forge/data/models/exercise_model.dart';
import 'package:fit_forge/data/models/plan_exercise_model.dart';
import 'package:fit_forge/data/providers.dart';
import 'package:fit_forge/features/settings/providers/settings_provider.dart';
import 'package:fit_forge/features/workout_log/providers/progression_provider.dart';
import 'package:fit_forge/features/workout_log/widgets/progression_banner.dart';
import 'package:fit_forge/features/workout_plan/providers/workout_plan_provider.dart';
import 'package:fit_forge/shared/widgets/stepper_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Edits an exercise's targets in one plan (sets, reps, starting weight) and
/// its progression settings, which apply in every plan.
class TargetsSheet extends ConsumerStatefulWidget {
  const TargetsSheet({super.key, required this.planExercise});

  final PlanExerciseModel planExercise;

  @override
  ConsumerState<TargetsSheet> createState() => _TargetsSheetState();
}

class _TargetsSheetState extends ConsumerState<TargetsSheet> {
  late int _sets;
  late int _reps;
  late double _weight;
  late bool _auto;

  /// Null means "use the default".
  double? _increment;
  int? _setsToProgress;
  bool _saving = false;

  ExerciseModel get _exercise => widget.planExercise.exercise;

  ProgressionUnit get _unit => switch (_exercise.exerciseType) {
        'bodyweight' => ProgressionUnit.reps,
        'timed' => ProgressionUnit.seconds,
        _ => ProgressionUnit.kg,
      };

  @override
  void initState() {
    super.initState();
    final sets = widget.planExercise.defaultSets;
    _sets = sets.isEmpty ? 3 : sets.length;
    _reps = sets.firstOrNull?.reps ?? (_exercise.isTimed ? 30 : 10);
    _weight = sets.firstOrNull?.weight ?? 0;
    _auto = _exercise.autoProgress;
    _increment = _exercise.increment;
    _setsToProgress = _exercise.setsToProgress;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await ref.read(planExerciseRepositoryProvider).updateTargets(
      widget.planExercise.id,
      [for (var i = 0; i < _sets; i++) (reps: _reps, weight: _weight)],
    );
    await ref.read(exerciseRepositoryProvider).updateProgression(
          _exercise.id,
          autoProgress: _auto,
          increment: _increment,
          setsToProgress: _setsToProgress,
        );
    ref.invalidate(planExercisesProvider);
    ref.invalidate(progressionProvider);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings =
        ref.watch(settingsProvider).valueOrNull ?? const AppSettings();
    final defaultIncrement = _unit == ProgressionUnit.kg
        ? settings.defaultIncrement
        : ExerciseModel.defaultIncrementFor(_exercise.exerciseType);
    final incrementStep = _unit == ProgressionUnit.kg ? 0.5 : 1.0;
    String level(double v) => formatLevel(context, v, _unit);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
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
          Text(l10n.targets_title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text1)),
          Text(_exercise.name,
              style: const TextStyle(fontSize: 13, color: AppColors.text2)),
          const SizedBox(height: 20),

          // Targets in this plan
          _Label(l10n.targets_plan_section),
          StepperField(
            label: l10n.targets_sets,
            value: _sets,
            onChanged: (v) => setState(() => _sets = v.clamp(1, 20)),
          ),
          const SizedBox(height: 12),
          StepperField(
            label: _exercise.isTimed ? l10n.targets_seconds : l10n.targets_reps,
            value: _reps,
            onChanged: (v) => setState(() => _reps = v.clamp(1, 999)),
          ),
          if (_exercise.isWeighted) ...[
            const SizedBox(height: 12),
            _Row(
              label: l10n.targets_weight,
              child: AppStepper(
                value: _weight,
                min: 0,
                max: 500,
                step: _increment ?? defaultIncrement,
                onChanged: (v) => setState(() => _weight = v),
              ),
            ),
          ],
          const SizedBox(height: 24),

          // Progression, shared by every plan with this exercise
          _Label(l10n.targets_progression_section),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.targets_auto,
                style: const TextStyle(fontSize: 14, color: AppColors.text1)),
            value: _auto,
            activeThumbColor: AppColors.accent,
            onChanged: (v) => setState(() => _auto = v),
          ),
          if (_auto) ...[
            _Row(
              label: l10n.targets_increment,
              child: AppStepper(
                value: _increment ?? defaultIncrement,
                min: incrementStep,
                max: _unit == ProgressionUnit.kg ? 50 : 60,
                step: incrementStep,
                format: (v) => '+${level(v)}',
                onChanged: (v) => setState(() => _increment = v),
              ),
            ),
            _DefaultButton(
              visible: _increment != null,
              label: l10n.targets_default('+${level(defaultIncrement)}'),
              onPressed: () => setState(() => _increment = null),
            ),
            _Row(
              label: l10n.targets_sets_to_progress,
              child: AppStepper(
                value: (_setsToProgress ?? settings.setsToProgress).toDouble(),
                min: 1,
                max: 30,
                step: 1,
                format: (v) => '${v.toInt()}',
                onChanged: (v) => setState(() => _setsToProgress = v.toInt()),
              ),
            ),
            _DefaultButton(
              visible: _setsToProgress != null,
              label: l10n.targets_default('${settings.setsToProgress}'),
              onPressed: () => setState(() => _setsToProgress = null),
            ),
            Text(l10n.targets_rule_hint,
                style: const TextStyle(fontSize: 12, color: AppColors.text3)),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              key: const Key('targets_save'),
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(l10n.btn_save),
            ),
          ),
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                color: AppColors.text3)),
      );
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 14, color: AppColors.text1)),
          ),
          child,
        ],
      );
}

/// "Default (…)" link under a value that overrides the default.
class _DefaultButton extends StatelessWidget {
  const _DefaultButton({
    required this.visible,
    required this.label,
    required this.onPressed,
  });

  final bool visible;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerRight,
        child: visible
            ? TextButton(
                onPressed: onPressed,
                style: TextButton.styleFrom(foregroundColor: AppColors.text2),
                child: Text(label, style: const TextStyle(fontSize: 12)),
              )
            : const SizedBox(height: 12),
      );
}
