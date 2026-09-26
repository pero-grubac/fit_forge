import 'package:fit_forge/data/local/dao/exercise_dao.dart';
import 'package:fit_forge/data/local/dao/plan_exercise_dao.dart';
import 'package:fit_forge/data/local/dao/quote_dao.dart';
import 'package:fit_forge/data/local/dao/workout_log_dao.dart';
import 'package:fit_forge/data/local/dao/workout_plan_dao.dart';
import 'package:fit_forge/data/demo_data.dart';
import 'package:fit_forge/data/local/database_helper.dart';
import 'package:fit_forge/data/repositories/backup_repository.dart';
import 'package:fit_forge/data/repositories/exercise_repository.dart';
import 'package:fit_forge/data/repositories/plan_exercise_repository.dart';
import 'package:fit_forge/data/repositories/quote_repository.dart';
import 'package:fit_forge/data/repositories/workout_log_repository.dart';
import 'package:fit_forge/data/repositories/workout_plan_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Data layer wiring. Override [databaseHelperProvider] in tests to use a
/// different database.
final databaseHelperProvider =
    Provider<DatabaseHelper>((ref) => DatabaseHelper.instance);

final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  return ExerciseRepository(ExerciseDao(ref.watch(databaseHelperProvider)));
});

final planExerciseRepositoryProvider = Provider<PlanExerciseRepository>((ref) {
  return PlanExerciseRepository(
    PlanExerciseDao(ref.watch(databaseHelperProvider)),
    ref.watch(exerciseRepositoryProvider),
  );
});

final workoutPlanRepositoryProvider = Provider<WorkoutPlanRepository>((ref) {
  return WorkoutPlanRepository(
    WorkoutPlanDao(ref.watch(databaseHelperProvider)),
    ref.watch(exerciseRepositoryProvider),
  );
});

final workoutLogRepositoryProvider = Provider<WorkoutLogRepository>((ref) {
  return WorkoutLogRepository(WorkoutLogDao(ref.watch(databaseHelperProvider)));
});

final quoteRepositoryProvider = Provider<QuoteRepository>((ref) {
  return QuoteRepository(QuoteDao(ref.watch(databaseHelperProvider)));
});

final backupRepositoryProvider = Provider<BackupRepository>((ref) {
  return BackupRepository(ref.watch(databaseHelperProvider));
});

final demoDataProvider = Provider<DemoData>((ref) {
  return DemoData(
    helper: ref.watch(databaseHelperProvider),
    plans: ref.watch(workoutPlanRepositoryProvider),
    exercises: ref.watch(exerciseRepositoryProvider),
    planExercises: ref.watch(planExerciseRepositoryProvider),
    logs: ref.watch(workoutLogRepositoryProvider),
    quotes: ref.watch(quoteRepositoryProvider),
  );
});
