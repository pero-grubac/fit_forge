import 'package:fit_forge/core/theme/app_colors.dart';
import 'package:fit_forge/core/utils/l10n_extension.dart';
import 'package:fit_forge/features/settings/providers/quote_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MotivationBanner extends ConsumerWidget {
  const MotivationBanner({super.key, required this.planName});

  final String planName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quoteAsync = ref.watch(randomActiveQuoteProvider);

    final message = quoteAsync.maybeWhen(
      data: (q) => q ?? _defaultMessage(context),
      orElse: () => _defaultMessage(context),
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppColors.accent.withOpacity(0.1),
          AppColors.green.withOpacity(0.06),
        ]),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accent.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.motivationTitle,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '"$message"',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.text2,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  String _defaultMessage(BuildContext context) {
    final messages = [
      context.l10n.motivation_1,
      context.l10n.motivation_2,
      context.l10n.motivation_3,
      context.l10n.motivation_4,
      context.l10n.motivation_5,
    ];
    return messages[DateTime.now().day % messages.length];
  }
}
