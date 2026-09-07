import 'package:flutter/material.dart';

/// Visual tokens extracted from the pastoral screens in the UX reference.
///
/// This theme is intentionally scoped to [PastorShell]. It must not be added to
/// the app-level theme because the member and authentication experiences keep
/// their existing visual language.
abstract final class PastorPalette {
  static const background = Color(0xFFF7F5F0);
  static const surface = Color(0xFFFFFCF7);
  static const surfaceStrong = Color(0xFFFFFCF7);
  static const surfaceSoft = Color(0xFFF7F5F0);
  static const navigation = Color(0xFFFFFCF7);
  static const secondaryButton = Color(0xFFDCE9E4);
  static const border = Color(0xFFDCE9E4);
  static const divider = Color(0xFFDCE9E4);
  static const orange = Color(0xFF315B57);
  static const orangeSoft = Color(0xFFDCE9E4);
  static const orangeBorder = Color(0xFF315B57);
  static const plum = Color(0xFFDCE9E4);
  static const white = Color(0xFF25302D);
  static const onPrimary = Color(0xFFFFFCF7);
  static const secondary = Color(0xFF55776F);
  static const textMuted = Color(0xFF5F6965);
  static const textSoft = Color(0xFF5F6965);
  static const success = Color(0xFF315B57);
  static const successSurface = Color(0xFFDCE9E4);
  static const blue = secondary;
  static const purple = Color(0xFFB84E1E);
  static const accent = Color(0xFFF47C20);
  static const accentDark = Color(0xFFB84E1E);
  static const scrim = Color(0xCC25302D);
}

abstract final class PastorTheme {
  static ThemeData data() {
    const textTheme = TextTheme(
      displaySmall: TextStyle(
        fontFamily: 'Poppins',
        color: PastorPalette.white,
        fontSize: 27,
        height: 1.08,
        letterSpacing: -0.8,
        fontWeight: FontWeight.w800,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Poppins',
        color: PastorPalette.white,
        fontSize: 21,
        height: 1.15,
        letterSpacing: -0.4,
        fontWeight: FontWeight.w800,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Poppins',
        color: PastorPalette.white,
        fontSize: 18,
        height: 1.2,
        letterSpacing: -0.25,
        fontWeight: FontWeight.w800,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Inter',
        color: PastorPalette.white,
        fontSize: 16,
        height: 1.25,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Inter',
        color: PastorPalette.white,
        fontSize: 15,
        height: 1.45,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Inter',
        color: PastorPalette.textSoft,
        fontSize: 13,
        height: 1.45,
        fontWeight: FontWeight.w500,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Inter',
        color: PastorPalette.textMuted,
        fontSize: 12,
        height: 1.35,
        fontWeight: FontWeight.w500,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Inter',
        color: PastorPalette.white,
        fontSize: 14,
        height: 1.2,
        fontWeight: FontWeight.w700,
      ),
      labelMedium: TextStyle(
        fontFamily: 'Inter',
        color: PastorPalette.textMuted,
        fontSize: 12,
        height: 1.2,
        fontWeight: FontWeight.w600,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: PastorPalette.background,
      colorScheme: const ColorScheme.light(
        primary: PastorPalette.orange,
        onPrimary: PastorPalette.onPrimary,
        primaryContainer: PastorPalette.orangeSoft,
        onPrimaryContainer: PastorPalette.white,
        secondary: PastorPalette.secondary,
        onSecondary: PastorPalette.onPrimary,
        tertiary: PastorPalette.accent,
        onTertiary: PastorPalette.white,
        surface: PastorPalette.surface,
        onSurface: PastorPalette.white,
        onSurfaceVariant: PastorPalette.textMuted,
        outline: PastorPalette.secondary,
        outlineVariant: PastorPalette.border,
        error: PastorPalette.accentDark,
        onError: PastorPalette.onPrimary,
        scrim: PastorPalette.scrim,
        shadow: PastorPalette.white,
      ),
      textTheme: textTheme,
      splashColor: PastorPalette.orange.withValues(alpha: 0.10),
      highlightColor: Colors.transparent,
      dividerColor: PastorPalette.divider,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: PastorPalette.surfaceStrong,
        hintStyle: const TextStyle(
          color: PastorPalette.textMuted,
          fontSize: 15,
        ),
        labelStyle: const TextStyle(color: PastorPalette.textMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: PastorPalette.secondary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: PastorPalette.secondary),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: PastorPalette.orange, width: 1.4),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? PastorPalette.onPrimary
              : PastorPalette.white,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? PastorPalette.orange
              : PastorPalette.secondaryButton,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.transparent
              : PastorPalette.secondary,
        ),
      ),
    );
  }
}
