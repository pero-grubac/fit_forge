import 'package:fit_forge/data/models/default_set_model.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class ExerciseModel {
  final String id;
  final String planId;
  final String name;
  final String muscleGroup;
  final String? description;
  final String? imagePath;
  final String? youTubeUrl;
  final int sortOrder;
  final DateTime createdAt;
  final List<DefaultSetModel> defaultSets;

  static const tableName = 'exercises';

  const ExerciseModel({
    required this.id,
    required this.planId,
    required this.name,
    required this.muscleGroup,
    this.description,
    this.imagePath,
    this.youTubeUrl,
    required this.sortOrder,
    required this.createdAt,
    this.defaultSets = const [],
  });

  bool get hasCustomImage => imagePath != null;

  Color get groupColor => AppColors.muscleGroupColor(muscleGroup);

  factory ExerciseModel.fromMap(Map<String, dynamic> map) {
    return ExerciseModel(
      id: map['id'] as String,
      planId: map['plan_id'] as String,
      name: map['name'] as String,
      muscleGroup: map['muscle_group'] as String,
      description: map['description'] as String?,
      imagePath: map['image_path'] as String?,
      youTubeUrl: map['youtube_url'] as String?,
      sortOrder: map['sort_order'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'plan_id': planId,
      'name': name,
      'muscle_group': muscleGroup,
      'description': description,
      'image_path': imagePath,
      'youtube_url': youTubeUrl,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ExerciseModel copyWith({
    String? name,
    String? muscleGroup,
    String? description,
    String? imagePath,
    String? youTubeUrl,
    int? sortOrder,
    List<DefaultSetModel>? defaultSets,
  }) {
    return ExerciseModel(
      id: id,
      planId: planId,
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      youTubeUrl: youTubeUrl ?? this.youTubeUrl,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt,
      defaultSets: defaultSets ?? this.defaultSets,
    );
  }
}
