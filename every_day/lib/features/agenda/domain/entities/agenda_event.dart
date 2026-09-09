enum AgendaEventStatus { draft, published, cancelled }

enum AgendaAudience { church, group }

class AgendaEvent {
  const AgendaEvent({
    required this.id,
    required this.churchId,
    required this.title,
    required this.startsAt,
    required this.status,
    required this.audience,
    required this.createdBy,
    this.description,
    this.location,
    this.endsAt,
    this.groupId,
    this.groupName,
    this.isAttending = false,
    this.attendeeCount = 0,
  });

  final String id;
  final String churchId;
  final String title;
  final String? description;
  final String? location;
  final DateTime startsAt;
  final DateTime? endsAt;
  final AgendaEventStatus status;
  final AgendaAudience audience;
  final String? groupId;
  final String? groupName;
  final String createdBy;
  final bool isAttending;
  final int attendeeCount;

  bool isRelevantTo(Set<String> memberGroupIds) =>
      audience == AgendaAudience.church ||
      (groupId != null && memberGroupIds.contains(groupId));

  AgendaEvent copyWith({
    AgendaEventStatus? status,
    bool? isAttending,
    int? attendeeCount,
  }) {
    return AgendaEvent(
      id: id,
      churchId: churchId,
      title: title,
      startsAt: startsAt,
      status: status ?? this.status,
      audience: audience,
      createdBy: createdBy,
      description: description,
      location: location,
      endsAt: endsAt,
      groupId: groupId,
      groupName: groupName,
      isAttending: isAttending ?? this.isAttending,
      attendeeCount: attendeeCount ?? this.attendeeCount,
    );
  }
}

class AgendaEventDraft {
  const AgendaEventDraft({
    required this.title,
    required this.startsAt,
    required this.audience,
    this.description,
    this.location,
    this.endsAt,
    this.groupId,
  });

  final String title;
  final String? description;
  final String? location;
  final DateTime startsAt;
  final DateTime? endsAt;
  final AgendaAudience audience;
  final String? groupId;

  String? validate() {
    if (title.trim().isEmpty) return 'Informe o título do evento.';
    if (title.trim().length > 200) {
      return 'O título deve ter no máximo 200 caracteres.';
    }
    if (endsAt != null && !endsAt!.isAfter(startsAt)) {
      return 'O término deve ser depois do início.';
    }
    if (audience == AgendaAudience.group &&
        (groupId == null || groupId!.trim().isEmpty)) {
      return 'Selecione um grupo.';
    }
    return null;
  }
}
