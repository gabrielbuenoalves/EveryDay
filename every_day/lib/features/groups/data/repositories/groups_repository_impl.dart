import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/domain/user_preview.dart';
import '../../domain/entities/reading_group.dart';
import '../../domain/repositories/groups_repository.dart';

class GroupsRepositoryImpl implements GroupsRepository {
  GroupsRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<List<ReadingGroup>> getGroups() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw StateError('not authenticated');

    final me = await _client
        .from('profiles')
        .select('church_id')
        .eq('id', uid)
        .single();
    final churchId = me['church_id'] as String?;
    if (churchId == null) return [];

    final groups = await _client
        .from('groups')
        .select()
        .eq('church_id', churchId);
    final result = <ReadingGroup>[];

    for (final group in groups) {
      final groupId = group['id'] as String;
      final members = await _client
          .from('group_members')
          .select(
            'user_id, profiles!user_id(id, display_name, initials, avatar_color)',
          )
          .eq('group_id', groupId);

      final previews = <UserPreview>[];
      for (final member in members) {
        final profile = Map<String, dynamic>.from(member['profiles'] as Map);
        previews.add(
          UserPreview(
            id: profile['id'] as String,
            displayName: profile['display_name'] as String,
            initials: profile['initials'] as String,
            avatarColorValue: profile['avatar_color'] as int,
          ),
        );
      }

      final weekAgo = DateTime.now()
          .subtract(const Duration(days: 7))
          .toIso8601String();
      final logs = await _client
          .from('reading_logs')
          .select('user_id')
          .eq('church_id', churchId)
          .gte('occurred_at', weekAgo);
      final readers = logs.map((row) => row['user_id']).toSet();
      final progress = previews.isEmpty
          ? 0.0
          : readers.where((id) => previews.any((p) => p.id == id)).length /
                previews.length;

      result.add(
        ReadingGroup(
          id: groupId,
          name: group['name'] as String,
          planLabel: group['plan_label'] as String,
          memberCount: previews.length,
          weekProgress: progress.clamp(0, 1),
          members: previews,
          inviteCode: group['invite_code'] as String?,
        ),
      );
    }

    return result;
  }
}
