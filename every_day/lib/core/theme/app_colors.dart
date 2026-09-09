import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF315B57);
  static const background = Color(0xFFF7F5F0);
  static const surface = Color(0xFFFFFCF7);
  static const primaryContainer = Color(0xFFDCE9E4);
  static const secondary = Color(0xFF55776F);
  static const orange = Color(0xFFF47C20);
  static const orangeDark = Color(0xFFB84E1E);
  static const textPrimary = Color(0xFF25302D);
  static const textSecondary = Color(0xFF5F6965);
  static const scrim = Color(0xCC25302D);
  static const softShadow = Color(0x2925302D);

  // Legacy names are retained so the presentation adopts the palette without
  // a broad widget rewrite.
  static const slate950 = textPrimary;
  static const slate900 = background;
  static const slate850 = surface;
  static const slate800 = surface;
  static const slate700 = primaryContainer;
  static const slate500 = secondary;
  static const slate400 = textSecondary;
  static const slate300 = textSecondary;
  static const slate100 = textPrimary;
  static const ember = primary;
  static const emberDark = orangeDark;
  static const success = primary;
  static const danger = orangeDark;
  static const violet = primaryContainer;
  static const violetSoft = primaryContainer;

  static const cream = background;
  static const creamDark = primaryContainer;
  static const charcoal = primary;
  static const charcoalSoft = primaryContainer;
  static const orangePressed = orangeDark;
  static const forest = primary;
  static const forestDeep = textPrimary;
  static const forestMuted = secondary;
  static const quoteFill = primaryContainer;
  static const muted = textSecondary;
  static const mutedDark = secondary;
  static const navInactive = textSecondary;
  static const divider = primaryContainer;
  static const checkGreen = primary;
  static const white = surface;
}
