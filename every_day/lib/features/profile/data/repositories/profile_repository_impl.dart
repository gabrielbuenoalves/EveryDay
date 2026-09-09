import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../../../core/domain/user_role.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<UserProfile> getProfile() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw StateError('not authenticated');

    final row = await _client
        .from('profiles')
        .select(
          'id, display_name, initials, avatar_color, role, churches(name, invite_code)',
        )
        .eq('id', uid)
        .single();

    final church = row['churches'] as Map<String, dynamic>?;
    final logs = await _client
        .from('reading_logs')
        .select('minutes, occurred_at')
        .eq('user_id', uid);

    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    var minutesWeek = 0;
    for (final log in logs) {
      final at = DateTime.parse(log['occurred_at'] as String);
      if (at.isAfter(weekAgo)) {
        minutesWeek += log['minutes'] as int;
      }
    }

    final books = await _client
        .from('book_progress')
        .select('read_chapters, bible_books(chapters)')
        .eq('user_id', uid);
    var completed = 0;
    var chaptersWeek = 0;
    for (final book in books) {
      final read = book['read_chapters'] as int;
      final total = (book['bible_books'] as Map)['chapters'] as int;
      if (read >= total) completed++;
      chaptersWeek += read;
    }

    String plan = 'sem leitura do pastor';
    final carePlans = await _client
        .from('care_plans')
        .select('title, message')
        .eq('user_id', uid)
        .eq('status', 'active')
        .order('created_at', ascending: false)
        .limit(1);
    if (carePlans.isNotEmpty) {
      final title = (carePlans.first['title'] as String?)?.trim();
      plan = (title == null || title.isEmpty) ? 'Leitura do seu pastor' : title;
    }

    return UserProfile(
      id: row['id'] as String,
      displayName: row['display_name'] as String,
      initials: row['initials'] as String,
      avatarColorValue: row['avatar_color'] as int,
      streakDays: await _streak(uid),
      longestStreak: await _streak(uid),
      currentPlan: plan,
      role: UserRoleX.fromName(row['role'] as String?),
      churchName: church?['name'] as String?,
      inviteCode: church?['invite_code'] as String?,
      stats: UserStats(
        chaptersThisWeek: chaptersWeek,
        booksCompleted: completed,
        minutesThisWeek: minutesWeek,
      ),
    );
  }

  Future<int> _streak(String userId) async {
    final rows = await _client
        .from('reading_logs')
        .select('occurred_at')
        .eq('user_id', userId)
        .order('occurred_at', ascending: false)
        .limit(400);
    final days = <DateTime>{};
    for (final row in rows) {
      final at = DateTime.parse(row['occurred_at'] as String).toLocal();
      days.add(DateTime(at.year, at.month, at.day));
    }
    if (days.isEmpty) return 0;
    var cursor = DateTime.now();
    cursor = DateTime(cursor.year, cursor.month, cursor.day);
    if (!days.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
    }
    var streak = 0;
    while (days.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }
}
