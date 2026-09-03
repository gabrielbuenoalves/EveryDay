import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/domain/daily_reading.dart';
import '../../../../core/domain/user_preview.dart';
import '../../care/domain/entities/care_models.dart';
import '../domain/repositories/plans_repository.dart';

class PlansRepositoryImpl implements PlansRepository {
  PlansRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<List<MemberCarePlan>> listMyPlans() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw StateError('not authenticated');

    final logs = await _client
        .from('reading_logs')
        .select('passage_label')
        .eq('user_id', uid);
    final done = _doneLabels(logs);

    final plans = <MemberCarePlan>[];
    plans.addAll(await _carePlans(uid, done, archived: false));
    try {
      plans.addAll(await _groupPlans(uid, done, includeArchived: false));
    } catch (_) {}
    return plans;
  }

  @override
  Future<List<MemberCarePlan>> listArchivedPlans() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw StateError('not authenticated');

    final logs = await _client
        .from('reading_logs')
        .select('passage_label')
        .eq('user_id', uid);
    final done = _doneLabels(logs);

    final plans = <MemberCarePlan>[];
    plans.addAll(await _carePlans(uid, done, archived: true));
    try {
      plans.addAll(
        (await _groupPlans(
          uid,
          done,
          includeArchived: true,
        )).where((plan) => plan.isArchived),
      );
    } catch (_) {}
    plans.sort((a, b) {
      final left = a.archivedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final right = b.archivedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return right.compareTo(left);
    });
    return plans;
  }

  Future<List<MemberCarePlan>> _carePlans(
    String uid,
    Set<String> done, {
    required bool archived,
  }) async {
    final rows = await _client
        .from('care_plans')
        .select('id, title, message, status, archived_at')
        .eq('user_id', uid)
        .eq('status', archived ? 'archived' : 'active')
        .order('created_at', ascending: false);
    final reflections = archived
        ? await _careReflections(uid)
        : const <String, Map<String, dynamic>>{};
    final result = <MemberCarePlan>[];
    for (final row in rows) {
      final readings = await _readingsForCare(row['id'] as String, done);
      if (readings.isEmpty && !archived) continue;
      final title = (row['title'] as String?)?.trim();
      final meta = reflections[row['id'] as String];
      result.add(
        MemberCarePlan(
          id: row['id'] as String,
          title: (title == null || title.isEmpty)
              ? 'Leitura do seu pastor'
              : title,
          message: (row['message'] as String?)?.trim(),
          readings: readings,
          archived: archived,
          sessionMinutes: _asInt(meta?['minutes']),
          takeaway: (meta?['takeaway'] as String?)?.trim(),
          archivedAt: row['archived_at'] == null
              ? null
              : DateTime.parse(row['archived_at'] as String).toLocal(),
        ),
      );
    }
    return result;
  }

  Future<List<MemberCarePlan>> _groupPlans(
    String uid,
    Set<String> done, {
    bool includeArchived = false,
  }) async {
    final memberships = await _client
        .from('group_members')
        .select('group_id, groups(id, name, plan_id, plan_label)')
        .eq('user_id', uid);
    final result = <MemberCarePlan>[];
    final seen = <String>{};
    final archivedByKey = await _completionsFor(uid);

    for (final row in memberships) {
      final group = row['groups'];
      if (group is! Map) continue;
      final groupId = group['id'] as String;
      result.addAll(
        await _plansForGroup(
          uid: uid,
          done: done,
          groupId: groupId,
          groupName: group['name'] as String? ?? 'Grupo',
          fallbackPlanId: group['plan_id'] as String?,
          fallbackLabel: group['plan_label'] as String?,
          includeArchived: includeArchived,
          archivedByKey: archivedByKey,
          seen: seen,
        ),
      );
    }
    return result;
  }

  Future<Map<String, Map<String, dynamic>>> _completionsFor(String uid) async {
    final archivedByKey = <String, Map<String, dynamic>>{};
    try {
      final rows = await _client
          .from('group_plan_completions')
          .select('group_id, plan_id, takeaway, minutes, created_at')
          .eq('user_id', uid);
      for (final row in rows) {
        archivedByKey['${row['group_id']}:${row['plan_id']}'] =
            Map<String, dynamic>.from(row);
      }
    } catch (_) {}
    return archivedByKey;
  }

  Future<List<MemberCarePlan>> _plansForGroup({
    required String uid,
    required Set<String> done,
    required String groupId,
    required String groupName,
    required String? fallbackPlanId,
    required String? fallbackLabel,
    required bool includeArchived,
    required Map<String, Map<String, dynamic>> archivedByKey,
    required Set<String> seen,
  }) async {
    final result = <MemberCarePlan>[];
    var assigned = <dynamic>[];
    try {
      assigned = await _client
          .from('group_reading_plans')
          .select('plan_id')
          .eq('group_id', groupId);
    } catch (_) {}
    final planIds = assigned
        .map((item) => (item as Map)['plan_id'] as String)
        .toSet();
    if (fallbackPlanId != null) planIds.add(fallbackPlanId);

    for (final planId in planIds) {
      final key = '$groupId:$planId';
      if (!seen.add(key)) continue;
      final meta = archivedByKey[key];
      final archived = meta != null;
      if (archived && !includeArchived) continue;
      final plan = await _client
          .from('reading_plans')
          .select('id, title')
          .eq('id', planId)
          .maybeSingle();
      if (plan == null) continue;
      final readings = await _readingsForChurchPlan(planId, done);
      if (readings.isEmpty && !archived) continue;
      result.add(
        MemberCarePlan(
          id: key,
          title: (plan['title'] as String?)?.trim().isNotEmpty == true
              ? plan['title'] as String
              : (fallbackLabel ?? 'Leitura do grupo'),
          readings: readings,
          sourceLabel: 'Grupo $groupName',
          groupId: groupId,
          readingPlanId: planId,
          pastoral: false,
          archived: archived,
          sessionMinutes: _asInt(meta?['minutes']),
          takeaway: (meta?['takeaway'] as String?)?.trim(),
          archivedAt: meta?['created_at'] == null
              ? null
              : DateTime.parse(meta!['created_at'] as String).toLocal(),
        ),
      );
    }
    return result;
  }

  Future<List<CareReading>> _readingsForCare(
    String planId,
    Set<String> done,
  ) async {
    final days = await _client
        .from('care_plan_days')
        .select('passage_label, book, start_chapter, end_chapter, day')
        .eq('plan_id', planId)
        .order('day');
    return _uniqueReadings(days, done);
  }

  Future<List<CareReading>> _readingsForChurchPlan(
    String planId,
    Set<String> done,
  ) async {
    final days = await _client
        .from('plan_days')
        .select('passage_label, book, start_chapter, end_chapter, day')
        .eq('plan_id', planId)
        .order('day');
    return _uniqueReadings(days, done);
  }

  List<CareReading> _uniqueReadings(List<dynamic> days, Set<String> done) {
    final seen = <String>{};
    final readings = <CareReading>[];
    for (final raw in days) {
      if (raw is! Map) continue;
      final day = Map<String, dynamic>.from(raw);
      final label = (day['passage_label'] as String? ?? '').trim();
      final key = label.toLowerCase();
      if (label.isEmpty || !seen.add(key)) continue;
      readings.add(
        CareReading(
          reading: DailyReading.fromLabel(
            label,
            book: day['book'] as String?,
            startChapter: _asInt(day['start_chapter']),
            endChapter: _asInt(day['end_chapter']),
          ),
          completed: done.contains(key),
        ),
      );
    }
    return readings;
  }

  Future<Map<String, Map<String, dynamic>>> _careReflections(String uid) async {
    final byPlan = <String, Map<String, dynamic>>{};
    try {
      final rows = await _client
          .from('care_plan_reflections')
          .select('plan_id, takeaway, minutes, created_at')
          .eq('user_id', uid);
      for (final row in rows) {
        byPlan[row['plan_id'] as String] = Map<String, dynamic>.from(row);
      }
    } catch (_) {}
    return byPlan;
  }

  Set<String> _doneLabels(List<dynamic> logs) {
    return {
      for (final log in logs)
        if ((log['passage_label'] as String?)?.trim().isNotEmpty == true)
          (log['passage_label'] as String).trim().toLowerCase(),
    };
  }

  int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value');
  }

  @override
  Future<List<PassageComment>> listComments({
    required String groupId,
    required String passageLabel,
  }) async {
    final rows = await _client
        .from('group_passage_comments')
        .select(
          'id, body, created_at, user_id, profiles!user_id(display_name, initials, avatar_color)',
        )
        .eq('group_id', groupId)
        .eq('passage_label', passageLabel)
        .order('created_at');
    return [
      for (final row in rows)
        PassageComment(
          id: row['id'] as String,
          author: _author(row),
          body: row['body'] as String,
          createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
        ),
    ];
  }

  UserPreview _author(Map<String, dynamic> row) {
    final profile = row['profiles'];
    if (profile is Map) {
      return UserPreview(
        id: row['user_id'] as String,
        displayName: profile['display_name'] as String? ?? 'Membro',
        initials: profile['initials'] as String? ?? 'M',
        avatarColorValue: profile['avatar_color'] as int? ?? 0xFF64748B,
      );
    }
    return UserPreview(
      id: row['user_id'] as String,
      displayName: 'Membro',
      initials: 'M',
      avatarColorValue: 0xFF64748B,
    );
  }

  @override
  Future<void> addComment({
    required String groupId,
    String? planId,
    required String passageLabel,
    required String body,
  }) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw StateError('not authenticated');
    await _client.from('group_passage_comments').insert({
      'group_id': groupId,
      'plan_id': planId,
      'passage_label': passageLabel,
      'user_id': uid,
      'body': body.trim(),
    });
  }

  @override
  Future<void> createGroupPlan({
    required String groupId,
    required String title,
    required List<String> passages,
  }) async {
    await _client.rpc(
      'create_group_plan',
      params: {'p_group_id': groupId, 'p_title': title, 'p_passages': passages},
    );
  }

  @override
  Future<List<MemberCarePlan>> listGroupPlans(String groupId) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw StateError('not authenticated');
    final logs = await _client
        .from('reading_logs')
        .select('passage_label')
        .eq('user_id', uid);
    final done = _doneLabels(logs);
    final group = await _client
        .from('groups')
        .select('id, name, plan_id, plan_label')
        .eq('id', groupId)
        .maybeSingle();
    if (group == null) return const [];
    return _plansForGroup(
      uid: uid,
      done: done,
      groupId: groupId,
      groupName: group['name'] as String? ?? 'Grupo',
      fallbackPlanId: group['plan_id'] as String?,
      fallbackLabel: group['plan_label'] as String?,
      includeArchived: true,
      archivedByKey: await _completionsFor(uid),
      seen: <String>{},
    );
  }

  @override
  Future<void> completeGroupPlan({
    required String groupId,
    required String planId,
    required PlanReflection reflection,
  }) async {
    await _client.rpc(
      'complete_group_plan',
      params: {
        'p_group_id': groupId,
        'p_plan_id': planId,
        'p_comment': reflection.comment,
        'p_takeaway': reflection.takeaway,
        'p_understanding': reflection.understanding,
        'p_reception': reflection.reception,
        'p_minutes': reflection.minutes,
      },
    );
  }

  @override
  Future<int> minutesForPassages(List<String> labels) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null || labels.isEmpty) return 1;
    final keys = {for (final label in labels) label.trim().toLowerCase()};
    final logs = await _client
        .from('reading_logs')
        .select('passage_label, minutes')
        .eq('user_id', uid);
    var total = 0;
    for (final log in logs) {
      final label = (log['passage_label'] as String?)?.trim().toLowerCase();
      if (label == null || !keys.contains(label)) continue;
      total += (log['minutes'] as int?) ?? 0;
    }
    return total.clamp(1, 999);
  }
}
