import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Backgrounds
  static const bg = Color(0xFF0C0F1A);
  static const bg2 = Color(0xFF141829);
  static const bg3 = Color(0xFF1C2138);
  static const bg4 = Color(0xFF242B45);
  static const card = Color(0xFF151B2E);
  static const border = Color(0xFF1E2540);
  static const border2 = Color(0xFF2D3554);

  // Accent
  static const accent = Color(0xFF4F8EF7); // plava
  static const green = Color(0xFF38D9A9); // zavrseno
  static const amber = Color(0xFFFFB347); // streak
  static const red = Color(0xFFE55B5B); // greska

  // Text
  static const text1 = Color(0xFFEEF0FF);
  static const text2 = Color(0xFF8B92B3);
  static const text3 = Color(0xFF525A7A);

  // Muscle group colors
  static const chest = Color(0xFFE55B5B);
  static const back = Color(0xFF4F8EF7);
  static const shoulders = Color(0xFFFFB347);
  static const biceps = Color(0xFF38D9A9);
  static const triceps = Color(0xFFA78BFA);
  static const legs = Color(0xFFFB7185);
  static const core = Color(0xFF34D399);

  static Color muscleGroupColor(String group) {
    return switch (group) {
      'Chest' => chest,
      'Back' => back,
      'Shoulders' => shoulders,
      'Biceps' => biceps,
      'Triceps' => triceps,
      'Legs' => legs,
      'Core' => core,
      _ => text3,
    };
  }
}
