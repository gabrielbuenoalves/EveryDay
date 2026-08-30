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
          color: const Color(0xFF111110),
          child: Center(
            child: FittedBox(
              child: Container(
                width: width + 20,
                height: height + 20,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.charcoal,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x66000000),
                      blurRadius: 40,
                      offset: Offset(0, 18),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        size: const Size(width, height),
                        padding: const EdgeInsets.only(top: 12, bottom: 8),
                        viewPadding: const EdgeInsets.only(top: 12, bottom: 8),
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
