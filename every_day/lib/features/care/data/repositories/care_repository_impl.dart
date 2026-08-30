import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/domain/user_preview.dart';
import '../../domain/entities/care_models.dart';
import '../../domain/repositories/care_repository.dart';

class CareRepositoryImpl implements CareRepository {
  CareRepositoryImpl(this._client);

  final SupabaseClient _client;

  String get _today => DateTime.now().toIso8601String().substring(0, 10);

  @override
  Future<bool> hasCheckedInToday() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return true;
    final row = await _client
        .from('mood_checkins')
        .select('id')
        .eq('user_id', uid)
        .eq('day', _today)
        .maybeSingle();
    return row != null;
  }

  @override
  Future<String> submitCheckin({
    required int score,
    String? body,
    required bool lgpdAccepted,
  }) async {
    final id = await _client.rpc(
      'submit_mood_checkin',
      params: {
        'p_score': score,
        'p_body': body ?? '',
        'p_lgpd': lgpdAccepted,
      },
    );
    return id as String;
  }

  @override
  Future<void> analyzeCheckin(String checkinId) async {
    final response = await _client.functions.invoke(
      'analyze-checkin',
      body: {'checkin_id': checkinId},
    );
    if (response.status >= 400) {
      throw StateError('analyze-checkin failed: ${response.status}');
    }
  }

  @override
  Future<List<CareInboxItem>> listInbox() async {
    final rows = await _client
        .from('mood_checkins')
        .select('id, score, day, status, crisis, body, user_id')
        .inFilter('status', ['needs_care', 'analyzed']);

    final userIds = rows
        .map((row) => row['user_id'] as String)
        .toSet()
        .toList();
    final checkinIds = rows.map((row) => row['id'] as String).toList();

    final profiles = <String, Map<String, dynamic>>{};
    if (userIds.isNotEmpty) {
      final profileRows = await _client
          .from('profiles')
          .select('id, display_name, initials, avatar_color')
          .inFilter('id', userIds);
      for (final profile in profileRows) {
        profiles[profile['id'] as String] = profile;
      }
    }

    final reportsByCheckin = <String, Map<String, dynamic>>{};
    if (checkinIds.isNotEmpty) {
      final reportRows = await _client
          .from('pastoral_reports')
          .select(
            'id, checkin_id, summary, urgency, theme, duration_days, passages, approach_notes',
          )
          .inFilter('checkin_id', checkinIds);
      for (final report in reportRows) {
        reportsByCheckin[report['checkin_id'] as String] = report;
      }
    }

    final items = <CareInboxItem>[];
    for (final row in rows) {
      final userId = row['user_id'] as String;
      final profile = profiles[userId];
      final reportRow = reportsByCheckin[row['id'] as String];
      final name = (profile?['display_name'] as String?)?.trim();

      items.add(
        CareInboxItem(
          checkin: MoodCheckin(
            id: row['id'] as String,
            score: row['score'] as int,
            day: DateTime.parse(row['day'] as String),
            status: careStatusFrom(row['status'] as String?),
            crisis: row['crisis'] as bool? ?? false,
            body: row['body'] as String?,
          ),
          member: UserPreview(
            id: userId,
            displayName: (name == null || name.isEmpty) ? 'Membro' : name,
            initials: (profile?['initials'] as String?) ?? 'M',
            avatarColorValue: profile?['avatar_color'] as int? ?? 0xFF64748B,
          ),
          report: reportRow == null
              ? null
              : PastoralReport(
                  id: reportRow['id'] as String,
                  checkinId: reportRow['checkin_id'] as String,
                  summary: reportRow['summary'] as String,
                  urgency: careUrgencyFrom(reportRow['urgency'] as String?),
                  theme: reportRow['theme'] as String?,
                  durationDays: reportRow['duration_days'] as int?,
                  passages: _stringList(reportRow['passages']),
                  approachNotes: _stringList(reportRow['approach_notes']),
                ),
        ),
      );
    }

    items.sort((a, b) {
      final crisis = (b.checkin.crisis ? 1 : 0).compareTo(a.checkin.crisis ? 1 : 0);
      if (crisis != 0) return crisis;
      final ua = a.report?.urgency.rank ?? 9;
      final ub = b.report?.urgency.rank ?? 9;
      return ua.compareTo(ub);
    });
    return items;
  }

  @override
  Future<void> approvePlan({
    required String reportId,
    required String title,
    required String message,
    required List<String> passages,
    required int durationDays,
  }) async {
    await _client.rpc(
      'approve_care_plan',
      params: {
        'p_report_id': reportId,
        'p_title': title,
        'p_message': message,
        'p_passages': passages,
        'p_duration': durationDays,
      },
    );
  }

  @override
  Future<void> scheduleContact({
    required String reportId,
    required String whenLabel,
    String? note,
  }) async {
    await _client.rpc(
      'schedule_care_contact',
      params: {
        'p_report_id': reportId,
        'p_when': whenLabel,
        'p_note': note ?? '',
      },
    );
  }

  @override
  Future<void> completePlan({
    required String planId,
    required PlanReflection reflection,
  }) async {
    await _client.rpc(
      'complete_care_plan',
      params: {
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
  Future<List<CarePlanInsight>> listReflections({String? userId}) async {
    final filter = _client
        .from('care_plan_reflections')
        .select(
          'id, plan_id, user_id, comment_text, takeaway, understanding, reception, minutes, created_at',
        );
    final rows = await (userId == null
            ? filter.order('created_at', ascending: false).limit(40)
            : filter
                .eq('user_id', userId)
                .order('created_at', ascending: false)
                .limit(40));
    if (rows.isEmpty) return const [];

    final userIds = rows.map((row) => row['user_id'] as String).toSet().toList();
    final planIds = rows.map((row) => row['plan_id'] as String).toSet().toList();

    final names = <String, String>{};
    final profileRows = await _client
        .from('profiles')
        .select('id, display_name')
        .inFilter('id', userIds);
    for (final profile in profileRows) {
      names[profile['id'] as String] = profile['display_name'] as String;
    }

    final titles = <String, String>{};
    final planRows = await _client
        .from('care_plans')
        .select('id, title')
        .inFilter('id', planIds);
    for (final plan in planRows) {
      titles[plan['id'] as String] = plan['title'] as String;
    }

    return [
      for (final row in rows)
        CarePlanInsight(
          id: row['id'] as String,
          planId: row['plan_id'] as String,
          userId: row['user_id'] as String,
          memberName: names[row['user_id'] as String] ?? 'Membro',
          planTitle: titles[row['plan_id'] as String] ?? 'Leitura de cuidado',
          understanding: row['understanding'] as int,
          reception: row['reception'] as String,
          minutes: row['minutes'] as int,
          completedAt: DateTime.parse(row['created_at'] as String).toLocal(),
          comment: row['comment_text'] as String?,
          takeaway: row['takeaway'] as String?,
        ),
    ];
  }

  List<String> _stringList(Object? raw) {
    if (raw is List) {
      return raw.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    }
    return const [];
  }
}
