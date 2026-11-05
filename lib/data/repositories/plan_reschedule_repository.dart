import 'package:fit_forge/data/local/dao/plan_reschedule_dao.dart';
import 'package:fit_forge/data/models/plan_reschedule_model.dart';

class PlanRescheduleRepository {
  PlanRescheduleRepository(this._dao);

  final PlanRescheduleDao _dao;

  Future<List<PlanRescheduleModel>> getAll() => _dao.getAll();

  /// Schedules the plan's workout from [regularDate] on [to]; moving it back
  /// to its regular day removes the move.
  Future<void> move(String planId, DateTime regularDate, DateTime to) =>
      dayKey(to) == dayKey(regularDate)
          ? _dao.delete(planId, regularDate)
          : _dao.upsert(planId, regularDate, to);

  /// Drops every move of the plan, e.g. when its weekday changes.
  Future<void> clearForPlan(String planId) => _dao.deleteForPlan(planId);
}
