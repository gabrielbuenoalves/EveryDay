import '../../domain/entities/agenda_event.dart';

enum AgendaEntryKind { event, notice }

/// Optional UI capability boundary for notices and notification preferences.
/// No notice is rendered or persisted until an integration provides this data.
class AgendaPresentation {
  const AgendaPresentation({
    this.notices,
    this.onCreateNotice,
    this.pushNotificationsEnabled,
    this.onPushNotificationsChanged,
  });

  final List<AgendaEvent>? notices;
  final void Function()? onCreateNotice;
  final bool? pushNotificationsEnabled;
  final void Function(bool enabled)? onPushNotificationsChanged;
}
