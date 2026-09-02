import 'package:flutter/material.dart';

abstract final class AppColors {
  // The names are retained so existing presentation stays compatible; the
  // palette itself is the warm, ink-dark EveryDay system.
  static const slate950 = Color(0xFF121214);
  static const slate900 = Color(0xFF18181C);
  static const slate850 = Color(0xFF1D1D23);
  static const slate800 = Color(0xFF202026);
  static const slate700 = Color(0xFF34343D);
  static const slate500 = Color(0xFF686872);
  static const slate400 = Color(0xFFA4A4AE);
  static const slate300 = Color(0xFFD1D1D8);
  static const slate100 = Color(0xFFF8F7F4);
  static const ember = Color(0xFFFF5A16);
  static const emberDark = Color(0xFFD94308);
  static const success = Color(0xFF45C878);
  static const danger = Color(0xFFF0645D);

  static const cream = slate900;
  static const creamDark = slate800;
  static const charcoal = slate950;
  static const charcoalSoft = slate850;
  static const orange = ember;
  static const orangePressed = emberDark;
  static const forest = Color(0xFF236342);
  static const forestDeep = Color(0xFF173F2C);
  static const forestMuted = Color(0xFF4D9570);
  static const surface = slate800;
  static const quoteFill = slate950;
  static const muted = slate400;
  static const mutedDark = slate500;
  static const navInactive = slate400;
  static const divider = slate700;
  static const checkGreen = ember;
  static const white = slate100;
}
