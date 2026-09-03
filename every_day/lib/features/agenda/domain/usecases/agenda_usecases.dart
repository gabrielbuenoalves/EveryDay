import '../../../../core/domain/user_role.dart';
import '../entities/agenda_event.dart';
import '../repositories/agenda_repository.dart';

class GetAgenda {
  const GetAgenda(this.repository);

  final AgendaRepository repository;

  Future<List<AgendaEvent>> call() => repository.listEvents();
}

class SaveAgendaEvent {
  const SaveAgendaEvent(this.repository);

  final AgendaRepository repository;

  Future<String> call({
    required UserRole role,
    required AgendaEventDraft draft,
    String? eventId,
  }) async {
    if (!role.isPastor) {
      throw StateError('Apenas pastores podem gerenciar eventos.');
    }
    final error = draft.validate();
    if (error != null) throw ArgumentError(error);
    if (eventId == null) return repository.createEvent(draft);
    await repository.updateEvent(eventId, draft);
    return eventId;
  }
}

class ChangeAgendaEventStatus {
  const ChangeAgendaEventStatus(this.repository);

  final AgendaRepository repository;

  Future<void> call({
    required UserRole role,
    required AgendaEvent event,
    required AgendaEventStatus status,
  }) {
    if (!role.isPastor) {
      throw StateError('Apenas pastores podem gerenciar eventos.');
    }
    if (event.status == AgendaEventStatus.cancelled) {
      throw StateError('Um evento cancelado não pode ser alterado.');
    }
    if (status == AgendaEventStatus.draft) {
      throw ArgumentError('Um evento não pode voltar para rascunho.');
    }
    if (status == AgendaEventStatus.published &&
        event.status != AgendaEventStatus.draft) {
      throw StateError('Apenas rascunhos podem ser publicados.');
    }
    return repository.setStatus(event.id, status);
  }
}

class ToggleAgendaAttendance {
  const ToggleAgendaAttendance(this.repository);

  final AgendaRepository repository;

  Future<void> call({required UserRole role, required AgendaEvent event}) {
    if (role.isPastor) {
      throw StateError('A confirmação é destinada aos participantes.');
    }
    if (event.status != AgendaEventStatus.published) {
      throw StateError('Só é possível confirmar em eventos publicados.');
    }
    return repository.setAttendance(event.id, attending: !event.isAttending);
  }
}
