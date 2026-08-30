import '../../../../core/domain/user_role.dart';

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
    required this.role,
    this.churchName,
    this.inviteCode,
  });

  final String id;
  final String displayName;
  final String initials;
  final int avatarColorValue;
  final int streakDays;
  final int longestStreak;
  final String currentPlan;
  final UserStats stats;
  final UserRole role;
  final String? churchName;
  final String? inviteCode;

  String get firstName {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? displayName : parts.first;
  }

  String get username {
    final raw = firstName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9._-]'), '');
    return '@${raw.isEmpty ? 'voce' : raw}';
  }
}
