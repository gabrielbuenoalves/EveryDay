import '../../domain/entities/user_profile.dart';

class ProfileLocalDataSource {
  UserProfile fetch() {
    return const UserProfile(
      id: 'me',
      displayName: 'Você',
      initials: 'VC',
      avatarColorValue: 0xFFD95F33,
      streakDays: 17,
      longestStreak: 17,
      currentPlan: 'Salmos 28–30',
      stats: UserStats(
        chaptersThisWeek: 18,
        booksCompleted: 4,
        minutesThisWeek: 96,
      ),
    );
  }
}
