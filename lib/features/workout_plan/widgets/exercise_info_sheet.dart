import 'package:fit_forge/core/theme/app_colors.dart';
import 'package:fit_forge/core/utils/l10n_extension.dart';
import 'package:fit_forge/data/models/exercise_model.dart';
import 'package:fit_forge/data/providers.dart';
import 'package:fit_forge/features/progress/providers/progress_provider.dart';
import 'package:fit_forge/features/workout_plan/providers/workout_plan_provider.dart';
import 'package:fit_forge/features/workout_plan/widgets/exercise_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class ExerciseInfoSheet extends ConsumerStatefulWidget {
  const ExerciseInfoSheet({super.key, required this.exercise});

  final ExerciseModel exercise;

  @override
  ConsumerState<ExerciseInfoSheet> createState() => _ExerciseInfoSheetState();
}

class _ExerciseInfoSheetState extends ConsumerState<ExerciseInfoSheet> {
  late final TextEditingController _descCtrl;
  late final TextEditingController _urlCtrl;
  bool _saving = false;
  late String _muscleGroup;
  int _planCount = 1;

  @override
  void initState() {
    super.initState();
    _descCtrl = TextEditingController(text: widget.exercise.description ?? '');
    _urlCtrl = TextEditingController(text: widget.exercise.youTubeUrl ?? '');
    _muscleGroup = widget.exercise.muscleGroup;
    ref
        .read(exerciseRepositoryProvider)
        .countPlans(widget.exercise.id)
        .then((n) {
      if (mounted) setState(() => _planCount = n);
    });
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final repo = ref.read(exerciseRepositoryProvider);
    await repo.updateDescriptionAndUrl(
      widget.exercise.id,
      _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      _urlCtrl.text.trim().isEmpty ? null : _urlCtrl.text.trim(),
    );

    await repo.updateMuscleGroup(
      widget.exercise.id,
      _muscleGroup,
    );
    ref.invalidate(planExercisesProvider);
    ref.invalidate(exercisesWithLogsProvider);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _confirmDeleteEverywhere() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.bg2,
        title: Text(context.l10n.exercise_delete_title,
            style: const TextStyle(color: AppColors.text1)),
        content: Text(
            context.l10n
                .exercise_delete_everywhere_confirm(widget.exercise.name),
            style: const TextStyle(color: AppColors.text2)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.btn_cancel,
                style: const TextStyle(color: AppColors.text2)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.l10n.btn_delete,
                style: const TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(exerciseRepositoryProvider).delete(widget.exercise);
    ref.invalidate(planExercisesProvider);
    ref.invalidate(exercisesWithLogsProvider);
    ref.invalidate(exerciseHistoryProvider(widget.exercise.id));
    if (mounted) Navigator.pop(context);
  }

  String _labelToKey(String label, BuildContext context) {
    final l = context.l10n;
    if (label == l.muscle_chest) return 'Chest';
    if (label == l.muscle_back) return 'Back';
    if (label == l.muscle_shoulders) return 'Shoulders';
    if (label == l.muscle_biceps) return 'Biceps';
    if (label == l.muscle_triceps) return 'Triceps';
    if (label == l.muscle_legs) return 'Legs';
    if (label == l.muscle_forearms) return 'Forearms';
    if (label == l.muscle_bodyweight) return 'Bodyweight';
    return 'Core';
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
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.bg4, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),

          // Name
          Text(widget.exercise.name,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text1)),
          const SizedBox(height: 4),
          Text(widget.exercise.muscleGroup,
              style: const TextStyle(fontSize: 13, color: AppColors.text2)),
          if (_planCount > 1) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.info_outline,
                    size: 14, color: AppColors.amber),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(context.l10n.exercise_shared_hint(_planCount),
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.amber)),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),

          ExerciseImageWidget(
            exercise: widget.exercise,
            height: 200,
            editable: true,
          ),
          const SizedBox(height: 20),

          const SizedBox(height: 16),
          Text(context.l10n.exercise_muscle_label,
              style: const TextStyle(fontSize: 12, color: AppColors.text2)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.bg3,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border2),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _muscleGroup,
                isExpanded: true,
                dropdownColor: AppColors.bg2,
                style: const TextStyle(color: AppColors.text1, fontSize: 14),
                icon: const Icon(Icons.expand_more, color: AppColors.text2),
                items: [
                  context.l10n.muscle_chest,
                  context.l10n.muscle_back,
                  context.l10n.muscle_shoulders,
                  context.l10n.muscle_biceps,
                  context.l10n.muscle_triceps,
                  context.l10n.muscle_legs,
                  context.l10n.muscle_core,
                  context.l10n.muscle_forearms,
                  context.l10n.muscle_bodyweight,
                ].map((label) {
                  final key = _labelToKey(label, context);
                  return DropdownMenuItem(
                    value: key,
                    child: Text(label),
                  );
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _muscleGroup = v);
                },
              ),
            ),
          ),

          // Description
          Text(context.l10n.exercise_description_label,
              style: const TextStyle(fontSize: 12, color: AppColors.text2)),
          const SizedBox(height: 6),
          TextField(
            controller: _descCtrl,
            maxLines: 4,
            style: const TextStyle(color: AppColors.text1),
            decoration: InputDecoration(
              hintText: context.l10n.exercise_description_hint,
            ),
          ),
          const SizedBox(height: 16),

          // YouTube URL
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

          // YouTube button when a link is set
          if (widget.exercise.youTubeUrl != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => launchUrl(
                    Uri.parse(widget.exercise.youTubeUrl!),
                    mode: LaunchMode.externalApplication),
                icon:
                    const Icon(Icons.play_circle_outline, color: AppColors.red),
                label: Text(context.l10n.exercise_watch_youtube,
                    style: const TextStyle(color: AppColors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.red),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(context.l10n.btn_save),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: _saving ? null : _confirmDeleteEverywhere,
              icon: const Icon(Icons.delete_forever_outlined,
                  color: AppColors.red, size: 20),
              label: Text(context.l10n.exercise_delete_everywhere,
                  style: const TextStyle(color: AppColors.red)),
            ),
          ),
        ],
      ),
    );
  }
}
