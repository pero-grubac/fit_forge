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
    );
  }

  bool get isWeighted => exerciseType == 'weighted';

  bool get isBodyweight => exerciseType == 'bodyweight';

  bool get isTimed => exerciseType == 'timed';
}
