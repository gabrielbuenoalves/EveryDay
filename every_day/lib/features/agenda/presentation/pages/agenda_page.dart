import 'package:flutter/material.dart';

import '../../../../app/di/app_scope.dart';
import '../../../../core/domain/user_role.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/proto.dart';
import '../../../groups/domain/entities/reading_group.dart';
import '../../domain/entities/agenda_event.dart';
import '../models/agenda_capabilities.dart';

class AgendaPage extends StatefulWidget {
  const AgendaPage({
    super.key,
    required this.role,
    this.presentation = const AgendaPresentation(),
  });

  final UserRole role;
  final AgendaPresentation presentation;

  @override
  State<AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  List<AgendaEvent>? _events;
  Object? _error;
  var _started = false;
  var _monthMode = false;
  DateTime _selectedDay = DateTime.now();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final events = await AppScope.of(context).getAgenda();
      if (!mounted) return;
      setState(() => _events = events);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _events = const [];
      });
    }
  }

  Future<void> _edit([AgendaEvent? event]) async {
    try {
      final groups = await AppScope.of(context).getGroups();
      if (!mounted) return;
      final draft = await showModalBottomSheet<AgendaEventDraft>(
        context: context,
        isScrollControlled: true,
        backgroundColor: AppColors.slate800,
        builder: (_) => _EventEditor(event: event, groups: groups),
      );
      if (draft == null || !mounted) return;
      await AppScope.of(context)
          .saveAgendaEvent(role: widget.role, draft: draft, eventId: event?.id);
      await _load();
    } catch (error) {
      _message(error);
    }
  }

  Future<void> _status(AgendaEvent event, AgendaEventStatus status) async {
    try {
      await AppScope.of(context).changeAgendaEventStatus(
        role: widget.role,
        event: event,
        status: status,
      );
      await _load();
    } catch (error) {
      _message(error);
    }
  }

  Future<void> _setAttendance(AgendaEvent event, bool attending) async {
    if (event.isAttending == attending) return;
    try {
      await AppScope.of(context)
          .toggleAgendaAttendance(role: widget.role, event: event);
      await _load();
    } catch (error) {
      _message(error);
    }
  }

  void _message(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final events = _events;
    final selectedEvents =
        events
            ?.where((event) => _sameDay(event.startsAt, _selectedDay))
            .toList() ??
        const <AgendaEvent>[];
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          AppScreenHeader(
            kicker: widget.role.isPastor ? 'Gestão' : 'Comunidade',
            title: 'Agenda',
            action: widget.role.isPastor
                ? IconButton(
                    tooltip: 'Criar evento',
                    onPressed: _edit,
                    icon: const Icon(Icons.add, color: AppColors.ember),
                  )
                : null,
          ),
          Expanded(
            child: events == null
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.ember),
                  )
                : RefreshIndicator(
                    color: AppColors.ember,
                    onRefresh: _load,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
                      children: [
                        Row(
                          children: [
                            ChoiceChip(
                              label: const Text('Semana'),
                              selected: !_monthMode,
                              onSelected: (_) =>
                                  setState(() => _monthMode = false),
                            ),
                            const SizedBox(width: 8),
                            ChoiceChip(
                              label: const Text('Mês'),
                              selected: _monthMode,
                              onSelected: (_) =>
                                  setState(() => _monthMode = true),
                            ),
                          ],
                        ),
                        _AgendaCalendar(
                          selectedDay: _selectedDay,
                          monthMode: _monthMode,
                          onSelected: (value) =>
                              setState(() => _selectedDay = value),
                          eventDays: events
                              .where(
                                (event) =>
                                    event.status != AgendaEventStatus.cancelled,
                              )
                              .map(
                                (event) => DateTime(
                                  event.startsAt.year,
                                  event.startsAt.month,
                                  event.startsAt.day,
                                ),
                              )
                              .toSet(),
                        ),
                        if (_error != null)
                          _StateCard(
                            icon: Icons.cloud_off_outlined,
                            text: 'Não foi possível carregar a agenda.',
                            action: _load,
                          )
                        else if (events.isEmpty)
                          const _StateCard(
                            icon: Icons.event_available_outlined,
                            text: 'Nenhum evento na agenda.',
                          )
                        else ...[
                          ProtoSection(
                            title: 'Eventos em ${_date(_selectedDay)}',
                            trailing: '${selectedEvents.length}',
                          ),
                          if (selectedEvents.isEmpty)
                            const _StateCard(
                              icon: Icons.event_outlined,
                              text: 'Nenhum evento neste dia.',
                            ),
                          for (final event in selectedEvents) ...[
                            _EventCard(
                              event: event,
                              pastor: widget.role.isPastor,
                              onEdit: () => _edit(event),
                              onPublish: () =>
                                  _status(event, AgendaEventStatus.published),
                              onCancel: () =>
                                  _status(event, AgendaEventStatus.cancelled),
                              onGoing: () => _setAttendance(event, true),
                              onNotGoing: () => _setAttendance(event, false),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ],
                        ProtoSection(
                          title: 'Avisos da semana',
                          trailing: widget.presentation.notices == null
                              ? 'indisponível'
                              : '${widget.presentation.notices!.length}',
                        ),
                        if (widget.presentation.notices == null)
                          const _StateCard(
                            icon: Icons.campaign_outlined,
                            text: 'Avisos aguardam integração de dados. Eventos continuam funcionando normalmente.',
                          )
                        else if (widget.presentation.notices!.isEmpty)
                          const _StateCard(
                            icon: Icons.campaign_outlined,
                            text: 'Nenhum aviso publicado nesta semana.',
                          )
                        else
                          for (final notice
                              in widget.presentation.notices!) ...[
                            _NoticeCard(notice: notice),
                            const SizedBox(height: 10),
                          ],
                        if (widget.role.isPastor)
                          OutlinedButton.icon(
                            onPressed: widget.presentation.onCreateNotice,
                            icon: const Icon(Icons.add_alert_outlined),
                            label: Text(
                              widget.presentation.onCreateNotice == null
                                  ? 'CRIAR AVISO · AGUARDA INTEGRAÇÃO'
                                  : 'CRIAR AVISO',
                            ),
                          ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value:
                              widget.presentation.pushNotificationsEnabled ??
                              false,
                          onChanged:
                              widget.presentation.onPushNotificationsChanged,
                          title: const Text('Notificações push'),
                          subtitle: Text(
                            widget.presentation.onPushNotificationsChanged ==
                                    null
                                ? 'Preferência aguarda integração de dados.'
                                : 'Receber lembretes de eventos e avisos.',
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.event,
    required this.pastor,
    required this.onEdit,
    required this.onPublish,
    required this.onCancel,
    required this.onGoing,
    required this.onNotGoing,
  });

  final AgendaEvent event;
  final bool pastor;
  final VoidCallback onEdit;
  final VoidCallback onPublish;
  final VoidCallback onCancel;
  final VoidCallback onGoing;
  final VoidCallback onNotGoing;

  @override
  Widget build(BuildContext context) {
    final active = event.status != AgendaEventStatus.cancelled;
    return Opacity(
      opacity: active ? 1 : .55,
      child: ProtoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: MiniLabel(_audience)),
                _StatusChip(status: event.status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0x20FF5C16),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${event.startsAt.day}',
                        style: const TextStyle(
                          color: AppColors.ember,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        _month(event.startsAt),
                        style: const TextStyle(
                          color: AppColors.slate400,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    event.title,
                    style: const TextStyle(
                      color: AppColors.slate100,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            _Detail(icon: Icons.schedule, text: _date(event.startsAt)),
            if (event.location != null)
              _Detail(icon: Icons.place_outlined, text: event.location!),
            if (event.description != null) ...[
              const SizedBox(height: 8),
              Text(
                event.description!,
                style: const TextStyle(
                  color: AppColors.slate300,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
            if (pastor) ...[
              const SizedBox(height: 12),
              Text(
                '${event.attendeeCount} ${event.attendeeCount == 1 ? 'presença confirmada' : 'presenças confirmadas'}',
                style: const TextStyle(color: AppColors.slate400, fontSize: 11),
              ),
            ] else if (event.isAttending) ...[
              const SizedBox(height: 12),
              const Text(
                'Sua presença está confirmada',
                style: TextStyle(color: AppColors.slate400, fontSize: 11),
              ),
            ],
            if (pastor && active) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  TextButton(onPressed: onEdit, child: const Text('Editar')),
                  if (event.status == AgendaEventStatus.draft)
                    TextButton(
                      onPressed: onPublish,
                      child: const Text('Publicar'),
                    ),
                  TextButton(
                    onPressed: onCancel,
                    child: const Text(
                      'Cancelar evento',
                      style: TextStyle(color: AppColors.danger),
                    ),
                  ),
                ],
              ),
            ] else if (!pastor &&
                event.status == AgendaEventStatus.published) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: EmberButton(
                      expand: true,
                      label: 'VOU',
                      onPressed: event.isAttending ? null : onGoing,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 40,
                    child: OutlinedButton(
                      onPressed: event.isAttending ? onNotGoing : null,
                      child: const Text('NÃO VOU'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String get _audience => event.audience == AgendaAudience.church
      ? 'Toda a igreja'
      : event.groupName ?? 'Grupo';
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({required this.notice});

  final AgendaEvent notice;

  @override
  Widget build(BuildContext context) {
    final description = notice.description;
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.slate850,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MiniLabel('Aviso'),
          const SizedBox(height: 5),
          Text(
            notice.title,
            style: const TextStyle(
              color: AppColors.slate100,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (description != null && description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(color: AppColors.slate300, fontSize: 11),
            ),
          ],
        ],
      ),
    );
  }
}

class _AgendaCalendar extends StatelessWidget {
  const _AgendaCalendar({
    required this.eventDays,
    required this.selectedDay,
    required this.monthMode,
    required this.onSelected,
  });

  final Set<DateTime> eventDays;
  final DateTime selectedDay;
  final bool monthMode;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final start = monthMode
        ? DateTime(selectedDay.year, selectedDay.month, 1)
        : selectedDay.subtract(Duration(days: selectedDay.weekday - 1));
    const labels = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 8),
      child: Wrap(
        children: List.generate(
          monthMode
              ? DateTime(selectedDay.year, selectedDay.month + 1, 0).day
              : 7,
          (index) {
            final day = start.add(Duration(days: index));
            final selected = _sameDay(day, selectedDay);
            final marked = eventDays.contains(
              DateTime(day.year, day.month, day.day),
            );
            return SizedBox(
              width: MediaQuery.sizeOf(context).width / 7 - 5,
              child: Column(
                children: [
                  Text(
                    labels[index],
                    style: const TextStyle(
                      color: AppColors.slate400,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 7),
                  InkWell(
                    onTap: () => onSelected(day),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 32,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected ? AppColors.ember : AppColors.slate800,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected
                              ? AppColors.ember
                              : AppColors.slate700,
                        ),
                      ),
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: selected
                              ? AppColors.slate950
                              : AppColors.slate100,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 4,
                    width: 4,
                    decoration: BoxDecoration(
                      color: marked ? AppColors.ember : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Row(
      children: [
        Icon(icon, color: AppColors.ember, size: 15),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: AppColors.slate300, fontSize: 12),
          ),
        ),
      ],
    ),
  );
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final AgendaEventStatus status;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      AgendaEventStatus.draft => 'Rascunho',
      AgendaEventStatus.published => 'Publicado',
      AgendaEventStatus.cancelled => 'Cancelado',
    };
    return Text(
      label,
      style: TextStyle(
        color: status == AgendaEventStatus.cancelled
            ? AppColors.danger
            : AppColors.slate400,
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({required this.icon, required this.text, this.action});
  final IconData icon;
  final String text;
  final VoidCallback? action;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 36),
    child: ProtoCard(
      child: Column(
        children: [
          Icon(icon, color: AppColors.slate400, size: 32),
          const SizedBox(height: 10),
          Text(text, style: const TextStyle(color: AppColors.slate300)),
          if (action != null)
            TextButton(
              onPressed: action,
              child: const Text('Tentar novamente'),
            ),
        ],
      ),
    ),
  );
}

class _EventEditor extends StatefulWidget {
  const _EventEditor({required this.groups, this.event});
  final List<ReadingGroup> groups;
  final AgendaEvent? event;

  @override
  State<_EventEditor> createState() => _EventEditorState();
}

class _EventEditorState extends State<_EventEditor> {
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _location;
  late DateTime _startsAt;
  DateTime? _endsAt;
  late AgendaAudience _audience;
  String? _groupId;
  String? _error;

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    _title = TextEditingController(text: event?.title);
    _description = TextEditingController(text: event?.description);
    _location = TextEditingController(text: event?.location);
    _startsAt = event?.startsAt ?? DateTime.now().add(const Duration(days: 1));
    _endsAt = event?.endsAt;
    _audience = event?.audience ?? AgendaAudience.church;
    _groupId = event?.groupId;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<DateTime?> _pickDateTime(DateTime initial) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (date == null || !mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _pickStart() async {
    final value = await _pickDateTime(_startsAt);
    if (value == null || !mounted) return;
    setState(() => _startsAt = value);
  }

  Future<void> _pickEnd() async {
    final value = await _pickDateTime(
      _endsAt ?? _startsAt.add(const Duration(hours: 1)),
    );
    if (value == null || !mounted) return;
    setState(() => _endsAt = value);
  }

  void _save() {
    final draft = AgendaEventDraft(
      title: _title.text,
      description: _description.text,
      location: _location.text,
      startsAt: _startsAt,
      endsAt: _endsAt,
      audience: _audience,
      groupId: _groupId,
    );
    final error = draft.validate();
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.pop(context, draft);
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.event == null ? 'Novo evento' : 'Editar evento',
              style: const TextStyle(
                color: AppColors.slate100,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            const MiniLabel('Evento'),
            const SizedBox(height: 8),
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: _description,
              decoration: const InputDecoration(labelText: 'Descrição'),
              maxLines: 2,
            ),
            TextField(
              controller: _location,
              decoration: const InputDecoration(labelText: 'Local'),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule, color: AppColors.ember),
              subtitle: const Text('Início'),
              title: Text(
                _date(_startsAt),
                style: const TextStyle(color: AppColors.slate100),
              ),
              onTap: _pickStart,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_busy, color: AppColors.ember),
              subtitle: const Text('Término opcional'),
              title: Text(
                _endsAt == null ? 'Sem horário de término' : _date(_endsAt!),
                style: const TextStyle(color: AppColors.slate100),
              ),
              trailing: _endsAt == null
                  ? null
                  : IconButton(
                      tooltip: 'Remover término',
                      onPressed: () => setState(() => _endsAt = null),
                      icon: const Icon(Icons.close, color: AppColors.slate400),
                    ),
              onTap: _pickEnd,
            ),
            DropdownButtonFormField<AgendaAudience>(
              initialValue: _audience,
              decoration: const InputDecoration(labelText: 'Público'),
              items: const [
                DropdownMenuItem(
                  value: AgendaAudience.church,
                  child: Text('Toda a igreja'),
                ),
                DropdownMenuItem(
                  value: AgendaAudience.group,
                  child: Text('Grupo específico'),
                ),
              ],
              onChanged: (value) => setState(() => _audience = value!),
            ),
            if (_audience == AgendaAudience.group)
              DropdownButtonFormField<String>(
                initialValue: _groupId,
                decoration: const InputDecoration(labelText: 'Grupo'),
                items: [
                  for (final group in widget.groups)
                    DropdownMenuItem(value: group.id, child: Text(group.name)),
                ],
                onChanged: (value) => setState(() => _groupId = value),
              ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: const TextStyle(color: AppColors.danger)),
            ],
            const SizedBox(height: 20),
            EmberButton(
              expand: true,
              label: widget.event == null ? 'Criar rascunho' : 'Salvar',
              onPressed: _save,
            ),
          ],
        ),
      ),
    ),
  );
}

String _date(DateTime value) {
  const months = [
    'jan',
    'fev',
    'mar',
    'abr',
    'mai',
    'jun',
    'jul',
    'ago',
    'set',
    'out',
    'nov',
    'dez',
  ];
  final minute = value.minute.toString().padLeft(2, '0');
  return '${value.day} ${months[value.month - 1]} · ${value.hour}:$minute';
}

String _month(DateTime value) {
  const months = [
    'JAN',
    'FEV',
    'MAR',
    'ABR',
    'MAI',
    'JUN',
    'JUL',
    'AGO',
    'SET',
    'OUT',
    'NOV',
    'DEZ',
  ];
  return months[value.month - 1];
}

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
