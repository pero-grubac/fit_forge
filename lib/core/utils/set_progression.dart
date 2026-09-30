import 'package:fit_forge/data/models/workout_log_model.dart';

/// What progression changes: weight for weighted exercises, reps for
/// bodyweight ones, seconds for timed ones.
enum ProgressionUnit { kg, reps, seconds }

/// A performed set, reduced to what the progression rule needs.
///
/// [level] is the weight for weighted exercises, or the target reps/seconds
/// for bodyweight and timed ones. [success] means all planned reps were done.
typedef PerformedSet = ({double level, bool success});

/// The sets done in one workout (skipped sets left out), in order.
typedef Session = List<PerformedSet>;

/// The counter: [streak] consecutive successful sets at [level].
class ProgressionState {
  const ProgressionState({required this.level, required this.streak});

  final double level;
  final int streak;

  @override
  bool operator ==(Object other) =>
      other is ProgressionState &&
      _same(other.level, level) &&
      other.streak == streak;

  @override
  int get hashCode => Object.hash(level.toStringAsFixed(3), streak);

  @override
  String toString() => 'ProgressionState($level × $streak)';
}

/// Moving up to a new level one set per workout: the next workout does
/// [heavySets] sets at [to] (the last ones) and the rest at [from].
class Transition {
  const Transition({
    required this.from,
    required this.to,
    required this.heavySets,
  });

  final double from;
  final double to;
  final int heavySets;

  @override
  bool operator ==(Object other) =>
      other is Transition &&
      _same(other.from, from) &&
      _same(other.to, to) &&
      other.heavySets == heavySets;

  @override
  int get hashCode =>
      Object.hash(from.toStringAsFixed(3), to.toStringAsFixed(3), heavySets);

  @override
  String toString() => 'Transition($from → $to, $heavySets heavy)';
}

/// Where progression stands before the next workout: either moving up
/// ([transition]) or counting good sets ([counting]).
class ProgressionStatus {
  const ProgressionStatus.counting(this.counting) : transition = null;

  const ProgressionStatus.moving(Transition this.transition, this.counting);

  final ProgressionState counting;
  final Transition? transition;

  bool get isMoving => transition != null;

  @override
  String toString() => transition?.toString() ?? counting.toString();
}

/// Set-count progression.
///
/// Counting: after [setsToProgress] consecutive successful sets at the same
/// level, the next set goes up by [increment]; the rest of that workout
/// stays up. A missed set, or a set at a different level, resets the count.
///
/// Moving up: after an increase, each following workout does one more set at
/// the new level (heaviest sets last) until the whole workout is at it:
/// `10·10·12.5 → 10·12.5·12.5 → 12.5·12.5·12.5`. Only then does counting
/// start again, with that workout's sets. A missed set at the new level
/// repeats that workout's split until the heavy sets are clean.
class SetProgression {
  const SetProgression({required this.setsToProgress, required this.increment});

  final int setsToProgress;
  final double increment;

  // ── Counting ──────────────────────────────────────────────────────────

  /// Applies one performed set to the counter.
  ProgressionState apply(ProgressionState state, PerformedSet set) {
    if (!_same(set.level, state.level)) {
      return ProgressionState(level: set.level, streak: set.success ? 1 : 0);
    }
    return ProgressionState(
      level: state.level,
      streak: set.success ? state.streak + 1 : 0,
    );
  }

  /// Applies [sets] in the order they were done.
  ProgressionState replay(
          ProgressionState start, Iterable<PerformedSet> sets) =>
      sets.fold(start, apply);

  /// The level the next set should use.
  double nextLevel(ProgressionState state) =>
      state.streak >= setsToProgress ? state.level + increment : state.level;

  /// Levels for the next [count] sets while counting, assuming each one
  /// succeeds: once the count is reached, the remaining sets go up.
  List<double> plan(ProgressionState state, int count) {
    final levels = <double>[];
    var s = state;
    for (var i = 0; i < count; i++) {
      final level = nextLevel(s);
      levels.add(level);
      s = apply(s, (level: level, success: true));
    }
    return levels;
  }

  /// Successful sets still needed at the current level before it goes up.
  int setsLeft(ProgressionState state) =>
      (setsToProgress - state.streak).clamp(0, setsToProgress);

  // ── Whole workouts ───────────────────────────────────────────────────

  /// Status after [sessions] (oldest first). [start] is the level when there
  /// is no history; [plannedSets] is how many sets a workout has.
  ProgressionStatus status(
    List<Session> sessions, {
    required double start,
    required int plannedSets,
  }) {
    final done = [
      for (final s in sessions)
        if (s.isNotEmpty) s
    ];
    if (done.isEmpty) {
      return ProgressionStatus.counting(
          ProgressionState(level: start, streak: 0));
    }

    final last = done.last;
    final top = last.last.level;
    final heavy = _trailingAt(last, top);
    final before = last.sublist(0, last.length - heavy);

    // Lighter sets first, heavier ones last: moving up. One more heavy set
    // only once all heavy sets of the last workout were clean; otherwise the
    // same split is repeated.
    if (before.isNotEmpty && before.every((s) => s.level < top - 1e-6)) {
      final clean = last.sublist(before.length).every((s) => s.success);
      final next = clean ? heavy + 1 : heavy;
      final counting = ProgressionState(level: top, streak: 0);
      if (next >= plannedSets) return ProgressionStatus.counting(counting);
      return ProgressionStatus.moving(
        Transition(from: before.last.level, to: top, heavySets: next),
        counting,
      );
    }

    // Counting: good sets in a row at [top]. Earlier workouts only count
    // when done entirely at that level (not the ones moving up to it).
    var streak = 0;
    for (final (i, session) in done.reversed.indexed) {
      final isLatest = i == 0;
      if (!isLatest && !session.every((s) => _same(s.level, top))) break;
      for (final set in session.reversed) {
        if (!_same(set.level, top) || !set.success) {
          return ProgressionStatus.counting(
              ProgressionState(level: top, streak: streak));
        }
        streak++;
      }
    }
    return ProgressionStatus.counting(
        ProgressionState(level: top, streak: streak));
  }

  /// Levels for a workout of [count] sets.
  List<double> planSession(ProgressionStatus status, int count) {
    final t = status.transition;
    if (t == null) return plan(status.counting, count);
    final heavy = t.heavySets.clamp(0, count);
    return [
      for (var i = 0; i < count; i++) i < count - heavy ? t.from : t.to,
    ];
  }

  /// Converts logged workouts (oldest first) into sessions. Sets that
  /// weren't ticked as done are skipped. [byReps] uses the planned reps as
  /// the level (bodyweight/timed); otherwise the actual weight.
  static List<Session> sessionsFromLogs(
    Iterable<WorkoutLogModel> logsOldestFirst, {
    required bool byReps,
  }) =>
      [
        for (final log in logsOldestFirst)
          [
            for (final s in [
              ...log.sets
            ]..sort((a, b) => a.setNumber.compareTo(b.setNumber)))
              if (s.isCompleted)
                (
                  level: byReps ? s.plannedReps.toDouble() : s.actualWeight,
                  success: s.actualReps >= s.plannedReps,
                ),
          ],
      ];

  static int _trailingAt(Session session, double level) {
    var n = 0;
    for (final set in session.reversed) {
      if (!_same(set.level, level)) break;
      n++;
    }
    return n;
  }
}

bool _same(double a, double b) => (a - b).abs() < 1e-6;
