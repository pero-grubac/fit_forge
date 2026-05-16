import 'package:fit_forge/core/models/progression_suggestion.dart';
import 'package:fit_forge/data/models/workout_log_model.dart';
import 'package:fit_forge/features/workout_log/providers/workout_log_provider.dart';

class ProgressionCalculator {
  static const _historyNeeded = 3;
  static const _highThreshold = 0.95; // >= 95% -> povecaj
  static const _lowThreshold  = 0.80; // <  80% -> smanji
  static const _heavyWeight   = 100.0;

  final double smallIncrement;
  final double largeIncrement;

  const ProgressionCalculator({
    this.smallIncrement = 2.5,
    this.largeIncrement = 5.0,
  });

  ProgressionSuggestion calculate(List<WorkoutLogModel> logs) {
    if (logs.length < _historyNeeded) return ProgressionSuggestion.noData;

    final recent  = logs.take(_historyNeeded).toList();
    final avgRate = recent.map(_completionRate).reduce((a, b) => a + b) / _historyNeeded;

    final lastWeights = recent.first.sets.map((s) => s.actualWeight).toList();
    final lastReps    = recent.first.sets.map((s) => s.plannedReps).toList();

    if (avgRate >= _highThreshold) {
      final inc = lastWeights.any((w) => w >= _heavyWeight)
          ? largeIncrement
          : smallIncrement;
      return ProgressionSuggestion(
        suggestedWeights: lastWeights.map((w) => w + inc).toList(),
        suggestedReps:    lastReps,
        confidence:       'High',
        reason:           'Odlicno! Povecavamo za $inc kg',
      );
    }

    if (avgRate >= _lowThreshold) {
      return ProgressionSuggestion(
        suggestedWeights: lastWeights,
        suggestedReps:    lastReps,
        confidence:       'Hold',
        reason:           'Zadrzi tezinu — skoro si spreman',
      );
    }

    return ProgressionSuggestion(
      suggestedWeights: lastWeights.map((w) => (w * 0.95)).toList(),
      suggestedReps:    lastReps,
      confidence:       'Reduce',
      reason:           'Fokusiraj se na tehniku, smanjujemo malo',
    );
  }

  static double _completionRate(WorkoutLogModel log) {
    if (log.sets.isEmpty) return 0;
    final planned = log.sets.fold(0, (sum, s) => sum + s.plannedReps);
    final actual  = log.sets.fold(0, (sum, s) => sum + s.actualReps);
    return planned == 0 ? 0 : actual / planned;
  }
}