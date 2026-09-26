import 'package:fit_forge/core/theme/app_colors.dart';
import 'package:fit_forge/core/utils/l10n_extension.dart';
import 'package:fit_forge/features/settings/providers/quote_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Motivational quote on the home screen. A different quote is picked every
/// time the banner is shown again (see [QuoteRotation]).
class MotivationBanner extends ConsumerStatefulWidget {
  const MotivationBanner({super.key});

  @override
  ConsumerState<MotivationBanner> createState() => _MotivationBannerState();
}

class _MotivationBannerState extends ConsumerState<MotivationBanner> {
  @override
  void initState() {
    super.initState();
    // Coming back to the home tab builds a new banner: rotate. Providers
    // can't change during build, so do it after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(quoteRotationProvider.notifier).next();
    });
  }

  @override
  Widget build(BuildContext context) {
    final position = ref.watch(quoteRotationProvider);
    final custom = ref.watch(activeQuotesProvider).valueOrNull ?? const [];
    final pool = custom.isNotEmpty
        ? [for (final q in custom) q.text]
        : _builtInQuotes(context);
    final message = pool[position % pool.length];

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppColors.accent.withValues(alpha: 0.1),
          AppColors.green.withValues(alpha: 0.06),
        ]),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.18)),
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
            key: const Key('motivation_quote'),
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

  /// Must stay in sync with [builtInQuoteCount].
  List<String> _builtInQuotes(BuildContext context) => [
        context.l10n.motivation_1,
        context.l10n.motivation_2,
        context.l10n.motivation_3,
        context.l10n.motivation_4,
        context.l10n.motivation_5,
      ];
}
