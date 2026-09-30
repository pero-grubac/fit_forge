import 'package:fit_forge/core/utils/set_progression.dart';
import 'package:flutter_test/flutter_test.dart';

PerformedSet ok(double level) => (level: level, success: true);
PerformedSet miss(double level) => (level: level, success: false);

void main() {
  const rule = SetProgression(setsToProgress: 8, increment: 2.5);

  /// Runs workouts of 3 sets, each done exactly as planned (all good), and
  /// returns what was planned for every workout.
  List<List<double>> simulate(int workouts, {double start = 10}) {
    final history = <Session>[];
    final planned = <List<double>>[];
    for (var i = 0; i < workouts; i++) {
      final status = rule.status(history, start: start, plannedSets: 3);
      final levels = rule.planSession(status, 3);
      planned.add(levels);
      history.add([for (final l in levels) ok(l)]);
    }
    return planned;
  }

  group('the example (+2.5 kg after 8 sets, 3 sets per workout)', () {
    test('weeks 1–5', () {
      expect(simulate(5), [
        [10, 10, 10],
        [10, 10, 10],
        [10, 10, 12.5], // the 9th set is heavier
        [10, 12.5, 12.5], // one more set at 12.5
        [12.5, 12.5, 12.5], // all at 12.5
      ]);
    });

    test('counting starts again with the first full workout at 12.5', () {
      final history = [
        for (final w in simulate(5)) [for (final l in w) ok(l)],
      ];
      final status = rule.status(history, start: 10, plannedSets: 3);
      expect(status.isMoving, isFalse);
      expect(status.counting, const ProgressionState(level: 12.5, streak: 3));
    });

    test('keeps going: the next increase comes 8 sets later', () {
      expect(simulate(10).sublist(5), [
        [12.5, 12.5, 12.5], // 6/8
        [12.5, 12.5, 15], // 8 done, the 9th is heavier
        [12.5, 15, 15],
        [15, 15, 15],
        [15, 15, 15],
      ]);
    });

    test('while moving up, the status says so', () {
      final history = [
        [ok(10), ok(10), ok(10)],
        [ok(10), ok(10), ok(10)],
        [ok(10), ok(10), ok(12.5)],
      ];
      final status = rule.status(history, start: 10, plannedSets: 3);
      expect(status.transition,
          const Transition(from: 10, to: 12.5, heavySets: 2));
    });
  });

  group('counting', () {
    test('a missed set resets the counter', () {
      final status = rule.status([
        [ok(10), ok(10), ok(10)],
        [ok(10), miss(10), ok(10)],
      ], start: 10, plannedSets: 3);
      // Only the set after the miss counts.
      expect(status.counting, const ProgressionState(level: 10, streak: 1));
    });

    test('a lower weight resets and counts at that weight', () {
      final status = rule.status([
        [ok(10), ok(10), ok(10)],
        [ok(8), ok(8), ok(8)],
      ], start: 10, plannedSets: 3);
      expect(status.counting, const ProgressionState(level: 8, streak: 3));
    });

    test('a whole workout raised by hand starts counting at that weight', () {
      final status = rule.status([
        [ok(10), ok(10), ok(10)],
        [ok(12.5), ok(12.5), ok(12.5)],
      ], start: 10, plannedSets: 3);
      expect(status.counting, const ProgressionState(level: 12.5, streak: 3));
    });

    test('raising only the last set by hand moves up gradually', () {
      final status = rule.status([
        [ok(10), ok(10), ok(12.5)],
      ], start: 10, plannedSets: 3);
      expect(rule.planSession(status, 3), [10, 12.5, 12.5]);
    });

    test('no history starts at the plan weight', () {
      final status = rule.status([], start: 20, plannedSets: 3);
      expect(rule.planSession(status, 3), [20, 20, 20]);
    });

    test('skipped workouts (nothing ticked) are ignored', () {
      final status = rule.status([
        [ok(10), ok(10), ok(10)],
        [],
      ], start: 10, plannedSets: 3);
      expect(status.counting.streak, 3);
    });
  });

  group('a missed set at the new weight holds the move up', () {
    final weeks1to3 = <Session>[
      [ok(10), ok(10), ok(10)],
      [ok(10), ok(10), ok(10)],
    ];

    List<double> next(List<Session> history) =>
        rule.planSession(rule.status(history, start: 10, plannedSets: 3), 3);

    test('the example: miss in week 4 repeats it, clean week 5 moves on', () {
      final history = [
        ...weeks1to3,
        [ok(10), ok(10), ok(12.5)], // week 3
        [ok(10), ok(12.5), miss(12.5)], // week 4: set 3 missed
      ];
      expect(next(history), [10, 12.5, 12.5]); // week 5 repeats

      history.add([ok(10), ok(12.5), ok(12.5)]); // week 5 clean
      expect(next(history), [12.5, 12.5, 12.5]); // week 6

      history.add([ok(12.5), ok(12.5), ok(12.5)]);
      final status = rule.status(history, start: 10, plannedSets: 3);
      expect(status.counting, const ProgressionState(level: 12.5, streak: 3));
    });

    test('a miss on the first heavy set repeats 10 · 10 · 12.5', () {
      expect(
          next([
            ...weeks1to3,
            [ok(10), ok(10), miss(12.5)],
          ]),
          [10, 10, 12.5]);
    });

    test('choosing 10 · 12.5 · 12.5 again keeps offering the full switch', () {
      final history = [
        ...weeks1to3,
        [ok(10), ok(10), ok(12.5)],
        [ok(10), ok(12.5), ok(12.5)], // offered 12.5 × 3 next ...
        [ok(10), ok(12.5), ok(12.5)], // ... but did this again
        [ok(10), ok(12.5), ok(12.5)], // ... and again
      ];
      final status = rule.status(history, start: 10, plannedSets: 3);
      expect(rule.planSession(status, 3), [12.5, 12.5, 12.5]);
      // No counting yet: that starts with a full workout at 12.5.
      expect(status.counting.streak, 0);
    });

    test('a miss on a light set does not hold it', () {
      expect(
          next([
            ...weeks1to3,
            [miss(10), ok(10), ok(12.5)],
          ]),
          [10, 12.5, 12.5]);
    });
  });

  test('works for reps too (bodyweight: +1 rep, 3 sets to go up)', () {
    // With "3 sets to go up" and 3 sets per workout, a full workout at the
    // new level already reaches the count.
    const reps = SetProgression(setsToProgress: 3, increment: 1);
    final history = <Session>[];
    final planned = <List<double>>[];
    for (var i = 0; i < 4; i++) {
      final levels =
          reps.planSession(reps.status(history, start: 8, plannedSets: 3), 3);
      planned.add(levels);
      history.add([for (final l in levels) ok(l)]);
    }
    expect(planned, [
      [8, 8, 8],
      [9, 9, 9], // 3 good sets done: the whole next workout is up
      [10, 10, 10],
      [11, 11, 11],
    ]);
  });
}
