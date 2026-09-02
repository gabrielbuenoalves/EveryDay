import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class PhoneViewport extends StatelessWidget {
  const PhoneViewport({super.key, required this.child});

  static const width = 390.0;
  static const height = 844.0;
  static const compactBreakpoint = 520.0;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            constraints.maxWidth <= compactBreakpoint ||
            constraints.maxHeight <= 640;
        if (compact) return child;

        return ColoredBox(
          color: const Color(0xFF0D0D10),
          child: Center(
            child: FittedBox(
              child: Container(
                width: width + 18,
                height: height + 18,
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: const Color(0xFF121214),
                  borderRadius: BorderRadius.circular(42),
                  border: Border.all(color: AppColors.slate700),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xA6000000),
                      blurRadius: 80,
                      offset: Offset(0, 28),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(35),
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        size: const Size(width, height),
                        padding: const EdgeInsets.only(top: 12, bottom: 8),
                        viewPadding: const EdgeInsets.only(top: 12, bottom: 8),
                        textScaler: TextScaler.noScaling,
                      ),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
