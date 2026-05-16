import 'package:fit_forge/core/theme/app_colors.dart';
import 'package:fit_forge/data/models/workout_plan_model.dart';
import 'package:fit_forge/features/workout_plan/providers/workout_plan_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlanListPage extends ConsumerWidget {
  const PlanListPage({super.key});

  static const _days = [
    '',
    'Ponedjeljak',
    'Utorak',
    'Srijeda',
    'Cetvrtak',
    'Petak',
    'Subota',
    'Nedjelja'
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(workoutPlansProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 16, 18, 16),
              child: Text('Plan editor',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text1)),
            ),
            Expanded(
              child: plans.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Greska: $e')),
                data: (list) => list.isEmpty
                    ? _EmptyState(onAdd: () => _showCreateDialog(context, ref))
                    : _PlanList(plans: list, days: _days),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context, ref),
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Novi plan',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bg2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CreatePlanSheet(ref: ref),
    );
  }
}

class _PlanList extends StatelessWidget {
  const _PlanList({required this.plans, required this.days});

  final List<WorkoutPlanModel> plans;
  final List<String> days;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 80),
      itemCount: plans.length,
      itemBuilder: (context, i) {
        final plan = plans[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.calendar_month,
                  color: AppColors.accent, size: 22),
            ),
            title: Text(plan.name,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: AppColors.text1)),
            subtitle: Text(days[plan.dayOfWeek],
                style: const TextStyle(color: AppColors.text2, fontSize: 12)),
            trailing: const Icon(Icons.chevron_right, color: AppColors.text3),
            onTap: () {
              // navigacija na plan detail
            },
          ),
        );
      },
    );
  }
}

class _CreatePlanSheet extends StatefulWidget {
  const _CreatePlanSheet({required this.ref});

  final WidgetRef ref;

  @override
  State<_CreatePlanSheet> createState() => _CreatePlanSheetState();
}

class _CreatePlanSheetState extends State<_CreatePlanSheet> {
  final _nameController = TextEditingController();
  int _selectedDay = 1;
  bool _loading = false;

  static const _days = [
    '',
    'Ponedjeljak',
    'Utorak',
    'Srijeda',
    'Cetvrtak',
    'Petak',
    'Subota',
    'Nedjelja'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
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
          const Text('Novi plan',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text1)),
          const SizedBox(height: 16),

          // Naziv
          const Text('Naziv plana',
              style: TextStyle(fontSize: 12, color: AppColors.text2)),
          const SizedBox(height: 6),
          TextField(
            controller: _nameController,
            style: const TextStyle(color: AppColors.text1),
            decoration: const InputDecoration(
              hintText: 'npr. Push Day A',
            ),
          ),
          const SizedBox(height: 16),

          // Dan sedmice
          const Text('Dan sedmice',
              style: TextStyle(fontSize: 12, color: AppColors.text2)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: List.generate(7, (i) {
              final day = i + 1;
              final selected = _selectedDay == day;
              return GestureDetector(
                onTap: () => setState(() => _selectedDay = day),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.accent : AppColors.bg3,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? AppColors.accent : AppColors.border2,
                    ),
                  ),
                  child: Text(
                    _days[day].substring(0, 3),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: selected ? Colors.white : AppColors.text2,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),

          // Dugme
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _save,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Kreiraj plan'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _loading = true);
    await widget.ref
        .read(workoutPlanNotifierProvider.notifier)
        .create(name: _nameController.text.trim(), dayOfWeek: _selectedDay);
    if (mounted) Navigator.pop(context);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_month, size: 64, color: AppColors.text3),
          const SizedBox(height: 16),
          const Text('Nemas nijedan plan',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text2)),
          const SizedBox(height: 8),
          const Text('Kreiraj prvi workout plan',
              style: TextStyle(fontSize: 14, color: AppColors.text3)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Kreiraj plan'),
          ),
        ],
      ),
    );
  }
}
