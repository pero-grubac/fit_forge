import 'package:fit_forge/core/models/progression_suggestion.dart';
import 'package:fit_forge/features/workout_log/providers/workout_log_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final progressionProvider =
    FutureProvider.family<ProgressionSuggestion, String>(
        (ref, exerciseId) async {
  final logs = await ref.watch(exerciseLogsProvider(exerciseId).future);
  const calculator = ProgressionCalculator();
  return calculator.calculate(logs);
});
