import 'package:fit_forge/core/models/progression_suggestion.dart';
import 'package:fit_forge/core/utils/progression_calculator.dart';
import 'package:fit_forge/data/models/default_set_model.dart';
import 'package:fit_forge/data/models/workout_log_model.dart';
import 'package:fit_forge/data/models/workout_set_model.dart';
import 'package:flutter_test/flutter_test.dart';

WorkoutSetModel _set(
  int n, {
  double weight = 50,
  double? actualWeight,
  int reps = 10,
  int? actualReps,
  bool done = true,
}) =>
    WorkoutSetModel(
      id: 's$n',
      logId: 'l',
      setNumber: n,
      plannedReps: reps,
      actualReps: actualReps ?? reps,
      plannedWeight: weight,
      actualWeight: actualWeight ?? weight,
      isCompleted: done,
    );

WorkoutLogModel _log(List<WorkoutSetModel> sets) => WorkoutLogModel(
      id: 'l',
      exerciseId: 'e',
      logDate: DateTime(2026, 1, 1),
      totalVolume: 0,
      createdAt: DateTime(2026, 1, 1),
      sets: sets,
    );

List<WorkoutLogModel> _history(List<WorkoutSetModel> sets) =>
    List.generate(3, (_) => _log(sets));

void main() {
  const calc = ProgressionCalculator();

  test('no data with fewer than 3 logs', () {
    final s = calc.calculate([
      _log([_set(1)]),
      _log([_set(1)])
    ]);
    expect(s.action, ProgressionAction.noData);
  });

  test('increases by small increment when all sets are completed', () {
    final s = calc.calculate(_history([_set(1), _set(2), _set(3)]));
    expect(s.action, ProgressionAction.increase);
    expect(s.suggestedWeights, [52.5, 52.5, 52.5]);
    expect(s.increment, 2.5);
  });

  test('uses large increment at 100 kg or more', () {
    final s = calc.calculate(_history([_set(1, weight: 100)]));
    expect(s.suggestedWeights, [105]);
  });

  test('uses settings passed in', () {
    const custom = ProgressionCalculator(smallIncrement: 1.25, threshold: 0.8);
    // 9 of 10 reps = 90%, above the custom 80% threshold.
    final s = custom.calculate(_history([_set(1, actualReps: 9)]));
    expect(s.action, ProgressionAction.increase);
    expect(s.suggestedWeights, [51.25]);
  });

  test('per-set increment from default sets wins over settings', () {
    const ds = DefaultSetModel(
        id: 'd',
        planExerciseId: 'pe',
        setNumber: 1,
        reps: 10,
        weight: 50,
        increment: 1);
    final s = calc.calculate(_history([_set(1), _set(2)]), defaultSets: [ds]);
    expect(s.suggestedWeights, [51, 52.5]);
  });

  test('uncompleted sets do not count', () {
    final s = calc.calculate(_history([_set(1), _set(2, done: false)]));
    expect(s.action, ProgressionAction.reduce);
  });

  test('sets done below planned weight do not count', () {
    final s = calc.calculate(_history([_set(1, actualWeight: 45)]));
    expect(s.action, ProgressionAction.reduce);
  });

  test('extra reps do not compensate for missed reps', () {
    final s = calc
        .calculate(_history([_set(1, actualReps: 15), _set(2, actualReps: 5)]));
    expect(
        ProgressionCalculator.completionRate(_log([
          _set(1, actualReps: 15),
          _set(2, actualReps: 5),
        ])),
        0.75);
    expect(s.action, ProgressionAction.reduce);
  });

  test('holds between reduce and increase thresholds', () {
    final s = calc.calculate(_history([_set(1, actualReps: 9)]));
    expect(s.action, ProgressionAction.hold);
    expect(s.suggestedWeights, [50]);
  });

  test('reduced weights are rounded down to the increment', () {
    final s = calc.calculate(_history([_set(1, weight: 45, actualReps: 5)]));
    expect(s.action, ProgressionAction.reduce);
    // 45 * 0.95 = 42.75 -> 42.5
    expect(s.suggestedWeights, [42.5]);
  });

  group('rep progression (bodyweight / timed)', () {
    test('adds reps when all sets are completed, weights unchanged', () {
      final s = calc.calculateReps(
          _history([_set(1, weight: 0), _set(2, weight: 0)]),
          step: 1);
      expect(s.action, ProgressionAction.increase);
      expect(s.unit, ProgressionUnit.reps);
      expect(s.suggestedReps, [11, 11]);
      expect(s.suggestedWeights, [0, 0]);
      expect(s.increment, 1);
    });

    test('timed exercises add seconds', () {
      final s = calc.calculateReps(_history([_set(1, weight: 0, reps: 30)]),
          step: 5, unit: ProgressionUnit.seconds);
      expect(s.unit, ProgressionUnit.seconds);
      expect(s.suggestedReps, [35]);
    });

    test('holds reps between thresholds', () {
      final s = calc.calculateReps(
          _history([_set(1, weight: 0, actualReps: 9)]),
          step: 1);
      expect(s.action, ProgressionAction.hold);
      expect(s.suggestedReps, [10]);
    });

    test('reduces reps but never below one', () {
      final s = calc.calculateReps(
          _history([_set(1, weight: 0, reps: 1, actualReps: 0)]),
          step: 1);
      expect(s.action, ProgressionAction.reduce);
      expect(s.suggestedReps, [1]);
    });
  });
}
