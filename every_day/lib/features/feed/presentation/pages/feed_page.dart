import 'package:flutter/material.dart';

import '../../../../app/di/app_scope.dart';
import '../../../../core/domain/daily_reading.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../reading/presentation/pages/reading_page.dart';
import '../../domain/entities/feed_home.dart';
import '../controllers/feed_controller.dart';
import '../widgets/daily_reading_card.dart';
import '../widgets/feed_cards.dart';
import '../widgets/feed_header.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  FeedController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller ??= FeedController(
      getFeedHome: AppScope.of(context).getFeedHome,
    )..load();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final home = controller.home;

        return SafeArea(
          bottom: false,
          child: Column(
            children: [
              FeedHeader(streakDays: home?.streakDays ?? 0),
              Expanded(
                child: controller.loading && home == null
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.orange,
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                        children: [
                          if (home != null) ...[
                            DailyReadingCard(
                              reading: home.dailyReading,
                              onRead: () => _openReading(home.dailyReading),
                            ),
                            const SizedBox(height: 14),
                            for (final item in home.items) ...[
                              _FeedItemView(item: item),
                              const SizedBox(height: 14),
                            ],
                          ],
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openReading(DailyReading reading) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ReadingPage(reading: reading)),
    );
  }
}

class _FeedItemView extends StatelessWidget {
  const _FeedItemView({required this.item});

  final FeedItem item;

  @override
  Widget build(BuildContext context) {
    return switch (item) {
      final BookCompletedFeedItem completed => CompletionFeedCard(
        item: completed,
      ),
      final ReadingProgressFeedItem progress => ProgressFeedCard(
        item: progress,
      ),
      final StreakAchievementFeedItem streak => StreakFeedCard(item: streak),
    };
  }
}
