import '../../../../core/domain/daily_reading.dart';
import '../../../../core/domain/user_preview.dart';
import '../../domain/entities/feed_home.dart';

class FeedLocalDataSource {
  FeedHome fetchHome({DateTime? now}) {
    final clock = now ?? DateTime.now();

    return FeedHome(
      streakDays: 17,
      dailyReading: const DailyReading(
        passageLabel: 'Salmos 28–30',
        book: 'Salmos',
        startChapter: 28,
        endChapter: 30,
      ),
      items: [
        BookCompletedFeedItem(
          id: 'lucas-john',
          occurredAt: clock.subtract(const Duration(minutes: 12)),
          author: const UserPreview(
            id: 'lucas',
            displayName: 'Lucas',
            initials: 'LC',
            avatarColorValue: 0xFFB8B0A4,
          ),
          bookName: 'João',
          chapterCount: 21,
          quote: 'Cheguei ao fim e queria começar de novo. Que livro.',
          highFives: 12,
          comments: 3,
        ),
        ReadingProgressFeedItem(
          id: 'marina-psalms',
          occurredAt: clock.subtract(const Duration(hours: 1)),
          author: const UserPreview(
            id: 'marina',
            displayName: 'Marina',
            initials: 'MA',
            avatarColorValue: 0xFFE07A4A,
          ),
          passageLabel: 'Salmos 23–27',
          readingMinutes: 14,
          segments: const [1, 1, 1, 1, 0.45],
          highFives: 8,
          comments: 1,
        ),
        StreakAchievementFeedItem(
          id: 'gabriel-streak',
          occurredAt: clock.subtract(const Duration(hours: 3)),
          author: const UserPreview(
            id: 'gabriel',
            displayName: 'Gabriel',
            initials: 'GA',
            avatarColorValue: 0xFF1A4D3A,
          ),
          days: 30,
          isPersonalBest: true,
          highFives: 0,
          comments: 0,
        ),
      ],
    );
  }
}
