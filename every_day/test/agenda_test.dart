import 'package:every_day/core/domain/user_role.dart';
import 'package:every_day/features/agenda/domain/entities/agenda_event.dart';
import 'package:every_day/features/agenda/domain/repositories/agenda_repository.dart';
import 'package:every_day/features/agenda/domain/usecases/agenda_usecases.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final start = DateTime(2030, 1, 10, 19);

  AgendaEvent event({
    AgendaAudience audience = AgendaAudience.church,
    AgendaEventStatus status = AgendaEventStatus.published,
    String? groupId,
    bool attending = false,
  }) {
    return AgendaEvent(
      id: 'event-1',
      churchId: 'church-1',
      title: 'Culto',
      startsAt: start,
      status: status,
      audience: audience,
      groupId: groupId,
      createdBy: 'pastor-1',
      isAttending: attending,
    );
  }

  group('event validation and relevance', () {
    test('church events are relevant to everyone', () {
      expect(event().isRelevantTo(const {}), isTrue);
    });

    test('group events are relevant only to group members', () {
      final groupEvent = event(
        audience: AgendaAudience.group,
        groupId: 'group-1',
      );
      expect(groupEvent.isRelevantTo({'group-1'}), isTrue);
      expect(groupEvent.isRelevantTo({'group-2'}), isFalse);
    });

    test('draft requires title, a valid interval and target group', () {
      expect(
        AgendaEventDraft(
          title: ' ',
          startsAt: start,
          audience: AgendaAudience.church,
        ).validate(),
        isNotNull,
      );
      expect(
        AgendaEventDraft(
          title: 'Encontro',
          startsAt: start,
          endsAt: start,
          audience: AgendaAudience.church,
        ).validate(),
        isNotNull,
      );
      expect(
        AgendaEventDraft(
          title: 'Encontro',
          startsAt: start,
          audience: AgendaAudience.group,
        ).validate(),
        isNotNull,
      );
      expect(
        AgendaEventDraft(
          title: 'Encontro',
          startsAt: start,
          audience: AgendaAudience.group,
          groupId: 'group-1',
        ).validate(),
        isNull,
      );
    });
  });

  group('role and status rules', () {
    test('only pastors can save and change event status', () async {
      final repository = _RecordingAgendaRepository();
      final draft = AgendaEventDraft(
        title: 'Culto',
        startsAt: start,
        audience: AgendaAudience.church,
      );

      await expectLater(
        SaveAgendaEvent(repository)(role: UserRole.leader, draft: draft),
        throwsStateError,
      );
      expect(
        () => ChangeAgendaEventStatus(repository)(
          role: UserRole.member,
          event: event(status: AgendaEventStatus.draft),
          status: AgendaEventStatus.published,
        ),
        throwsStateError,
      );
      expect(repository.calls, isEmpty);
    });

    test(
      'pastor can publish draft but cannot revive cancelled event',
      () async {
        final repository = _RecordingAgendaRepository();
        final usecase = ChangeAgendaEventStatus(repository);
        await usecase(
          role: UserRole.pastor,
          event: event(status: AgendaEventStatus.draft),
          status: AgendaEventStatus.published,
        );
        expect(repository.calls, ['status:event-1:published']);

        expect(
          () => usecase(
            role: UserRole.pastor,
            event: event(status: AgendaEventStatus.cancelled),
            status: AgendaEventStatus.published,
          ),
          throwsStateError,
        );
        expect(
          () => usecase(
            role: UserRole.pastor,
            event: event(),
            status: AgendaEventStatus.published,
          ),
          throwsStateError,
        );
      },
    );
  });

  group('RSVP contract', () {
    test(
      'member confirmation toggles to the inverse repository value',
      () async {
        final repository = _RecordingAgendaRepository();
        final toggle = ToggleAgendaAttendance(repository);

        await toggle(role: UserRole.member, event: event());
        await toggle(role: UserRole.leader, event: event(attending: true));

        expect(repository.calls, [
          'attendance:event-1:true',
          'attendance:event-1:false',
        ]);
      },
    );

    test('RSVP is rejected for draft events and pastors', () async {
      final repository = _RecordingAgendaRepository();
      final toggle = ToggleAgendaAttendance(repository);
      expect(
        () => toggle(
          role: UserRole.member,
          event: event(status: AgendaEventStatus.draft),
        ),
        throwsStateError,
      );
      expect(
        () => toggle(role: UserRole.pastor, event: event()),
        throwsStateError,
      );
      expect(repository.calls, isEmpty);
    });
  });
}

class _RecordingAgendaRepository implements AgendaRepository {
  final calls = <String>[];

  @override
  Future<String> createEvent(AgendaEventDraft draft) async {
    calls.add('create');
    return 'event-1';
  }

  @override
  Future<List<AgendaEvent>> listEvents() async => const [];

  @override
  Future<void> setAttendance(String eventId, {required bool attending}) async {
    calls.add('attendance:$eventId:$attending');
  }

  @override
  Future<void> setStatus(String eventId, AgendaEventStatus status) async {
    calls.add('status:$eventId:${status.name}');
  }

  @override
  Future<void> updateEvent(String eventId, AgendaEventDraft draft) async {
    calls.add('update');
  }
}
