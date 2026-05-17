import 'package:fit_forge/data/repositories/workout_log_repository.dart';
import 'package:fit_forge/features/workout_plan/widgets/exercise_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/progression_suggestion.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/exercise_model.dart';
import '../../../data/repositories/exercise_repository.dart';
import '../providers/progression_provider.dart';
import '../providers/workout_log_provider.dart';

class LogSessionPage extends ConsumerStatefulWidget {
  const LogSessionPage({required this.exerciseId, super.key});

  final String exerciseId;

  @override
  ConsumerState<LogSessionPage> createState() => _LogSessionPageState();
}

class _LogSessionPageState extends ConsumerState<LogSessionPage> {
  ExerciseModel? _exercise;
  bool _loadingExercise = true;
  final _notesCtrl = TextEditingController();
  final _sets = <_SetRow>[];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadExercise();
  }

  Future<void> _loadExercise() async {
    final ex = await ExerciseRepository().getById(widget.exerciseId);
    if (!mounted) return;
    setState(() {
      _exercise = ex;
      _loadingExercise = false;
    });
    if (_sets.isEmpty) {
      await _loadLastLog();
    }
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    for (final s in _sets) {
      s.weightCtrl.dispose();
      s.repsCtrl.dispose();
    }
    super.dispose();
  }

  void _initSetsFromSuggestion(ProgressionSuggestion suggestion) {
    if (_sets.isNotEmpty) return;
    if (!suggestion.hasData) return; // _loadExercise vec ucitao setove

    // Ima progression data — override sa prijedlogom
    setState(() {
      _sets.clear();
      for (int i = 0; i < suggestion.suggestedWeights.length; i++) {
        _sets.add(_SetRow(
          setNumber: i + 1,
          plannedWeight: suggestion.suggestedWeights[i],
          plannedReps: suggestion.suggestedReps[i],
        ));
      }
    });
  }

  Future<void> _loadLastLog() async {
    final logs =
        await WorkoutLogRepository().getByExercise(widget.exerciseId, limit: 1);

    if (!mounted) return;

    if (logs.isNotEmpty && logs.first.sets.isNotEmpty) {
      final lastSets = logs.first.sets;
      setState(() {
        _sets.clear();
        for (final s in lastSets) {
          _sets.add(_SetRow(
            setNumber: s.setNumber,
            plannedWeight: s.actualWeight,
            plannedReps: s.actualReps, // stvarni repovi, ne planirani
            isDone: s.isCompleted, // postavi checkmark
          ));
        }
      });
    } else if (_exercise != null && _exercise!.defaultSets.isNotEmpty) {
      setState(() {
        for (int i = 0; i < _exercise!.defaultSets.length; i++) {
          final ds = _exercise!.defaultSets[i];
          _sets.add(_SetRow(
            setNumber: i + 1,
            plannedWeight: ds.weight,
            plannedReps: ds.reps,
            isDone: false,
          ));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingExercise) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final suggestion = ref.watch(progressionProvider(widget.exerciseId));

    suggestion.whenData((s) => _initSetsFromSuggestion(s));

    return Scaffold(
      appBar: AppBar(
        title: Text(_exercise?.name ?? 'Trening'),
        backgroundColor: AppColors.bg,
        actions: [
          if (_exercise?.youTubeUrl != null)
            IconButton(
              icon: const Icon(Icons.play_circle_outline, color: AppColors.red),
              onPressed: () {
                /* otvori YouTube */
              },
            ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Chip za misicnu grupu
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  // Slika vjezbe
                  if (_exercise != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: ExerciseImageWidget(
                          exercise: _exercise!,
                          height:   130,
                          editable: false,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Progression banner
          SliverToBoxAdapter(
            child: suggestion.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (s) => s.hasData
                  ? _ProgressionBanner(suggestion: s)
                  : const SizedBox.shrink(),
            ),
          ),

          // Tabela setova
          SliverToBoxAdapter(
            child: _SetsTable(
              sets: _sets,
              onToggle: (i) =>
                  setState(() => _sets[i].isDone = !_sets[i].isDone),
            ),
          ),

          // Dodaj set dugme
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: OutlinedButton.icon(
                onPressed: _addSet,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Dodaj set'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accent,
                  side: const BorderSide(color: AppColors.accent),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),

          // Biljeska
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Bilješka (opciono)',
                      style: TextStyle(fontSize: 12, color: AppColors.text2)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _notesCtrl,
                    maxLines: 2,
                    style: const TextStyle(color: AppColors.text1),
                    decoration: const InputDecoration(
                      hintText: 'Npr. dobra pumpa, povecaj sljedeci put...',
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Volume info
          if (_sets.any((s) => s.isDone))
            SliverToBoxAdapter(
              child: _VolumeInfo(sets: _sets),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),

      // Save FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saving ? null : _save,
        backgroundColor:
            _sets.any((s) => s.isDone) ? AppColors.accent : AppColors.bg4,
        icon: _saving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : const Icon(Icons.save_rounded, color: Colors.white),
        label: const Text('Spremi trening',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _addSet() {
    final last = _sets.isNotEmpty ? _sets.last : null;
    setState(() {
      _sets.add(_SetRow(
        setNumber: _sets.length + 1,
        plannedWeight: last?.actualWeight ?? 0,
        plannedReps: last?.plannedReps ?? 10,
      ));
    });
  }

  Future<void> _save() async {
    final doneSets = _sets.where((s) => s.isDone).toList();
    if (doneSets.isEmpty) return;

    setState(() => _saving = true);

    final exerciseIds = [widget.exerciseId];

    await ref.read(workoutLogNotifierProvider.notifier).logWorkout(
          exerciseId: widget.exerciseId,
          logDate: DateTime.now(),
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          sets: _sets
              .map((s) => (
                    plannedReps: s.plannedReps,
                    actualReps: s.actualReps,
                    plannedWeight: s.plannedWeight,
                    actualWeight: s.actualWeight,
                    isCompleted: s.isDone,
                  ))
              .toList(),
        );

    // Invalidaj completed sets provider
    ref.invalidate(completedSetsTodayProvider(widget.exerciseId));
    if (mounted) Navigator.pop(context);
  }
}

// ── Pomocne klase ──────────────────────────────────────────────────────────────

class _SetRow {
  final int setNumber;
  final double plannedWeight;
  final int plannedReps;
  bool isDone;
  late final TextEditingController weightCtrl;
  late final TextEditingController repsCtrl;

  _SetRow({
    required this.setNumber,
    required this.plannedWeight,
    required this.plannedReps,
    this.isDone = false,
  }) {
    weightCtrl = TextEditingController(text: plannedWeight.toString());
    repsCtrl = TextEditingController(text: plannedReps.toString());
  }

  double get actualWeight => double.tryParse(weightCtrl.text) ?? plannedWeight;

  int get actualReps => int.tryParse(repsCtrl.text) ?? plannedReps;
}

// ── Widgets ────────────────────────────────────────────────────────────────────

class _ProgressionBanner extends StatelessWidget {
  const _ProgressionBanner({required this.suggestion});

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
                Text('Prijedlog progresije',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color)),
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

class _SetsTable extends StatelessWidget {
  const _SetsTable({required this.sets, required this.onToggle});

  final List<_SetRow> sets;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: const [
                SizedBox(width: 30),
                Expanded(
                    child: Text('Tezina (kg)',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 11, color: AppColors.text3))),
                Expanded(
                    child: Text('Repovi',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 11, color: AppColors.text3))),
                SizedBox(width: 36),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Setovi
          ...sets.asMap().entries.map((e) {
            final i = e.key;
            final set = e.value;
            return _SetRowWidget(
              set: set,
              onToggle: () => onToggle(i),
              isLast: i == sets.length - 1,
            );
          }),
        ],
      ),
    );
  }
}

class _SetRowWidget extends StatelessWidget {
  const _SetRowWidget({
    required this.set,
    required this.onToggle,
    required this.isLast,
  });

  final _SetRow set;
  final VoidCallback onToggle;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            children: [
              // Broj seta
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: set.isDone
                      ? AppColors.green.withOpacity(0.15)
                      : AppColors.bg4,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text('${set.setNumber}',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color:
                              set.isDone ? AppColors.green : AppColors.text2)),
                ),
              ),
              const SizedBox(width: 8),

              // Tezina
              Expanded(
                child: TextField(
                  controller: set.weightCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.text1, fontSize: 14),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    fillColor: AppColors.bg3,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9),
                      borderSide: const BorderSide(color: AppColors.border2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9),
                      borderSide: const BorderSide(color: AppColors.border2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Repovi
              Expanded(
                child: TextField(
                  controller: set.repsCtrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.text1, fontSize: 14),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    fillColor: AppColors.bg3,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9),
                      borderSide: const BorderSide(color: AppColors.border2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(9),
                      borderSide: const BorderSide(color: AppColors.border2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Check dugme
              GestureDetector(
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: set.isDone
                        ? AppColors.green.withOpacity(0.15)
                        : AppColors.bg3,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: set.isDone ? AppColors.green : AppColors.border2,
                      width: 1.5,
                    ),
                  ),
                  child: set.isDone
                      ? const Icon(Icons.check_rounded,
                          size: 18, color: AppColors.green)
                      : null,
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, color: AppColors.border),
      ],
    );
  }
}

class _VolumeInfo extends StatelessWidget {
  const _VolumeInfo({required this.sets});

  final List<_SetRow> sets;

  @override
  Widget build(BuildContext context) {
    final doneSets = sets.where((s) => s.isDone).toList();
    final volume =
        doneSets.fold(0.0, (sum, s) => sum + s.actualWeight * s.actualReps);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Ukupni volumen',
              style: TextStyle(fontSize: 13, color: AppColors.text2)),
          Text('${volume.toStringAsFixed(1)} kg',
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text1)),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w500, color: color)),
    );
  }
}
