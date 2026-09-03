import 'package:flutter/material.dart';

abstract final class AppColors {
  // The names are retained so existing presentation stays compatible; the
  // palette itself is the warm, ink-dark EveryDay system.
  static const slate950 = Color(0xFF101014);
  static const slate900 = Color(0xFF15151B);
  static const slate850 = Color(0xFF1B1B22);
  static const slate800 = Color(0xFF222229);
  static const slate700 = Color(0xFF34343D);
  static const slate500 = Color(0xFF6D6D78);
  static const slate400 = Color(0xFFA0A0AA);
  static const slate300 = Color(0xFFD2D2D8);
  static const slate100 = Color(0xFFF6F5F2);
  static const ember = Color(0xFFFF5C16);
  static const emberDark = Color(0xFFE94D0A);
  static const success = Color(0xFF46C879);
  static const danger = Color(0xFFFF6961);
  static const violet = Color(0xFF332052);
  static const violetSoft = Color(0xFF25183D);

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
