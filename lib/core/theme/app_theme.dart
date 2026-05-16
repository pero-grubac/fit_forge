import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          secondary: AppColors.green,
          surface: AppColors.bg2,
          error: AppColors.red,
        ),
        cardColor: AppColors.card,
        dividerColor: AppColors.border,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.bg,
          foregroundColor: AppColors.text1,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: AppColors.text1,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
              color: AppColors.text1,
              fontSize: 26,
              fontWeight: FontWeight.w800),
          headlineMedium: TextStyle(
              color: AppColors.text1,
              fontSize: 22,
              fontWeight: FontWeight.w700),
          titleLarge: TextStyle(
              color: AppColors.text1,
              fontSize: 17,
              fontWeight: FontWeight.w600),
          titleMedium: TextStyle(
              color: AppColors.text1,
              fontSize: 15,
              fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: AppColors.text2, fontSize: 14),
          bodyMedium: TextStyle(color: AppColors.text2, fontSize: 13),
          bodySmall: TextStyle(color: AppColors.text3, fontSize: 11),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.bg3,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: const BorderSide(color: AppColors.border2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: const BorderSide(color: AppColors.border2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
          ),
          labelStyle: const TextStyle(color: AppColors.text2),
          hintStyle: const TextStyle(color: AppColors.text3),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.bg2,
          selectedItemColor: AppColors.accent,
          unselectedItemColor: AppColors.text3,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
      );
}
