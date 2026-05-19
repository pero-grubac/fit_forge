import 'package:fit_forge/core/theme/app_colors.dart';
import 'package:fit_forge/core/utils/l10n_extension.dart';
import 'package:fit_forge/data/local/database_helper.dart';
import 'package:fit_forge/features/settings/providers/quote_provider.dart';
import 'package:fit_forge/features/settings/providers/settings_provider.dart';
import 'package:fit_forge/shared/widgets/error_state.dart';
import 'package:fit_forge/shared/widgets/stepper_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      body: SafeArea(
        child: settings.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ErrorState(
            onRetry: () => ref.invalidate(settingsProvider),
          ),
          data: (s) => _SettingsContent(settings: s),
        ),
      ),
    );
  }
}

class _SettingsContent extends ConsumerWidget {
  const _SettingsContent({required this.settings});

  final AppSettings settings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 40),
      children: [
        // Jezik
        _SectionLabel(context.l10n.settings_language_section),
        _SettingsCard(children: [
          _LanguageRow(
            selected: settings.locale,
            onChanged: (v) => ref.read(settingsProvider.notifier).setLocale(v),
          ),
        ]),
        const SizedBox(height: 20),
        Text(context.l10n.settings_title,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.text1)),
        const SizedBox(height: 20),

        // Progression pravila
        _SectionLabel(context.l10n.settings_progression_section),
        _SettingsCard(children: [
          _IncrementRow(
            label: context.l10n.settings_small_increment,
            subtitle: context.l10n.settings_small_increment_sub,
            value: settings.smallIncrement,
            min: 0.5,
            max: 10.0,
            step: 0.5,
            onChanged: (v) =>
                ref.read(settingsProvider.notifier).setSmallIncrement(v),
          ),
          const _Divider(),
          _IncrementRow(
            label: context.l10n.settings_large_increment,
            subtitle: context.l10n.settings_large_increment_sub,
            value: settings.largeIncrement,
            min: 1.0,
            max: 20.0,
            step: 1.0,
            onChanged: (v) =>
                ref.read(settingsProvider.notifier).setLargeIncrement(v),
          ),
          const _Divider(),
          _SliderRow(
            label: context.l10n.settings_threshold,
            subtitle: context.l10n.settings_threshold_sub,
            value: settings.progressionThreshold,
            onChanged: (v) =>
                ref.read(settingsProvider.notifier).setProgressionThreshold(v),
          ),
        ]),
        const SizedBox(height: 20),

        // Opste
        _SectionLabel(context.l10n.settings_general_section),
        _SettingsCard(children: [
          _ActionRow(
            label: context.l10n.settings_reset,
            subtitle: context.l10n.settings_reset_sub,
            icon: Icons.delete_outline,
            color: AppColors.red,
            onTap: () => _confirmReset(context, ref),
          ),
        ]),

        const SizedBox(height: 20),

        _SectionLabel(context.l10n.settings_quotes_section),
        _SettingsCard(children: [
          _ActionRow(
            label: context.l10n.settings_quotes_add,
            subtitle: context.l10n.settings_quotes_add_sub,
            icon: Icons.add_circle_outline,
            color: AppColors.accent,
            onTap: () => _showAddQuoteDialog(context, ref),
          ),
        ]),
        const SizedBox(height: 10),

// Lista poruka
        ref.watch(quoteNotifierProvider).when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => const ErrorState(),
              data: (quotes) => quotes.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        context.l10n.settings_quotes_empty,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.text3),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : _SettingsCard(
                      children: quotes.asMap().entries.map((e) {
                        final i = e.key;
                        final quote = e.value;
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  // Toggle aktivnosti
                                  Switch(
                                    value: quote.isActive,
                                    activeColor: AppColors.accent,
                                    onChanged: (v) => ref
                                        .read(quoteNotifierProvider.notifier)
                                        .toggleActive(quote.id, v),
                                  ),
                                  const SizedBox(width: 8),
                                  // Tekst poruke
                                  Expanded(
                                    child: Text(
                                      quote.text,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: quote.isActive
                                            ? AppColors.text1
                                            : AppColors.text3,
                                      ),
                                    ),
                                  ),
                                  // Delete
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        color: AppColors.red, size: 18),
                                    onPressed: () => ref
                                        .read(quoteNotifierProvider.notifier)
                                        .delete(quote.id),
                                  ),
                                ],
                              ),
                            ),
                            if (i < quotes.length - 1)
                              const Divider(height: 1, color: AppColors.border),
                          ],
                        );
                      }).toList(),
                    ),
            ),
      ],
    );
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.bg2,
        title: Text(context.l10n.settings_reset_title,
            style: const TextStyle(color: AppColors.text1)),
        content: Text(context.l10n.settings_reset_confirm,
            style: const TextStyle(color: AppColors.text2)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.l10n.btn_cancel,
                style: const TextStyle(color: AppColors.text2)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _resetAllData(ref);
            },
            child: Text(
              context.l10n.settings_reset,
              style: const TextStyle(color: AppColors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _resetAllData(WidgetRef ref) async {
    // Obrisi bazu
    final dbPath = join(await getDatabasesPath(), 'fitforge.db');
    await DatabaseHelper.instance.close();
    await deleteDatabase(dbPath);
    await DatabaseHelper.instance.initialize();

    // Resetuj settings
    await ref.read(settingsProvider.notifier).resetAllData();

    // Invalidaj sve providere
    ref.invalidate(settingsProvider);
  }

  void _showAddQuoteDialog(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.bg4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(context.l10n.settings_quote_new,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text1)),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              maxLines: 3,
              style: const TextStyle(color: AppColors.text1),
              decoration: InputDecoration(
                hintText: context.l10n.settings_quote_hint,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                  onPressed: () async {
                    if (ctrl.text.trim().isEmpty) return;
                    await ref
                        .read(quoteNotifierProvider.notifier)
                        .create(ctrl.text.trim());
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: Text(context.l10n.settings_quote_add_btn)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helper widgeti ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.text3,
              letterSpacing: 0.8)),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, color: AppColors.border);
}

class _IncrementRow extends StatelessWidget {
  const _IncrementRow({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.onChanged,
  });

  final String label;
  final String subtitle;
  final double value;
  final double min;
  final double max;
  final double step;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        const TextStyle(fontSize: 14, color: AppColors.text1)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.text3)),
              ],
            ),
          ),
          AppStepper(
            value: value,
            min: min,
            max: max,
            step: step,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String subtitle;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.text1)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.text3)),
                ],
              ),
              Text('${(value * 100).toInt()}%',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text1)),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.accent,
              inactiveTrackColor: AppColors.bg4,
              thumbColor: AppColors.accent,
              overlayColor: AppColors.accent.withOpacity(0.1),
              trackHeight: 3,
            ),
            child: Slider(
              value: value,
              min: 0.70,
              max: 1.00,
              divisions: 6,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 14, color: color)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.text3)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color.withOpacity(0.5), size: 20),
          ],
        ),
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  static const _options = [
    (label: 'English', value: 'en'),
    (label: 'Srpski (lat)', value: 'sr'),
    (label: 'Srpski (ćir)', value: 'sr_Cyrl'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected,
          isExpanded: true,
          dropdownColor: AppColors.bg2,
          style: const TextStyle(color: AppColors.text1, fontSize: 14),
          icon: const Icon(Icons.expand_more, color: AppColors.text2),
          items: _options
              .map((opt) => DropdownMenuItem(
                    value: opt.value,
                    child: Text(opt.label),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}
