import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData light() {
    const textTheme = TextTheme(
      displayLarge: TextStyle(
        fontSize: 27,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        height: 1.1,
        color: AppColors.slate100,
      ),
      headlineMedium: TextStyle(
        fontSize: 21,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
        height: 1.15,
        color: AppColors.slate100,
      ),
      titleLarge: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        height: 1.25,
        color: AppColors.slate100,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: AppColors.slate100,
      ),
      bodyLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: AppColors.slate100,
      ),
      bodyMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.35,
        color: AppColors.slate400,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.1,
        color: AppColors.slate950,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: AppColors.ember,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      visualDensity: VisualDensity.compact,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.slate900,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.ember,
        onPrimary: AppColors.slate950,
        secondary: AppColors.emberDark,
        onSecondary: AppColors.slate100,
        surface: AppColors.slate800,
        onSurface: AppColors.slate100,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.slate900,
        foregroundColor: AppColors.slate100,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      dividerColor: AppColors.slate700,
      splashFactory: InkSparkle.splashFactory,
      cardTheme: CardThemeData(
        color: AppColors.slate800,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.slate700),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.slate800,
        modalBackgroundColor: AppColors.slate800,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.ember,
          foregroundColor: AppColors.slate950,
          minimumSize: const Size(48, 42),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: .15,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.slate800,
        contentTextStyle: const TextStyle(color: AppColors.slate100),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        behavior: SnackBarBehavior.floating,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.slate850,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        labelStyle: const TextStyle(color: AppColors.slate400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.slate700),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.slate700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.ember, width: 1.4),
        ),
      ),
    );
  }
}
