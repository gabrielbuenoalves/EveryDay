import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

const everydayTagline = 'o dia começa na leitura';
const everydayLogoAsset = 'assets/branding/everyday_logo.jpg';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 36, this.showShadow = true});

  final double size;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.22),
        boxShadow: showShadow
            ? const [
                BoxShadow(
                  color: Color(0x3DE3703A),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        everydayLogoAsset,
        width: size,
        height: size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

class AppWordmark extends StatelessWidget {
  const AppWordmark({super.key, this.logoSize = 56, this.showTagline = true});

  final double logoSize;
  final bool showTagline;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppLogo(size: logoSize),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'EveryDay',
                style: TextStyle(
                  color: AppColors.slate100,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.05,
                  letterSpacing: -0.7,
                ),
              ),
              if (showTagline) ...[
                const SizedBox(height: 3),
                const Text(
                  everydayTagline,
                  style: TextStyle(
                    color: AppColors.slate400,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
