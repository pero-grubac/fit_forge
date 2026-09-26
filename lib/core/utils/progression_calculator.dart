import 'package:fit_forge/core/models/progression_suggestion.dart';
import 'package:fit_forge/data/models/default_set_model.dart';
import 'package:fit_forge/data/models/workout_log_model.dart';
import 'package:fit_forge/data/models/workout_set_model.dart';

class ProgressionCalculator {
  static const historyNeeded = 3;
  static const _holdMargin = 0.15; // below (threshold - margin) -> reduce
  static const _reduceFactor = 0.95;
  static const _heavyWeight = 100.0;

  final double smallIncrement;
  final double largeIncrement;

  /// Minimum average completion rate required to increase weight.
  final double threshold;

  const ProgressionCalculator({
    this.smallIncrement = 2.5,
    this.largeIncrement = 5.0,
    this.threshold = 0.95,
  });

  /// [logs] must be ordered newest first. [defaultSets] supply per-set
  /// increments configured on the exercise; when missing or zero, the
  /// small/large increments from settings are used.
  ProgressionSuggestion calculate(
    List<WorkoutLogModel> logs, {
    List<DefaultSetModel> defaultSets = const [],
  }) {
    if (logs.length < historyNeeded) return ProgressionSuggestion.noData;

    final recent = logs.take(historyNeeded).toList();
    if (recent.first.sets.isEmpty) return ProgressionSuggestion.noData;

    final avgRate =
        recent.map(completionRate).reduce((a, b) => a + b) / historyNeeded;

    final lastSets = recent.first.sets;
    final lastWeights = lastSets.map((s) => s.actualWeight).toList();
    final lastReps = lastSets.map((s) => s.plannedReps).toList();

    if (avgRate >= threshold) {
      final increments = [
        for (final s in lastSets) _incrementFor(s, defaultSets, lastWeights),
      ];
      return ProgressionSuggestion(
        suggestedWeights: [
          for (var i = 0; i < lastWeights.length; i++)
            lastWeights[i] + increments[i],
        ],
        suggestedReps: lastReps,
        action: ProgressionAction.increase,
        increment: increments.reduce((a, b) => a > b ? a : b),
      );
    }

    if (avgRate >= threshold - _holdMargin) {
      return ProgressionSuggestion(
        suggestedWeights: lastWeights,
        suggestedReps: lastReps,
        action: ProgressionAction.hold,
      );
    }

    return ProgressionSuggestion(
      suggestedWeights: [
        for (final s in lastSets)
          roundTo(s.actualWeight * _reduceFactor,
              _incrementFor(s, defaultSets, lastWeights)),
      ],
      suggestedReps: lastReps,
      action: ProgressionAction.reduce,
    );
  }

  /// Progression for exercises without external weight: changes the target
  /// reps (or seconds, for timed exercises) of every set by [step].
  ProgressionSuggestion calculateReps(
    List<WorkoutLogModel> logs, {
    required int step,
    ProgressionUnit unit = ProgressionUnit.reps,
  }) {
    if (logs.length < historyNeeded) return ProgressionSuggestion.noData;

    final recent = logs.take(historyNeeded).toList();
    if (recent.first.sets.isEmpty) return ProgressionSuggestion.noData;

    final avgRate =
        recent.map(completionRate).reduce((a, b) => a + b) / historyNeeded;

    final lastSets = recent.first.sets;
    final lastWeights = lastSets.map((s) => s.actualWeight).toList();
    final lastReps = lastSets.map((s) => s.plannedReps).toList();

    final ProgressionAction action;
    final int delta;
    if (avgRate >= threshold) {
      action = ProgressionAction.increase;
      delta = step;
    } else if (avgRate >= threshold - _holdMargin) {
      action = ProgressionAction.hold;
      delta = 0;
    } else {
      action = ProgressionAction.reduce;
      delta = -step;
    }

    return ProgressionSuggestion(
      suggestedWeights: lastWeights,
      suggestedReps: [for (final r in lastReps) _max(1, r + delta)],
      action: action,
      unit: unit,
      increment: action == ProgressionAction.increase ? step.toDouble() : 0,
    );
  }

  double _incrementFor(
    WorkoutSetModel set,
    List<DefaultSetModel> defaultSets,
    List<double> lastWeights,
  ) {
    for (final ds in defaultSets) {
      if (ds.setNumber == set.setNumber && ds.increment > 0) {
        return ds.increment;
      }
    }
    return lastWeights.any((w) => w >= _heavyWeight)
        ? largeIncrement
        : smallIncrement;
  }

  /// Share of planned reps actually done. A set only counts if it was marked
  /// completed at no less than the planned weight; extra reps on one set
  /// don't make up for missed reps on another.
  static double completionRate(WorkoutLogModel log) {
    final planned = log.sets.fold(0, (sum, s) => sum + s.plannedReps);
    if (planned == 0) return 0;
    final actual = log.sets
        .where((s) => s.isCompleted && s.actualWeight >= s.plannedWeight)
        .fold(0, (sum, s) => sum + _min(s.actualReps, s.plannedReps));
    return actual / planned;
  }

  /// Rounds [value] down to the nearest multiple of [step].
  static double roundTo(double value, double step) {
    if (step <= 0) return value;
    final rounded = (value / step).floor() * step;
    return double.parse(rounded.toStringAsFixed(2));
  }

  static int _min(int a, int b) => a < b ? a : b;

  static int _max(int a, int b) => a > b ? a : b;
}
