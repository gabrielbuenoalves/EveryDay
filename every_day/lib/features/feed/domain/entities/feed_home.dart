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

class CareReading {
  const CareReading({required this.reading, this.completed = false});

  final DailyReading reading;
  final bool completed;

  String get passageLabel => reading.passageLabel;

  bool get isDone => completed == true;
}

class MemberCarePlan {
  const MemberCarePlan({
    required this.id,
    required this.title,
    this.message,
    required this.readings,
    this.sourceLabel = 'Leitura do seu pastor',
    this.groupId,
    this.readingPlanId,
    this.pastoral = true,
    this.archived = false,
    this.sessionMinutes,
    this.takeaway,
    this.archivedAt,
  });

  final String id;
  final String title;
  final String? message;
  final List<CareReading> readings;
  final String sourceLabel;
  final String? groupId;
  final String? readingPlanId;
  final bool pastoral;
  final bool archived;
  final int? sessionMinutes;
  final String? takeaway;
  final DateTime? archivedAt;

  int get doneCount => readings.where((item) => item.isDone).length;

  List<DailyReading> get playlist =>
      readings.map((item) => item.reading).toList();

  Set<String> get completedLabels => {
    for (final item in readings)
      if (item.isDone) item.passageLabel,
  };

  bool get isComplete => readings.isNotEmpty && doneCount == readings.length;

  bool get isArchived => archived == true;

  bool get isPastoral => pastoral != false;
}

class FeedHome {
  const FeedHome({
    required this.streakDays,
    required this.items,
    this.carePlan,
    this.needsMoodCheckin = false,
    this.canOpenCareInbox = false,
    this.carePendingCount = 0,
  });

  final int streakDays;
  final List<FeedItem> items;
  final MemberCarePlan? carePlan;
  final bool needsMoodCheckin;
  final bool canOpenCareInbox;
  final int carePendingCount;
}
