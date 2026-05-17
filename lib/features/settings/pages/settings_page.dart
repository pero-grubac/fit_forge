import 'package:fit_forge/core/theme/app_colors.dart';
import 'package:fit_forge/data/local/database_helper.dart';
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
        const Text('Settings',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.text1)),
        const SizedBox(height: 20),

        // Progression pravila
        const _SectionLabel('PROGRESSION PRAVILA'),
        _SettingsCard(children: [
          _IncrementRow(
            label: 'Mali inkrement',
            subtitle: 'Za tezine do 100 kg',
            value: settings.smallIncrement,
            min: 0.5,
            max: 10.0,
            step: 0.5,
            onChanged: (v) =>
                ref.read(settingsProvider.notifier).setSmallIncrement(v),
          ),
          const _Divider(),
          _IncrementRow(
            label: 'Veliki inkrement',
            subtitle: 'Za tezine iznad 100 kg',
            value: settings.largeIncrement,
            min: 1.0,
            max: 20.0,
            step: 1.0,
            onChanged: (v) =>
                ref.read(settingsProvider.notifier).setLargeIncrement(v),
          ),
          const _Divider(),
          _SliderRow(
            label: 'Prag napretka',
            subtitle: 'Min. completion rate za povecanje tezine',
            value: settings.progressionThreshold,
            onChanged: (v) =>
                ref.read(settingsProvider.notifier).setProgressionThreshold(v),
          ),
        ]),
        const SizedBox(height: 20),

        // Opste
        const _SectionLabel('OPSTE'),
        _SettingsCard(children: [
          _ActionRow(
            label: 'Resetuj sve podatke',
            subtitle: 'Brise sve planove, vjezbe i treninge',
            icon: Icons.delete_outline,
            color: AppColors.red,
            onTap: () => _confirmReset(context, ref),
          ),
        ]),
      ],
    );
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.bg2,
        title: const Text('Resetuj sve podatke',
            style: TextStyle(color: AppColors.text1)),
        content: const Text(
            'Ovo ce obrisati sve planove, vjezbe i istoriju treninga. Ova akcija se ne moze ponistiti.',
            style: TextStyle(color: AppColors.text2)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Odustani',
                style: TextStyle(color: AppColors.text2)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _resetAllData(ref);
            },
            child:
                const Text('Resetuj', style: TextStyle(color: AppColors.red)),
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
