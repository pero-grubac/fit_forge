import 'package:fit_forge/data/models/plan_reschedule_model.dart';

/// Midnight of [t]'s day.
DateTime dayOf(DateTime t) => DateTime(t.year, t.month, t.day);

/// [n] calendar days after [day] (safe across daylight saving changes).
DateTime addDays(DateTime day, int n) =>
    DateTime(day.year, day.month, day.day + n);

bool sameDay(DateTime a, DateTime b) => dayKey(a) == dayKey(b);

/// One workout of a plan: the one for its regular day [regularDate], done
/// on [dueDate] (the same day unless it was moved).
class PlanOccurrence {
  const PlanOccurrence({
    required this.planId,
    required this.regularDate,
    required this.dueDate,
  });

  final String planId;
  final DateTime regularDate;
  final DateTime dueDate;

  bool get isMoved => !sameDay(regularDate, dueDate);
}

/// Which plan's workout is due on which day: each plan on its weekday,
/// except the workouts moved to another day.
class PlanSchedule {
  PlanSchedule({
    required Map<String, int> weekdays,
    required Iterable<PlanRescheduleModel> moves,
  })  : _weekdays = weekdays,
        _moves = {
          for (final m in moves)
            if (weekdays.containsKey(m.planId))
              (m.planId, dayKey(m.fromDate)): dayOf(m.toDate),
        };

  /// Plan id -> weekday (1 = Monday .. 7 = Sunday).
  final Map<String, int> _weekdays;

  /// (plan id, regular day) -> the day it was moved to.
  final Map<(String, String), DateTime> _moves;

  /// A workout moves at most this many days either way: never onto or past
  /// the same plan's previous or next regular day.
  static const reach = 6;

  /// Plans whose regular day is [weekday].
  Iterable<String> plansOn(int weekday) => [
        for (final MapEntry(key: id, value: w) in _weekdays.entries)
          if (w == weekday) id,
      ];

  DateTime dueDate(String planId, DateTime regularDate) =>
      _moves[(planId, dayKey(regularDate))] ?? dayOf(regularDate);

  PlanOccurrence occurrence(String planId, DateTime regularDate) =>
      PlanOccurrence(
        planId: planId,
        regularDate: dayOf(regularDate),
        dueDate: dueDate(planId, regularDate),
      );

  /// The workouts to do on [day]: its regular ones that weren't moved away,
  /// then the ones moved onto it.
  List<PlanOccurrence> dueOn(DateTime day) {
    final d = dayOf(day);
    return [
      for (final id in plansOn(d.weekday))
        if (sameDay(dueDate(id, d), d))
          PlanOccurrence(planId: id, regularDate: d, dueDate: d),
      for (final MapEntry(key: (id, from), value: to) in _moves.entries)
        if (sameDay(to, d))
          PlanOccurrence(planId: id, regularDate: DateTime.parse(from), dueDate: to),
    ];
  }

  /// Regular workouts of [day] that were moved to another day.
  List<PlanOccurrence> movedAwayFrom(DateTime day) => [
        for (final id in plansOn(day.weekday))
          if (!sameDay(dueDate(id, day), day)) occurrence(id, day),
      ];

  /// Days [o] can be moved to, earliest first: today or later (never the
  /// past), within [reach] days of its regular day, skipping the day it's on
  /// now and days the same plan already has a workout. Empty once its day
  /// has passed.
  List<DateTime> targetDays(PlanOccurrence o, DateTime today) {
    final t = dayOf(today);
    if (o.dueDate.isBefore(t)) return const [];
    return [
      for (var i = -reach; i <= reach; i++)
        if (addDays(o.regularDate, i) case final d
            when !d.isBefore(t) &&
                !sameDay(d, o.dueDate) &&
                !dueOn(d).any((x) =>
                    x.planId == o.planId && !sameDay(x.regularDate, o.regularDate)))
          d,
    ];
  }

  /// Workouts due after [today], soonest first: everything in the next
  /// [reach] days, plus moved workouts further ahead.
  List<PlanOccurrence> upcoming(DateTime today) {
    final t = dayOf(today);
    final horizon = addDays(t, reach);
    return [
      for (var i = 1; i <= reach; i++) ...dueOn(addDays(t, i)),
      for (final MapEntry(key: (id, from), value: to) in _moves.entries)
        if (to.isAfter(horizon))
          PlanOccurrence(planId: id, regularDate: DateTime.parse(from), dueDate: to),
    ]..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }
}
