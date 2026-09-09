import '../entities/agenda_event.dart';

abstract interface class AgendaRepository {
  Future<List<AgendaEvent>> listEvents();

  Future<String> createEvent(AgendaEventDraft draft);

  Future<void> updateEvent(String eventId, AgendaEventDraft draft);

  Future<void> setStatus(String eventId, AgendaEventStatus status);

  Future<void> setAttendance(String eventId, {required bool attending});
}
