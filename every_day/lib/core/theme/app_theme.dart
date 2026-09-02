import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData light() {
    const textTheme = TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        height: 1.1,
        color: AppColors.white,
      ),
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
        height: 1.15,
        color: AppColors.white,
      ),
      titleLarge: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        height: 1.25,
        color: AppColors.white,
      ),
      titleMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: AppColors.white,
      ),
      bodyLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: AppColors.white,
      ),
      bodyMedium: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.35,
        color: AppColors.muted,
      ),
      labelLarge: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
        color: AppColors.white,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: AppColors.muted,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.orange,
        onPrimary: AppColors.white,
        secondary: AppColors.forest,
        onSecondary: AppColors.background,
        surface: AppColors.surface,
        onSurface: AppColors.white,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      dividerColor: AppColors.divider,
      splashFactory: InkRipple.splashFactory,
    );
  }
}
