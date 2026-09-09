import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/agenda_event.dart';
import '../../domain/repositories/agenda_repository.dart';

class AgendaRepositoryImpl implements AgendaRepository {
  AgendaRepositoryImpl(this._client);

  final SupabaseClient _client;

  String get _uid {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw StateError('not authenticated');
    return id;
  }

  @override
  Future<List<AgendaEvent>> listEvents() async {
    final uid = _uid;
    final profile = await _client
        .from('profiles')
        .select('church_id, role')
        .eq('id', uid)
        .single();
    final churchId = profile['church_id'] as String?;
    if (churchId == null) return const [];
    final pastor = profile['role'] == 'pastor';

    final memberships = await _client
        .from('group_members')
        .select('group_id')
        .eq('user_id', uid);
    final groupIds = memberships
        .map((row) => row['group_id'] as String)
        .toSet();

    final rows = await _client
        .from('events')
        .select('*, groups(name), event_rsvps(user_id, status)')
        .eq('church_id', churchId)
        .gte('starts_at', DateTime.now().toUtc().toIso8601String())
        .order('starts_at');
    final events = rows.map((row) => _event(row, uid)).where((event) {
      return pastor || event.isRelevantTo(groupIds);
    }).toList();
    return events;
  }

  @override
  Future<String> createEvent(AgendaEventDraft draft) async {
    final result = await _client.rpc('create_event', params: _params(draft));
    return result as String;
  }

  @override
  Future<void> updateEvent(String eventId, AgendaEventDraft draft) async {
    await _client.rpc(
      'update_event',
      params: {'p_event_id': eventId, ..._params(draft)},
    );
  }

  @override
  Future<void> setStatus(String eventId, AgendaEventStatus status) async {
    final rpc = switch (status) {
      AgendaEventStatus.published => 'publish_event',
      AgendaEventStatus.cancelled => 'cancel_event',
      AgendaEventStatus.draft => throw ArgumentError('invalid event status'),
    };
    await _client.rpc(rpc, params: {'p_event_id': eventId});
  }

  @override
  Future<void> setAttendance(String eventId, {required bool attending}) async {
    if (attending) {
      await _client.rpc(
        'set_event_rsvp',
        params: {'p_event_id': eventId, 'p_status': 'going'},
      );
    } else {
      await _client.rpc('delete_event_rsvp', params: {'p_event_id': eventId});
    }
  }

  Map<String, dynamic> _params(AgendaEventDraft draft) {
    return {
      'p_title': draft.title.trim(),
      'p_description': _nullable(draft.description),
      'p_location': _nullable(draft.location),
      'p_starts_at': draft.startsAt.toUtc().toIso8601String(),
      'p_ends_at': draft.endsAt?.toUtc().toIso8601String(),
      'p_group_id': draft.audience == AgendaAudience.group
          ? draft.groupId
          : null,
    };
  }

  AgendaEvent _event(Map<String, dynamic> row, String uid) {
    final rsvps = (row['event_rsvps'] as List?) ?? const [];
    final going = rsvps.where((item) => item['status'] == 'going').toList();
    final group = row['groups'] as Map<String, dynamic>?;
    return AgendaEvent(
      id: row['id'] as String,
      churchId: row['church_id'] as String,
      title: row['title'] as String,
      description: row['description'] as String?,
      location: row['location'] as String?,
      startsAt: DateTime.parse(row['starts_at'] as String).toLocal(),
      endsAt: row['ends_at'] == null
          ? null
          : DateTime.parse(row['ends_at'] as String).toLocal(),
      status: AgendaEventStatus.values.byName(row['status'] as String),
      audience: row['group_id'] == null
          ? AgendaAudience.church
          : AgendaAudience.group,
      groupId: row['group_id'] as String?,
      groupName: group?['name'] as String?,
      createdBy: row['created_by'] as String,
      isAttending: going.any((item) => item['user_id'] == uid),
      attendeeCount: going.length,
    );
  }

  String? _nullable(String? value) {
    final result = value?.trim();
    return result == null || result.isEmpty ? null : result;
  }
}
