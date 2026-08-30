import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/feed_home.dart';
import '../../domain/repositories/feed_repository.dart';
import '../../../../core/domain/user_preview.dart';

class FeedRepositoryImpl implements FeedRepository {
  FeedRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<FeedHome> getHome() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) {
      throw StateError('not authenticated');
    }

    final me = await _client
        .from('profiles')
        .select('church_id, role')
        .eq('id', uid)
        .single();
    final churchId = me['church_id'] as String?;
    final isPastor = me['role'] == 'pastor';

    final streakDays = await _streakFor(uid);
    final today = DateTime.now().toIso8601String().substring(0, 10);

    final mood = await _client
        .from('mood_checkins')
        .select('id')
        .eq('user_id', uid)
        .eq('day', today)
        .maybeSingle();

    final logs = churchId == null
        ? <Map<String, dynamic>>[]
        : await _client
              .from('reading_logs')
              .select(
                'id, passage_label, minutes, note, kind, occurred_at, user_id, profiles!user_id(display_name, initials, avatar_color)',
              )
              .eq('church_id', churchId)
              .order('occurred_at', ascending: false)
              .limit(40);

    final items = <FeedItem>[];
    for (final row in logs) {
      final profile = Map<String, dynamic>.from(row['profiles'] as Map);
      final author = UserPreview(
        id: row['user_id'] as String,
        displayName: profile['display_name'] as String,
        initials: profile['initials'] as String,
        avatarColorValue: profile['avatar_color'] as int,
      );
      final occurredAt = DateTime.parse(row['occurred_at'] as String).toLocal();
      final highFives = await _count('reactions', row['id'] as String);
      final comments = await _count('comments', row['id'] as String);
      final kind = row['kind'] as String? ?? 'progress';
      final note = row['note'] as String?;
      final passage = row['passage_label'] as String;
      final minutes = row['minutes'] as int;

      if (kind == 'streak') {
        items.add(
          StreakAchievementFeedItem(
            id: row['id'] as String,
            occurredAt: occurredAt,
            author: author,
            highFives: highFives,
            comments: comments,
            days: minutes,
            isPersonalBest: true,
          ),
        );
      } else if (kind == 'completed' || (note != null && note.isNotEmpty)) {
        items.add(
          BookCompletedFeedItem(
            id: row['id'] as String,
            occurredAt: occurredAt,
            author: author,
            highFives: highFives,
            comments: comments,
            bookName: passage,
            chapterCount: 1,
            quote: note,
          ),
        );
      } else {
        items.add(
          ReadingProgressFeedItem(
            id: row['id'] as String,
            occurredAt: occurredAt,
            author: author,
            highFives: highFives,
            comments: comments,
            passageLabel: passage,
            readingMinutes: minutes,
            segments: const [1, 1, 1, 1, 0.5],
          ),
        );
      }
    }

    var carePendingCount = 0;
    if (isPastor && churchId != null) {
      final pending = await _client
          .from('mood_checkins')
          .select('id')
          .eq('church_id', churchId)
          .inFilter('status', ['needs_care', 'analyzed']);
      carePendingCount = pending.length;
    }

    return FeedHome(
      streakDays: streakDays,
      items: items,
      needsMoodCheckin: mood == null,
      canOpenCareInbox: isPastor,
      carePendingCount: carePendingCount,
    );
  }

  Future<int> _count(String table, String logId) async {
    final rows = await _client.from(table).select('log_id').eq('log_id', logId);
    return rows.length;
  }

  Future<int> _streakFor(String userId) async {
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
