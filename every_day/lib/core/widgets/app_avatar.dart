import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.initials,
    required this.color,
    this.size = 42,
    this.foregroundColor,
  });

  final String initials;
  final Color color;
  final double size;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    final darkContrast = _contrast(color, AppColors.textPrimary);
    final lightContrast = _contrast(color, AppColors.surface);
    final effectiveForeground =
        foregroundColor ??
        (darkContrast >= lightContrast
            ? AppColors.textPrimary
            : AppColors.surface);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: initials.trim().isEmpty
          ? Icon(
              Icons.person_outline_rounded,
              color: effectiveForeground,
              size: size * 0.46,
            )
          : Text(
              initials,
              style: TextStyle(
                color: effectiveForeground,
                fontWeight: FontWeight.w800,
                fontSize: size * 0.32,
                letterSpacing: 0.4,
                height: 1,
              ),
            ),
    );
  }

  static double _contrast(Color first, Color second) {
    final lighter = first.computeLuminance() > second.computeLuminance()
        ? first.computeLuminance()
        : second.computeLuminance();
    final darker = first.computeLuminance() < second.computeLuminance()
        ? first.computeLuminance()
        : second.computeLuminance();
    return (lighter + .05) / (darker + .05);
  }
}
