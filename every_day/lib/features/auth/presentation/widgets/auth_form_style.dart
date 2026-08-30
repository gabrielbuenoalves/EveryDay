import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

abstract final class AuthFormStyle {
  static const buttonHeight = 52.0;
  static const radius = 12.0;

  static InputDecoration decoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppColors.slate950,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.slate400,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: AppColors.slate500),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: AppColors.slate500),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: AppColors.ember, width: 1.4),
      ),
    );
  }

  static ButtonStyle filled() {
    return FilledButton.styleFrom(
      minimumSize: const Size.fromHeight(buttonHeight),
      backgroundColor: AppColors.ember,
      foregroundColor: AppColors.slate950,
      disabledBackgroundColor: AppColors.emberDark,
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, height: 1),
    );
  }

  static ButtonStyle outlined() {
    return OutlinedButton.styleFrom(
      minimumSize: const Size.fromHeight(buttonHeight),
      foregroundColor: AppColors.slate100,
      padding: EdgeInsets.zero,
      side: const BorderSide(color: AppColors.slate500, width: 1.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, height: 1),
    );
  }
}
