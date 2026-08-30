import 'package:flutter/material.dart';

import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/streak_badge.dart';

class FeedHeader extends StatelessWidget {
  const FeedHeader({super.key, required this.streakDays});

  final int streakDays;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          const AppLogo(),
          const SizedBox(width: 12),
          Text('Hoje', style: Theme.of(context).textTheme.displayLarge),
          const Spacer(),
          StreakBadge(days: streakDays),
        ],
      ),
    );
  }
}
