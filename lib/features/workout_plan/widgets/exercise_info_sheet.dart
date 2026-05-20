import 'package:fit_forge/core/theme/app_colors.dart';
import 'package:fit_forge/core/utils/l10n_extension.dart';
import 'package:fit_forge/data/models/exercise_model.dart';
import 'package:fit_forge/data/repositories/exercise_repository.dart';
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

  @override
  void initState() {
    super.initState();
    _descCtrl = TextEditingController(text: widget.exercise.description ?? '');
    _urlCtrl = TextEditingController(text: widget.exercise.youTubeUrl ?? '');
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await ExerciseRepository().updateDescriptionAndUrl(
      widget.exercise.id,
      _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      _urlCtrl.text.trim().isEmpty ? null : _urlCtrl.text.trim(),
    );
    ref.invalidate(exercisesProvider(widget.exercise.planId));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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

          // Naziv
          Text(widget.exercise.name,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text1)),
          const SizedBox(height: 4),
          Text(widget.exercise.muscleGroup,
              style: const TextStyle(fontSize: 13, color: AppColors.text2)),
          const SizedBox(height: 20),

          ExerciseImageWidget(
            exercise: widget.exercise,
            height: 200,
            editable: true,
          ),
          const SizedBox(height: 20),

          // Opis
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

          // YouTube dugme ako postoji URL
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
        ],
      ),
    );
  }
}
