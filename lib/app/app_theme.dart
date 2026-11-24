import 'package:flutter/material.dart';

abstract final class AppColors {
  static const ink = Color(0xFF28231E);
  static const paper = Color(0xFFFFFBF4);
  static const muted = Color(0xFF83786D);
  static const saffron = Color(0xFFE6A23C);
  static const terracotta = Color(0xFFC65336);
  static const maroon = Color(0xFF762F30);
  static const sage = Color(0xFF687B5B);
  static const border = Color(0xFFE9E0D3);
}

ThemeData buildAppTheme() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AppColors.terracotta,
    brightness: Brightness.light,
    surface: AppColors.paper,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.paper,
    splashFactory: InkRipple.splashFactory,
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        color: AppColors.ink,
        fontSize: 30,
        fontWeight: FontWeight.w800,
        height: 1.15,
      ),
      titleLarge: TextStyle(
        color: AppColors.ink,
        fontSize: 19,
        fontWeight: FontWeight.w700,
      ),
      bodyMedium: TextStyle(color: AppColors.ink, fontSize: 15, height: 1.5),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.paper,
      foregroundColor: AppColors.ink,
      centerTitle: false,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.terracotta, width: 1.5),
      ),
    ),
  );
}
