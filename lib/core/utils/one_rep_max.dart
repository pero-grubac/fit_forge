import 'package:fit_forge/data/models/workout_log_model.dart';

/// Estimated one-rep max using the Epley formula: `w × (1 + reps / 30)`.
/// A single rep is the weight itself.
double estimateOneRepMax(double weight, int reps) {
  if (weight <= 0 || reps <= 0) return 0;
  if (reps == 1) return weight;
  return weight * (1 + reps / 30);
}

/// Best estimated one-rep max among the completed sets of [log].
double bestOneRepMax(WorkoutLogModel log) => log.sets
    .where((s) => s.isCompleted)
    .map((s) => estimateOneRepMax(s.actualWeight, s.actualReps))
    .fold(0.0, (max, v) => v > max ? v : max);
