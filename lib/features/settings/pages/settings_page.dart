import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:fit_forge/core/theme/app_colors.dart';
import 'package:fit_forge/core/utils/error_handler.dart';
import 'package:fit_forge/core/utils/l10n_extension.dart';
import 'package:fit_forge/data/providers.dart';
import 'package:fit_forge/data/repositories/backup_repository.dart';
import 'package:fit_forge/features/progress/providers/progress_provider.dart';
import 'package:fit_forge/features/settings/providers/quote_provider.dart';
import 'package:fit_forge/features/settings/providers/settings_provider.dart';
import 'package:fit_forge/features/workout_log/providers/streak_provider.dart';
import 'package:fit_forge/features/workout_log/providers/workout_log_provider.dart';
import 'package:fit_forge/features/workout_log/widgets/rest_timer_bar.dart';
import 'package:fit_forge/features/workout_plan/providers/workout_plan_provider.dart';
import 'package:fit_forge/shared/widgets/error_state.dart';
import 'package:fit_forge/shared/widgets/stepper_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
        // Language
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

        // Progression rules
        _SectionLabel(context.l10n.settings_progression_section),
        _SettingsCard(children: [
          _SwitchRow(
            label: context.l10n.settings_auto_progression,
            subtitle: context.l10n.settings_auto_progression_sub,
            value: settings.autoProgression,
            onChanged: (v) =>
                ref.read(settingsProvider.notifier).setAutoProgression(v),
          ),
          if (settings.autoProgression) ...[
            const _Divider(),
            _IncrementRow(
              label: context.l10n.settings_sets_to_progress,
              subtitle: context.l10n.settings_sets_to_progress_sub,
              value: settings.setsToProgress.toDouble(),
              min: 1,
              max: 30,
              step: 1,
              format: (v) => '${v.toInt()}',
              onChanged: (v) => ref
                  .read(settingsProvider.notifier)
                  .setSetsToProgress(v.toInt()),
            ),
            const _Divider(),
            _IncrementRow(
              label: context.l10n.settings_default_increment,
              subtitle: context.l10n.settings_default_increment_sub,
              value: settings.defaultIncrement,
              min: 0.5,
              max: 20.0,
              step: 0.5,
              onChanged: (v) =>
                  ref.read(settingsProvider.notifier).setDefaultIncrement(v),
            ),
          ],
        ]),
        const SizedBox(height: 20),

        // Rest timer
        _SectionLabel(context.l10n.settings_rest_section),
        _SettingsCard(children: [
          _IncrementRow(
            label: context.l10n.settings_rest,
            subtitle: context.l10n.settings_rest_sub,
            value: settings.restSeconds.toDouble(),
            min: 0,
            max: 300,
            step: 15,
            format: (v) => v == 0
                ? context.l10n.settings_rest_off
                : formatDuration(Duration(seconds: v.toInt())),
            onChanged: (v) =>
                ref.read(settingsProvider.notifier).setRestSeconds(v.toInt()),
          ),
        ]),
        const SizedBox(height: 20),

        // Data
        _SectionLabel(context.l10n.settings_data_section),
        _SettingsCard(children: [
          _ActionRow(
            label: context.l10n.settings_export,
            subtitle: context.l10n.settings_export_sub,
            icon: Icons.upload_file_outlined,
            color: AppColors.accent,
            onTap: () => _exportData(context, ref),
          ),
          const _Divider(),
          _ActionRow(
            label: context.l10n.settings_import,
            subtitle: context.l10n.settings_import_sub,
            icon: Icons.download_outlined,
            color: AppColors.accent,
            onTap: () => _confirmImport(context, ref),
          ),
        ]),
        const SizedBox(height: 20),

        // General
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

// Quote list
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
                                  // Active toggle
                                  Switch(
                                    value: quote.isActive,
                                    activeThumbColor: AppColors.accent,
                                    onChanged: (v) => ref
                                        .read(quoteNotifierProvider.notifier)
                                        .toggleActive(quote.id, v),
                                  ),
                                  const SizedBox(width: 8),
                                  // Quote text
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

        // Developer (hidden until unlocked)
        if (settings.devMode) ...[
          const SizedBox(height: 20),
          _SectionLabel(context.l10n.settings_dev_section),
          _SettingsCard(children: [
            _ActionRow(
              label: context.l10n.settings_demo,
              subtitle: context.l10n.settings_demo_sub,
              icon: Icons.science_outlined,
              color: AppColors.amber,
              onTap: () => _confirmDemoData(context, ref),
            ),
            const _Divider(),
            _ActionRow(
              label: context.l10n.settings_dev_hide,
              subtitle: context.l10n.settings_dev_hide_sub,
              icon: Icons.visibility_off_outlined,
              color: AppColors.text2,
              onTap: () =>
                  ref.read(settingsProvider.notifier).setDevMode(false),
            ),
          ]),
        ],

        const SizedBox(height: 24),
        _VersionFooter(devMode: settings.devMode),
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
    await ref.read(databaseHelperProvider).recreate();
    await ref.read(settingsProvider.notifier).resetAllData();
    ref.invalidate(settingsProvider);
    _invalidateData(ref);
  }

  /// Everything cached from the database is stale after a reset or import.
  void _invalidateData(WidgetRef ref) {
    ref.invalidate(workoutPlanNotifierProvider);
    ref.invalidate(planExercisesProvider);
    ref.invalidate(exercisesWithLogsProvider);
    ref.invalidate(exerciseHistoryProvider);
    ref.invalidate(exerciseLogsProvider);
    ref.invalidate(quoteNotifierProvider);
    ref.invalidate(streakProvider);
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      final json = await ref.read(backupRepositoryProvider).exportJson();
      final date = DateTime.now().toIso8601String().substring(0, 10);
      final uri = await FilePicker.saveFile(
        fileName: 'fitforge-backup-$date.json',
        bytes: Uint8List.fromList(utf8.encode(json)),
        mimeType: 'application/json',
      );
      if (uri != null) {
        messenger
            .showSnackBar(SnackBar(content: Text(l10n.settings_export_done)));
      }
    } catch (e, st) {
      ErrorHandler.handle(e, st);
      messenger.showSnackBar(SnackBar(content: Text(l10n.error_generic)));
    }
  }

  Future<void> _confirmDemoData(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.bg2,
        title: Text(context.l10n.settings_demo,
            style: const TextStyle(color: AppColors.text1)),
        content: Text(context.l10n.settings_demo_confirm,
            style: const TextStyle(color: AppColors.text2)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.btn_cancel,
                style: const TextStyle(color: AppColors.text2)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.l10n.settings_demo_btn,
                style: const TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      await ref.read(demoDataProvider).load();
      _invalidateData(ref);
      messenger.showSnackBar(SnackBar(content: Text(l10n.settings_demo_done)));
    } catch (e, st) {
      ErrorHandler.handle(e, st);
      messenger.showSnackBar(SnackBar(content: Text(l10n.error_generic)));
    }
  }

  Future<void> _confirmImport(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.bg2,
        title: Text(context.l10n.settings_import,
            style: const TextStyle(color: AppColors.text1)),
        content: Text(context.l10n.settings_import_confirm,
            style: const TextStyle(color: AppColors.text2)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.btn_cancel,
                style: const TextStyle(color: AppColors.text2)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.l10n.settings_import_btn,
                style: const TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (files.isEmpty) return;
      final json = await files.first.xFile.readAsString();
      await ref.read(backupRepositoryProvider).importJson(json);
      _invalidateData(ref);
      messenger
          .showSnackBar(SnackBar(content: Text(l10n.settings_import_done)));
    } on BackupFormatException catch (e) {
      ErrorHandler.handle(e, StackTrace.current);
      messenger
          .showSnackBar(SnackBar(content: Text(l10n.settings_import_invalid)));
    } catch (e, st) {
      ErrorHandler.handle(e, st);
      messenger.showSnackBar(SnackBar(content: Text(l10n.error_generic)));
    }
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

// ── Helper widgets ───────────────────────────────────────────────────────────

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
    this.format,
  });

  final String label;
  final String subtitle;
  final double value;
  final double min;
  final double max;
  final double step;
  final ValueChanged<double> onChanged;
  final String Function(double value)? format;

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
            format: format,
          ),
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
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
          Switch(
            value: value,
            activeThumbColor: AppColors.accent,
            onChanged: onChanged,
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
            Icon(Icons.chevron_right,
                color: color.withValues(alpha: 0.5), size: 20),
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

final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version} (${info.buildNumber})';
});

/// App version. Tapping it [_tapsToUnlock] times unlocks the developer
/// section, like Android's "build number" trick.
class _VersionFooter extends ConsumerStatefulWidget {
  const _VersionFooter({required this.devMode});

  final bool devMode;

  @override
  ConsumerState<_VersionFooter> createState() => _VersionFooterState();
}

class _VersionFooterState extends ConsumerState<_VersionFooter> {
  static const _tapsToUnlock = 7;
  static const _hintFrom = 4;
  int _taps = 0;

  void _onTap() {
    if (widget.devMode) return;
    _taps++;
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    if (_taps >= _tapsToUnlock) {
      _taps = 0;
      ref.read(settingsProvider.notifier).setDevMode(true);
      messenger.showSnackBar(
          SnackBar(content: Text(context.l10n.settings_dev_unlocked)));
    } else if (_taps >= _hintFrom) {
      messenger.showSnackBar(SnackBar(
        content:
            Text(context.l10n.settings_dev_taps_left(_tapsToUnlock - _taps)),
        duration: const Duration(milliseconds: 800),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final version = ref.watch(appVersionProvider).valueOrNull ?? '';
    return Center(
      child: GestureDetector(
        key: const Key('app_version'),
        behavior: HitTestBehavior.opaque,
        onTap: _onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            context.l10n.settings_version(version),
            style: const TextStyle(fontSize: 12, color: AppColors.text3),
          ),
        ),
      ),
    );
  }
}
