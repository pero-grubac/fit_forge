import 'package:fit_forge/core/utils/l10n_extension.dart';
import 'package:fit_forge/data/repositories/workout_log_repository.dart';
import 'package:fit_forge/features/workout_log/widgets/progression_banner.dart';
import 'package:fit_forge/features/workout_log/widgets/set_row.dart';
import 'package:fit_forge/features/workout_log/widgets/volume_info.dart';
import 'package:fit_forge/features/workout_plan/widgets/exercise_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../../../core/models/progression_suggestion.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/exercise_model.dart';
import '../../../data/repositories/exercise_repository.dart';
import '../providers/progression_provider.dart';
import '../providers/workout_log_provider.dart';

class LogSessionPage extends ConsumerStatefulWidget {
  const LogSessionPage({required this.exerciseId, super.key});

  final String exerciseId;

  @override
  ConsumerState<LogSessionPage> createState() => _LogSessionPageState();
}

class _LogSessionPageState extends ConsumerState<LogSessionPage> {
  ExerciseModel? _exercise;
  bool _loadingExercise = true;
  final _notesCtrl = TextEditingController();
  final _sets = <SetRow>[];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadExercise();
  }

  Future<void> _loadExercise() async {
    final ex = await ExerciseRepository().getById(widget.exerciseId);
    if (!mounted) return;
    setState(() {
      _exercise = ex;
      _loadingExercise = false;
    });
    if (_sets.isEmpty) {
      await _loadLastLog();
    }
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    for (final s in _sets) {
      s.weightCtrl.dispose();
      s.repsCtrl.dispose();
    }
    super.dispose();
  }

  void _initSetsFromSuggestion(ProgressionSuggestion suggestion) {
    if (_sets.isNotEmpty) return;
    if (!suggestion.hasData) return; // _loadExercise vec ucitao setove

    // Ima progression data — override sa prijedlogom
    setState(() {
      _sets.clear();
      for (int i = 0; i < suggestion.suggestedWeights.length; i++) {
        _sets.add(SetRow(
          setNumber: i + 1,
          plannedWeight: suggestion.suggestedWeights[i],
          plannedReps: suggestion.suggestedReps[i],
        ));
      }
    });
  }

  Future<void> _loadLastLog() async {
    final logs =
        await WorkoutLogRepository().getByExercise(widget.exerciseId, limit: 1);

    if (!mounted) return;

    if (logs.isNotEmpty && logs.first.sets.isNotEmpty) {
      final lastSets = logs.first.sets;
      setState(() {
        _sets.clear();
        for (final s in lastSets) {
          _sets.add(SetRow(
            setNumber: s.setNumber,
            plannedWeight: s.actualWeight,
            plannedReps: s.actualReps,
            isDone: false,
          ));
        }
      });
    } else if (_exercise != null && _exercise!.defaultSets.isNotEmpty) {
      setState(() {
        for (int i = 0; i < _exercise!.defaultSets.length; i++) {
          final ds = _exercise!.defaultSets[i];
          _sets.add(SetRow(
            setNumber: i + 1,
            plannedWeight: ds.weight,
            plannedReps: ds.reps,
            isDone: false,
          ));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingExercise) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final suggestion = ref.watch(progressionProvider(widget.exerciseId));

    suggestion.whenData((s) => _initSetsFromSuggestion(s));

    return Scaffold(
      appBar: AppBar(
        title: Text(_exercise?.name ?? context.l10n.log_session_title),
        backgroundColor: AppColors.bg,
        actions: [
          if (_exercise?.youTubeUrl != null)
            IconButton(
              icon: const Icon(Icons.play_circle_outline, color: AppColors.red),
              onPressed: () async {
                final url = Uri.parse(_exercise!.youTubeUrl!);
                if (await canLaunchUrl(url)) {
                await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
            ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Slika vjezbe
          if (_exercise != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: GestureDetector(
                  onTap: _exercise!.hasCustomImage ? () => _openFullImage(context) : null,
                  child: ExerciseImageWidget(
                    exercise: _exercise!,
                    height: 130,
                    editable: false,
                  ),
                ),
              ),
            ),

          // Progression banner
          SliverToBoxAdapter(
            child: suggestion.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (s) => s.hasData
                  ? ProgressionBanner(suggestion: s)
                  : const SizedBox.shrink(),
            ),
          ),

          // Tabela setova
          SliverToBoxAdapter(
            child: SetsTable(
              sets: _sets,
              onToggle: (i) =>
                  setState(() => _sets[i].isDone = !_sets[i].isDone),
            ),
          ),

          // Dodaj set dugme
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: OutlinedButton.icon(
                onPressed: _addSet,
                icon: const Icon(Icons.add, size: 18),
                label: Text(context.l10n.log_add_set),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accent,
                  side: const BorderSide(color: AppColors.accent),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),

          // Biljeska
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.log_notes_label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.text2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _notesCtrl,
                    maxLines: 2,
                    style: const TextStyle(color: AppColors.text1),
                    decoration: InputDecoration(
                      hintText: context.l10n.log_notes_hint,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Volume info
          if (_sets.any((s) => s.isDone))
            SliverToBoxAdapter(
              child: VolumeInfo(sets: _sets),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),

      // Save FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saving ? null : _save,
        backgroundColor:
            _sets.any((s) => s.isDone) ? AppColors.accent : AppColors.bg4,
        icon: _saving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.save_rounded, color: Colors.white),
        label: Text(
          context.l10n.log_save,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _addSet() {
    final last = _sets.isNotEmpty ? _sets.last : null;
    setState(() {
      _sets.add(SetRow(
        setNumber: _sets.length + 1,
        plannedWeight: last?.actualWeight ?? 0,
        plannedReps: last?.plannedReps ?? 10,
      ));
    });
  }

  Future<void> _save() async {
    final doneSets = _sets.where((s) => s.isDone).toList();
    if (doneSets.isEmpty) return;

    setState(() => _saving = true);

    await ref.read(workoutLogNotifierProvider.notifier).logWorkout(
          exerciseId: widget.exerciseId,
          logDate: DateTime.now(),
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          sets: _sets
              .map((s) => (
                    plannedReps: s.plannedReps,
                    actualReps: s.actualReps,
                    plannedWeight: s.plannedWeight,
                    actualWeight: s.actualWeight,
                    isCompleted: s.isDone,
                  ))
              .toList(),
        );

    // Invalidaj completed sets provider
    ref.invalidate(completedSetsTodayProvider(widget.exerciseId));
    if (mounted) Navigator.pop(context);
  }

  void _openFullImage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(backgroundColor: Colors.black),
          body: Center(
            child: InteractiveViewer(
              child: Image.file(
                File(_exercise!.imagePath!),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
