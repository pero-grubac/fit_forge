import 'package:fit_forge/core/theme/app_colors.dart';
import 'package:fit_forge/core/utils/l10n_extension.dart';
import 'package:fit_forge/features/workout_log/providers/weekly_summary_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// "This week: +8% volume, 2 new PRs" on the Home screen, next to the
/// motivational quote. Hidden until there's something to show.
class WeeklySummaryCard extends ConsumerWidget {
  const WeeklySummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(weeklySummaryProvider).valueOrNull;
    if (summary == null || summary.isEmpty) return const SizedBox.shrink();

    final lines = <String>[];
    final pct = summary.volumeChangePercent;
    if (pct != null) {
      final sign = pct >= 0 ? '+' : '';
      lines.add(
          context.l10n.weekly_summary_volume('$sign${pct.toStringAsFixed(0)}%'));
    }
    if (summary.newPrCount > 0) {
      lines.add(context.l10n.weekly_summary_new_prs(summary.newPrCount));
    }
    if (lines.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppColors.green.withValues(alpha: 0.1),
          AppColors.accent.withValues(alpha: 0.06),
        ]),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.green.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_graph_rounded, color: AppColors.green, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.weekly_summary_title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.green,
                  ),
                ),
                const SizedBox(height: 4),
                for (final line in lines)
                  Text(line,
                      style: const TextStyle(fontSize: 13, color: AppColors.text2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
