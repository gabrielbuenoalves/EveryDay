import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class ReactionPills extends StatelessWidget {
  const ReactionPills({
    super.key,
    required this.highFives,
    required this.comments,
    this.onHighFive,
    this.onComment,
  });

  final int highFives;
  final int comments;
  final VoidCallback? onHighFive;
  final VoidCallback? onComment;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Pill(
          icon: Icons.waving_hand_rounded,
          count: highFives,
          onTap: onHighFive,
        ),
        const SizedBox(width: 8),
        _Pill(
          icon: Icons.chat_bubble_outline_rounded,
          count: comments,
          onTap: onComment,
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.icon,
    required this.count,
    this.onTap,
  });

  final IconData icon;
  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cream,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            children: [
              Icon(icon, size: 15, color: AppColors.charcoal),
              const SizedBox(width: 6),
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.charcoal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
