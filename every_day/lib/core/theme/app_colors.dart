import 'package:flutter/material.dart';

abstract final class AppColors {
  // The names are retained so existing presentation stays compatible; the
  // palette itself is the warm, ink-dark EveryDay system.
  static const slate950 = Color(0xFF0D0E14);
  static const slate900 = Color(0xFF101117);
  static const slate850 = Color(0xFF15161E);
  static const slate800 = Color(0xFF1A1B24);
  static const slate700 = Color(0xFF2A2C37);
  static const slate500 = Color(0xFF626572);
  static const slate400 = Color(0xFF9C9EAA);
  static const slate300 = Color(0xFFD5D5DC);
  static const slate100 = Color(0xFFF5F3F0);
  static const ember = Color(0xFFFF6720);
  static const emberDark = Color(0xFFE84E0C);
  static const success = Color(0xFF58C583);
  static const danger = Color(0xFFEF6A62);
  static const violet = Color(0xFF35205D);
  static const violetSoft = Color(0xFF271A43);

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
