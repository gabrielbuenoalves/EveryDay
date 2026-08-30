import '../../../../core/domain/daily_reading.dart';
import '../../../../core/domain/user_preview.dart';

sealed class FeedItem {
  const FeedItem({
    required this.id,
    required this.occurredAt,
    required this.author,
    required this.highFives,
    required this.comments,
  });

  final String id;
  final DateTime occurredAt;
  final UserPreview author;
  final int highFives;
  final int comments;
}

class BookCompletedFeedItem extends FeedItem {
  const BookCompletedFeedItem({
    required super.id,
    required super.occurredAt,
    required super.author,
    required super.highFives,
    required super.comments,
    required this.bookName,
    required this.chapterCount,
    this.quote,
  });

  final String bookName;
  final int chapterCount;
  final String? quote;
}

class ReadingProgressFeedItem extends FeedItem {
  const ReadingProgressFeedItem({
    required super.id,
    required super.occurredAt,
    required super.author,
    required super.highFives,
    required super.comments,
    required this.passageLabel,
    required this.readingMinutes,
    required this.segments,
  });

  final String passageLabel;
  final int readingMinutes;
  final List<double> segments;
}

class StreakAchievementFeedItem extends FeedItem {
  const StreakAchievementFeedItem({
    required super.id,
    required super.occurredAt,
    required super.author,
    required super.highFives,
    required super.comments,
    required this.days,
    required this.isPersonalBest,
  });

  final int days;
  final bool isPersonalBest;
}

class FeedHome {
  const FeedHome({
    required this.streakDays,
    required this.dailyReading,
    required this.items,
  });

  final int streakDays;
  final DailyReading dailyReading;
  final List<FeedItem> items;
}
