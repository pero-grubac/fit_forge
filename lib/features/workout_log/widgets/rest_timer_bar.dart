import 'package:fit_forge/core/theme/app_colors.dart';
import 'package:fit_forge/core/utils/l10n_extension.dart';
import 'package:fit_forge/features/workout_log/providers/rest_timer_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bottom bar with the rest countdown; hidden when no rest is running.
class RestTimerBar extends ConsumerWidget {
  const RestTimerBar({super.key});

  static const _extra = Duration(seconds: 15);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(restTimerProvider);
    if (timer == null) return const SizedBox.shrink();

    final notifier = ref.read(restTimerProvider.notifier);
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
        decoration: BoxDecoration(
          color: AppColors.bg2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.amber.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                value: timer.fraction,
                strokeWidth: 3,
                color: AppColors.amber,
                backgroundColor: AppColors.bg4,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(context.l10n.rest_title,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.text2)),
                  Text(
                    formatDuration(timer.remaining),
                    key: const Key('rest_remaining'),
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text1,
                        fontFeatures: [FontFeature.tabularFigures()]),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => notifier.addTime(_extra),
              child: Text('+${_extra.inSeconds} s',
                  style: const TextStyle(color: AppColors.amber)),
            ),
            TextButton(
              onPressed: notifier.skip,
              child: Text(context.l10n.rest_skip,
                  style: const TextStyle(color: AppColors.text2)),
            ),
          ],
        ),
      ),
    );
  }
}

/// `m:ss`, e.g. 1:05.
String formatDuration(Duration d) {
  final minutes = d.inMinutes;
  final seconds = d.inSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}
