class UserStats {
  const UserStats({
    required this.chaptersThisWeek,
    required this.booksCompleted,
    required this.minutesThisWeek,
  });

  final int chaptersThisWeek;
  final int booksCompleted;
  final int minutesThisWeek;
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.displayName,
    required this.initials,
    required this.avatarColorValue,
    required this.streakDays,
    required this.longestStreak,
    required this.currentPlan,
    required this.stats,
  });

  final String id;
  final String displayName;
  final String initials;
  final int avatarColorValue;
  final int streakDays;
  final int longestStreak;
  final String currentPlan;
  final UserStats stats;
}
