import 'package:fit_forge/core/utils/one_rep_max.dart';
import 'package:fit_forge/data/models/workout_log_model.dart';
import 'package:fit_forge/data/models/workout_set_model.dart';
import 'package:flutter_test/flutter_test.dart';

WorkoutSetModel _set(int n, double weight, int reps, {bool done = true}) =>
    WorkoutSetModel(
      id: 's$n',
      logId: 'l',
      setNumber: n,
      plannedReps: reps,
      actualReps: reps,
      plannedWeight: weight,
      actualWeight: weight,
      isCompleted: done,
    );

void main() {
  test('Epley formula', () {
    expect(estimateOneRepMax(100, 10), closeTo(133.33, 0.01));
    expect(estimateOneRepMax(60, 5), 70);
  });

  test('a single rep is the weight itself', () {
    expect(estimateOneRepMax(140, 1), 140);
  });

  test('no weight or no reps gives no estimate', () {
    expect(estimateOneRepMax(0, 10), 0);
    expect(estimateOneRepMax(100, 0), 0);
  });

  test('best estimate of a log uses completed sets only', () {
    final log = WorkoutLogModel(
      id: 'l',
      exerciseId: 'e',
      logDate: DateTime(2026, 9, 25),
      totalVolume: 0,
      createdAt: DateTime(2026, 9, 25),
      sets: [
        _set(1, 100, 5), // 116.7
        _set(2, 90, 10), // 120
        _set(3, 120, 5, done: false), // 140, not completed
      ],
    );
    expect(bestOneRepMax(log), 120);
  });
}
