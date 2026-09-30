import 'package:fit_forge/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// A global exercise, shared by every plan that includes it.
class ExerciseModel {
  final String id;
  final String name;
  final String muscleGroup;
  final String? description;
  final String? imagePath;
  final String? youTubeUrl;
  final DateTime createdAt;
  final String exerciseType;

  /// Progression step: kg for weighted, reps for bodyweight, seconds for
  /// timed exercises. Null uses the default.
  final double? increment;

  /// Successful sets in a row at the same level before it goes up. Null
  /// uses the default from Settings.
  final int? setsToProgress;

  /// Whether the next sets are raised automatically.
  final bool autoProgress;
  static const tableName = 'exercises';

  const ExerciseModel({
    required this.id,
    required this.name,
    required this.muscleGroup,
    this.description,
    this.imagePath,
    this.youTubeUrl,
    required this.createdAt,
    this.exerciseType = 'weighted',
    this.increment,
    this.setsToProgress,
    this.autoProgress = true,
  });

  bool get hasCustomImage => imagePath != null;

  Color get groupColor => AppColors.muscleGroupColor(muscleGroup);

  factory ExerciseModel.fromMap(Map<String, dynamic> map) {
    return ExerciseModel(
      id: map['id'] as String,
      name: map['name'] as String,
      muscleGroup: map['muscle_group'] as String,
      description: map['description'] as String?,
      imagePath: map['image_path'] as String?,
      youTubeUrl: map['youtube_url'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      exerciseType: map['exercise_type'] as String? ?? 'weighted',
      increment: (map['increment'] as num?)?.toDouble(),
      setsToProgress: map['sets_to_progress'] as int?,
      autoProgress: (map['auto_progress'] as int? ?? 1) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'muscle_group': muscleGroup,
      'description': description,
      'image_path': imagePath,
      'youtube_url': youTubeUrl,
      'created_at': createdAt.toIso8601String(),
      'exercise_type': exerciseType,
      'increment': increment,
      'sets_to_progress': setsToProgress,
      'auto_progress': autoProgress ? 1 : 0,
    };
  }

  ExerciseModel copyWith({
    String? name,
    String? muscleGroup,
    String? description,
    String? imagePath,
    String? youTubeUrl,
    String? exerciseType,
  }) {
    return ExerciseModel(
      id: id,
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      youTubeUrl: youTubeUrl ?? this.youTubeUrl,
      createdAt: createdAt,
      exerciseType: exerciseType ?? this.exerciseType,
      increment: increment,
      setsToProgress: setsToProgress,
      autoProgress: autoProgress,
    );
  }

  bool get isWeighted => exerciseType == 'weighted';

  bool get isBodyweight => exerciseType == 'bodyweight';

  bool get isTimed => exerciseType == 'timed';

  /// Built-in step when neither the exercise nor Settings define one.
  static double defaultIncrementFor(String exerciseType) =>
      switch (exerciseType) { 'bodyweight' => 1, 'timed' => 5, _ => 2.5 };
}
