enum ProgressionAction { increase, hold, reduce, noData }

/// What a suggestion changes: weight for weighted exercises, reps for
/// bodyweight ones, seconds for timed ones.
enum ProgressionUnit { kg, reps, seconds }

class ProgressionSuggestion {
  final List<double> suggestedWeights;
  final List<int> suggestedReps;
  final ProgressionAction action;
  final ProgressionUnit unit;

  /// Amount added per set when [action] is [ProgressionAction.increase], in
  /// [unit].
  final double increment;

  const ProgressionSuggestion({
    required this.suggestedWeights,
    required this.suggestedReps,
    required this.action,
    this.unit = ProgressionUnit.kg,
    this.increment = 0,
  });

  bool get hasData => action != ProgressionAction.noData;

  bool get shouldIncrease => action == ProgressionAction.increase;

  static const noData = ProgressionSuggestion(
    suggestedWeights: [],
    suggestedReps: [],
    action: ProgressionAction.noData,
  );
}
