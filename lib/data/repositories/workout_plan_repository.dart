import 'package:fit_forge/data/local/dao/workout_plan_dao.dart';
import 'package:fit_forge/data/models/workout_plan_model.dart';
import 'package:uuid/uuid.dart';

class WorkoutPlanRepository {
  final _planDao = WorkoutPlanDao();

  Future<List<WorkoutPlanModel>> getAll() => _planDao.getAll();

  Future<WorkoutPlanModel?> getByDay(int dayOfWeek) =>
      _planDao.getByDay(dayOfWeek);

  Future<WorkoutPlanModel?> getById(String id) => _planDao.getById(id);

  Future<WorkoutPlanModel> create({
    required String name,
    required int dayOfWeek,
  }) async {
    final plan = WorkoutPlanModel(
      id: const Uuid().v4(),
      name: name,
      dayOfWeek: dayOfWeek,
      isActive: true,
      createdAt: DateTime.now(),
    );
    await _planDao.insert(plan);
    return plan;
  }

  Future<void> update(WorkoutPlanModel plan) => _planDao.update(plan);

  Future<void> delete(String id) => _planDao.delete(id);
}
