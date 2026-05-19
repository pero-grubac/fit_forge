import 'package:fit_forge/core/models/progression_suggestion.dart';
import 'package:fit_forge/core/theme/app_colors.dart';
import 'package:fit_forge/core/utils/l10n_extension.dart';
import 'package:flutter/material.dart';

class ProgressionBanner extends StatelessWidget {
  const ProgressionBanner({super.key, required this.suggestion});

  final ProgressionSuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    final color = switch (suggestion.confidence) {
      'High' => AppColors.green,
      'Hold' => AppColors.amber,
      'Reduce' => AppColors.red,
      _ => AppColors.accent,
    };

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.trending_up_rounded, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.log_progression_title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(suggestion.reason,
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.text2)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
