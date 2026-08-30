import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/time_ago.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/reaction_pills.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../domain/entities/feed_home.dart';

class CompletionFeedCard extends StatelessWidget {
  const CompletionFeedCard({super.key, required this.item});

  final BookCompletedFeedItem item;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FeedPersonHeader(
            initials: item.author.initials,
            color: Color(item.author.avatarColorValue),
            title: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: item.author.displayName,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const TextSpan(text: ' terminou '),
                  TextSpan(
                    text: item.bookName,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            subtitle:
                '${timeAgo(item.occurredAt)} · ${item.chapterCount} capítulos',
            trailing: const _CheckBadge(),
          ),
          if (item.quote != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.quoteFill,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '“${item.quote}”',
                style: const TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 16,
                  height: 1.45,
                  fontStyle: FontStyle.italic,
                  color: AppColors.charcoal,
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          ReactionPills(highFives: item.highFives, comments: item.comments),
        ],
      ),
    );
  }
}

class ProgressFeedCard extends StatelessWidget {
  const ProgressFeedCard({super.key, required this.item});

  final ReadingProgressFeedItem item;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FeedPersonHeader(
            initials: item.author.initials,
            color: Color(item.author.avatarColorValue),
            title: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: item.author.displayName,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const TextSpan(text: ' leu '),
                  TextSpan(
                    text: item.passageLabel,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            subtitle:
                '${timeAgo(item.occurredAt)} · ${item.readingMinutes} min de leitura',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (var i = 0; i < item.segments.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  flex: (item.segments[i] * 100).round().clamp(20, 100),
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.forest,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          ReactionPills(highFives: item.highFives, comments: item.comments),
        ],
      ),
    );
  }
}

class StreakFeedCard extends StatelessWidget {
  const StreakFeedCard({super.key, required this.item});

  final StreakAchievementFeedItem item;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      color: AppColors.forest,
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
      child: Row(
        children: [
          Expanded(
            child: _FeedPersonHeader(
              initials: item.author.initials,
              color: Color(item.author.avatarColorValue),
              foregroundColor: AppColors.white,
              title: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: item.author.displayName,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const TextSpan(text: ' completou '),
                    TextSpan(
                      text: '${item.days} dias seguidos',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                ),
              ),
              subtitleStyle: const TextStyle(
                color: Color(0xFFC5D9CE),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              subtitle: item.isPersonalBest
                  ? '${timeAgo(item.occurredAt)} · maior sequência dele'
                  : timeAgo(item.occurredAt),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 8, right: 4),
            child: Icon(
              Icons.local_fire_department_rounded,
              color: Color(0xFF7CBA96),
              size: 48,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedPersonHeader extends StatelessWidget {
  const _FeedPersonHeader({
    required this.initials,
    required this.color,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.foregroundColor,
    this.subtitleStyle,
  });

  final String initials;
  final Color color;
  final Widget title;
  final String subtitle;
  final Widget? trailing;
  final Color? foregroundColor;
  final TextStyle? subtitleStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppAvatar(
          initials: initials,
          color: color,
          foregroundColor: foregroundColor,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              const SizedBox(height: 4),
              Text(
                subtitle,
                style:
                    subtitleStyle ?? Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class _CheckBadge extends StatelessWidget {
  const _CheckBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: AppColors.checkGreen,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check_rounded, color: AppColors.white, size: 18),
    );
  }
}
