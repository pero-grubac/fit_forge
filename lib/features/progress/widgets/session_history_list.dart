import 'package:fit_forge/core/theme/app_colors.dart';
import 'package:fit_forge/core/utils/l10n_extension.dart';
import 'package:fit_forge/core/utils/set_progression.dart';
import 'package:fit_forge/data/models/exercise_model.dart';
import 'package:fit_forge/data/models/workout_log_model.dart';
import 'package:fit_forge/features/workout_log/providers/workout_log_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Past sessions of one exercise, newest first. Swipe a row right to edit
/// its note, left to clear it — the session itself is never removed.
class SessionHistoryList extends StatelessWidget {
  const SessionHistoryList({super.key, required this.logs, required this.exercise});

  final List<WorkoutLogModel> logs;
  final ExerciseModel exercise;

  @override
  Widget build(BuildContext context) {
    final sorted = [...logs]..sort((a, b) => b.logDate.compareTo(a.logDate));
    if (sorted.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
            child: Text(context.l10n.progress_history_title,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text2)),
          ),
          for (final (i, log) in sorted.indexed) ...[
            if (i > 0) const Divider(height: 1, color: AppColors.border),
            _HistoryRow(log: log, exercise: exercise),
          ],
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

/// The scroll target a chart point tap looks up to bring this row into view.
GlobalObjectKey historyRowKey(String logId) =>
    GlobalObjectKey('session_history_$logId');

class _HistoryRow extends ConsumerWidget {
  const _HistoryRow({required this.log, required this.exercise});

  final WorkoutLogModel log;
  final ExerciseModel exercise;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unit = exercise.progressionUnit;
    final completed = [...log.sets.where((s) => s.isCompleted)]
      ..sort((a, b) => a.setNumber.compareTo(b.setNumber));
    final summary = completed
        .map((s) => switch (unit) {
              ProgressionUnit.kg => '${_fmtNum(s.actualWeight)}kg×${s.actualReps}',
              ProgressionUnit.reps => '${s.actualReps} reps',
              ProgressionUnit.seconds => '${s.actualReps}s',
            })
        .join(' · ');
    final note = log.notes?.trim();

    return Dismissible(
      key: historyRowKey(log.id),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 16),
        color: AppColors.accent.withValues(alpha: 0.15),
        child: const Icon(Icons.edit_outlined, color: AppColors.accent),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: AppColors.red.withValues(alpha: 0.15),
        child: const Icon(Icons.delete_outline, color: AppColors.red),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          await _editNote(context, ref, log);
        } else if (note != null && note.isNotEmpty) {
          await ref.read(workoutLogNotifierProvider.notifier).updateNotes(
              logId: log.id, exerciseId: log.exerciseId, notes: null);
        }
        return false; // the session row itself always stays.
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${log.logDate.day}.${log.logDate.month}.${log.logDate.year}.',
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text1),
            ),
            if (summary.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(summary,
                  style: const TextStyle(fontSize: 12, color: AppColors.text2)),
            ],
            const SizedBox(height: 2),
            Text(
              (note == null || note.isEmpty)
                  ? context.l10n.progress_history_no_note
                  : note,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: (note == null || note.isEmpty)
                    ? AppColors.text3
                    : AppColors.text2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editNote(
      BuildContext context, WidgetRef ref, WorkoutLogModel log) async {
    final ctrl = TextEditingController(text: log.notes ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bg2,
        title: Text(ctx.l10n.progress_history_edit_note,
            style: const TextStyle(color: AppColors.text1, fontSize: 16)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLines: 3,
          style: const TextStyle(color: AppColors.text1),
          decoration: InputDecoration(hintText: ctx.l10n.log_notes_hint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(ctx.l10n.btn_cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: Text(ctx.l10n.btn_save),
          ),
        ],
      ),
    );
    ctrl.dispose();
    if (result == null) return;
    await ref.read(workoutLogNotifierProvider.notifier).updateNotes(
        logId: log.id,
        exerciseId: log.exerciseId,
        notes: result.isEmpty ? null : result);
  }
}

String _fmtNum(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();
