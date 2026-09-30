import 'dart:io';

import 'package:fit_forge/core/utils/l10n_extension.dart';
import 'package:fit_forge/data/providers.dart';
import 'package:fit_forge/features/workout_log/widgets/progression_banner.dart';
import 'package:fit_forge/features/workout_log/widgets/set_row.dart';
import 'package:fit_forge/features/settings/providers/settings_provider.dart';
import 'package:fit_forge/features/workout_log/providers/rest_timer_provider.dart';
import 'package:fit_forge/features/workout_log/widgets/rest_timer_bar.dart';
import 'package:fit_forge/features/workout_log/widgets/volume_info.dart';
import 'package:fit_forge/features/workout_plan/widgets/exercise_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/utils/set_progression.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/exercise_model.dart';
import '../../../data/models/plan_exercise_model.dart';
import '../../../data/models/workout_log_model.dart';
import '../../workout_plan/widgets/exercise_info_sheet.dart';
import '../providers/progression_provider.dart';
import '../providers/workout_log_provider.dart';

class LogSessionPage extends ConsumerStatefulWidget {
  const LogSessionPage({required this.planExerciseId, super.key});

  final String planExerciseId;

  @override
  ConsumerState<LogSessionPage> createState() => _LogSessionPageState();
}

class _LogSessionPageState extends ConsumerState<LogSessionPage> {
  PlanExerciseModel? _planExercise;
  bool _loadingExercise = true;

  /// The most recent earlier session of this exercise that has a note.
  WorkoutLogModel? _lastNoteLog;

  /// Set-count progression for this plan exercise; null if unavailable.
  ProgressionInfo? _progression;

  bool get _progressionOn => _progression?.enabled ?? false;

  bool get _byReps =>
      _progression != null && _progression!.unit != ProgressionUnit.kg;

  /// Where the counter stands after earlier sessions plus the sets ticked so
  /// far today (in list order). Null while moving up to a new level: that
  /// workout's sets are fixed.
  ProgressionState? get _currentProgression {
    final p = _progression;
    if (p == null || p.status.isMoving) return null;
    return p.rule.replay(p.status.counting, [
      for (final s in _sets)
        if (s.isDone)
          (
            level: _byReps ? s.plannedReps.toDouble() : s.actualWeight,
            success: s.actualReps >= s.plannedReps,
          ),
    ]);
  }

  /// Re-plans the sets not done yet from the current counter, e.g. after a
  /// set was ticked. Values the user typed are kept.
  void _applyProgression() {
    final state = _currentProgression;
    if (!_progressionOn || state == null) return;
    final open = _sets.where((s) => !s.isDone).toList();
    final levels = _progression!.rule.plan(state, open.length);
    for (final (i, set) in open.indexed) {
      if (_byReps) {
        set.setTarget(reps: levels[i].round());
      } else {
        set.setTarget(weight: levels[i]);
      }
    }
  }

  final _notesCtrl = TextEditingController();
  final _sets = <SetRow>[];
  bool _saving = false;

  ExerciseModel? get _exercise => _planExercise?.exercise;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    for (final s in _sets) {
      s.dispose();
    }
    super.dispose();
  }

  /// Loads the plan exercise and fills the sets from the first available
  /// source: today's log, the plan targets with progression applied, the last
  /// log from this plan slot, then the plan targets as they are.
  Future<void> _init() async {
    final logRepo = ref.read(workoutLogRepositoryProvider);
    final planExercise = await ref
        .read(planExerciseRepositoryProvider)
        .getById(widget.planExerciseId);
    if (planExercise == null) {
      if (mounted) setState(() => _loadingExercise = false);
      return;
    }

    final todayLog =
        await logRepo.getForPlanExerciseOn(planExercise.id, DateTime.now());
    final history = await logRepo.getByExercise(planExercise.exerciseId);
    final lastSlotLog = history
        .where((l) => l.planExerciseId == planExercise.id && l.sets.isNotEmpty)
        .firstOrNull;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastNoteLog = history
        .where((l) =>
            (l.notes?.trim().isNotEmpty ?? false) &&
            l.logDate.toIso8601String().substring(0, 10) != today)
        .firstOrNull;

    ProgressionInfo? progression;
    try {
      progression =
          await ref.read(progressionProvider(widget.planExerciseId).future);
    } catch (_) {
      // Without progression the sets come from the last log or the plan.
    }

    if (!mounted) return;

    final byReps =
        progression != null && progression.unit != ProgressionUnit.kg;
    final List<SetRow> sets;
    if (todayLog != null && todayLog.sets.isNotEmpty) {
      if (todayLog.notes != null) _notesCtrl.text = todayLog.notes!;
      sets = [
        for (final s in todayLog.sets)
          SetRow(
            setNumber: s.setNumber,
            plannedWeight: s.plannedWeight,
            plannedReps: s.plannedReps,
            isDone: s.isCompleted,
          )
            ..weightCtrl.text = s.actualWeight.toString()
            ..repsCtrl.text = s.actualReps.toString(),
      ];
    } else if (progression != null &&
        progression.enabled &&
        planExercise.defaultSets.isNotEmpty) {
      // Plan targets, with the level of each set from the progression rule.
      final levels = progression.rule
          .planSession(progression.status, planExercise.defaultSets.length);
      sets = [
        for (final (i, ds) in planExercise.defaultSets.indexed)
          SetRow(
            setNumber: i + 1,
            plannedWeight: byReps ? ds.weight : levels[i],
            plannedReps: byReps ? levels[i].round() : ds.reps,
          ),
      ];
    } else if (lastSlotLog != null) {
      sets = [
        for (final s in lastSlotLog.sets)
          SetRow(
            setNumber: s.setNumber,
            plannedWeight: s.actualWeight,
            plannedReps: s.plannedReps,
          ),
      ];
    } else {
      sets = [
        for (final ds in planExercise.defaultSets)
          SetRow(
            setNumber: ds.setNumber,
            plannedWeight: ds.weight,
            plannedReps: ds.reps,
          ),
      ];
    }

    setState(() {
      _planExercise = planExercise;
      _progression = progression;
      _lastNoteLog = lastNoteLog;
      _sets.addAll(sets);
      _loadingExercise = false;
    });
  }

  /// Opens the exercise info sheet (description, image, link) and shows the
  /// changes here afterwards. The sets being logged are left untouched.
  Future<void> _editExercise() async {
    final exercise = _exercise;
    if (exercise == null) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ExerciseInfoSheet(exercise: exercise),
    );

    final fresh = await ref
        .read(planExerciseRepositoryProvider)
        .getById(widget.planExerciseId);
    if (!mounted) return;
    if (fresh == null) {
      // The exercise was deleted from the sheet.
      Navigator.pop(context);
      return;
    }
    setState(() => _planExercise = fresh);
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingExercise) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_exercise?.name ?? context.l10n.log_session_title),
        backgroundColor: AppColors.bg,
        actions: [
          if (_exercise != null)
            IconButton(
              tooltip: context.l10n.exercise_edit,
              icon: const Icon(Icons.edit_note_rounded),
              onPressed: _editExercise,
            ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Exercise image
          if (_exercise != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: GestureDetector(
                  onTap: _exercise!.hasCustomImage
                      ? () => _openFullImage(context)
                      : null,
                  child: ExerciseImageWidget(
                    exercise: _exercise!,
                    height: 130,
                    editable: false,
                  ),
                ),
              ),
            ),
          // Description
          if (_exercise != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _DescriptionCard(
                  description: _exercise!.description,
                  onEdit: _editExercise,
                ),
              ),
            ),
          // YouTube button
          if (_exercise?.youTubeUrl != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final url = Uri.parse(_exercise!.youTubeUrl!);
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.play_circle_outline,
                      color: AppColors.red),
                  label: Text(context.l10n.exercise_watch_youtube,
                      style: const TextStyle(color: AppColors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.red),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
          // Progression banner
          if (_progressionOn)
            SliverToBoxAdapter(
              child: ProgressionBanner(
                rule: _progression!.rule,
                state: _currentProgression ?? _progression!.status.counting,
                transition: _progression!.status.transition,
                setsInWorkout: _sets.length,
                unit: _progression!.unit,
              ),
            ),

          // Sets table
          SliverToBoxAdapter(
            child: SetsTable(
              sets: _sets,
              onToggle: _toggleSet,
              onDelete: (i) => setState(() {
                final replaced = [_sets.removeAt(i)];
                for (int j = i; j < _sets.length; j++) {
                  replaced.add(_sets[j]);
                  _sets[j] = _sets[j].renumbered(j + 1);
                }
                _applyProgression();
                // Their text fields are still mounted until this rebuild.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  for (final row in replaced) {
                    row.dispose();
                  }
                });
              }),
              exerciseType: _exercise?.exerciseType ?? 'weighted',
            ),
          ),

          // Add set button
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

          // Notes
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
                  if (_lastNoteLog != null) ...[
                    _LastNote(log: _lastNoteLog!),
                    const SizedBox(height: 8),
                  ],
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
      bottomNavigationBar: const RestTimerBar(),
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

  void _toggleSet(int i) {
    setState(() {
      _sets[i].isDone = !_sets[i].isDone;
      _applyProgression();
    });
    if (_sets[i].isDone) _startRest();
  }

  /// Starts the rest timer after a completed set, unless it was the last one.
  void _startRest() {
    if (_sets.every((s) => s.isDone)) {
      ref.read(restTimerProvider.notifier).skip();
      return;
    }
    final seconds = ref.read(settingsProvider).valueOrNull?.restSeconds ?? 0;
    if (seconds <= 0) return;
    final l10n = context.l10n;
    ref.read(restTimerProvider.notifier).start(
      Duration(seconds: seconds),
      (
        restingTitle: l10n.rest_notification_title,
        doneTitle: l10n.rest_done_title,
        doneBody: l10n.rest_done_body(_exercise?.name ?? ''),
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
      _applyProgression();
    });
  }

  Future<void> _save() async {
    final doneSets = _sets.where((s) => s.isDone).toList();
    if (doneSets.isEmpty || _planExercise == null) return;

    setState(() => _saving = true);

    final log = await ref.read(workoutLogNotifierProvider.notifier).logWorkout(
          planExercise: _planExercise!,
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

    if (!mounted) return;
    if (log == null) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.error_generic)),
      );
      return;
    }
    Navigator.pop(context);
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

/// The exercise description, collapsed to a few lines. Without a description
/// it offers to add one.
class _DescriptionCard extends StatefulWidget {
  const _DescriptionCard({required this.description, required this.onEdit});

  final String? description;
  final VoidCallback onEdit;

  @override
  State<_DescriptionCard> createState() => _DescriptionCardState();
}

class _DescriptionCardState extends State<_DescriptionCard> {
  static const _collapsedLines = 3;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final text = widget.description?.trim() ?? '';
    if (text.isEmpty) {
      return Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: widget.onEdit,
          icon: const Icon(Icons.add, size: 16),
          label: Text(context.l10n.exercise_add_description),
          style: TextButton.styleFrom(foregroundColor: AppColors.text2),
        ),
      );
    }

    const style = TextStyle(fontSize: 13, color: AppColors.text2, height: 1.4);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: LayoutBuilder(builder: (context, constraints) {
        // Only offer "show more" when the text doesn't fit.
        final painter = TextPainter(
          text: TextSpan(text: text, style: style),
          maxLines: _collapsedLines,
          textDirection: Directionality.of(context),
        )..layout(maxWidth: constraints.maxWidth);
        final overflows = painter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              key: const Key('exercise_description'),
              style: style,
              maxLines: _expanded ? null : _collapsedLines,
              overflow: _expanded ? null : TextOverflow.ellipsis,
            ),
            if (overflows)
              TextButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 32),
                  foregroundColor: AppColors.accent,
                ),
                child: Text(_expanded
                    ? context.l10n.log_show_less
                    : context.l10n.log_show_more),
              )
            else
              const SizedBox(height: 8),
          ],
        );
      }),
    );
  }
}

/// The note written in the previous session of this exercise.
class _LastNote extends StatelessWidget {
  const _LastNote({required this.log});

  final WorkoutLogModel log;

  @override
  Widget build(BuildContext context) {
    final date = log.logDate;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bg3,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.log_last_note('${date.day}.${date.month}.'),
            style: const TextStyle(fontSize: 11, color: AppColors.text3),
          ),
          const SizedBox(height: 4),
          Text(
            log.notes!.trim(),
            key: const Key('last_session_note'),
            style: const TextStyle(fontSize: 13, color: AppColors.text2),
          ),
        ],
      ),
    );
  }
}
