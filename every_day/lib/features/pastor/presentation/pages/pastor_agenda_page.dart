import 'package:flutter/material.dart';

import '../theme/pastor_theme.dart';
import '../widgets/pastor_widgets.dart';

class PastorAgendaPage extends StatefulWidget {
  const PastorAgendaPage({super.key});

  @override
  State<PastorAgendaPage> createState() => _PastorAgendaPageState();
}

class _PastorAgendaPageState extends State<PastorAgendaPage> {
  var _section = 0;
  var _calendarMode = 1;

  void _openNewNotice() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const PastorNewNoticePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PastorScreen(
      children: [
        PastorHeader(
          eyebrow: 'Setembro 2026',
          title: 'Agenda',
          action: PastorCircleButton(
            icon: Icons.add_rounded,
            filled: true,
            semanticLabel: 'Criar aviso ou evento',
            onTap: _openNewNotice,
          ),
        ),
        const SizedBox(height: 22),
        _SegmentedControl(
          labels: const ['Calendário', 'Meus avisos'],
          selected: _section,
          onSelected: (value) => setState(() => _section = value),
        ),
        const SizedBox(height: 14),
        if (_section == 0) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              PastorChoiceChip(
                label: 'Mês',
                selected: _calendarMode == 0,
                onTap: () => setState(() => _calendarMode = 0),
              ),
              const SizedBox(width: 8),
              PastorChoiceChip(
                label: 'Semana',
                selected: _calendarMode == 1,
                onTap: () => setState(() => _calendarMode = 1),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_calendarMode == 0)
            const _MonthCalendar()
          else
            const _WeekCalendar(),
          const SizedBox(height: 18),
          _CreateNoticeHero(onTap: _openNewNotice),
          const SizedBox(height: 26),
          const PastorSectionTitle('Hoje, 03 Set'),
          const SizedBox(height: 13),
          const _AgendaEventCard(
            time: '19:30',
            title: 'Encontro Grupo de Jovens',
            subtitle: 'Salão Principal · Você é o líder',
            accent: true,
          ),
          const SizedBox(height: 12),
          const _AgendaEventCard(
            time: '21:00',
            title: 'Vigília de oração',
            subtitle: 'Online · Toda a igreja',
          ),
        ],
        if (_section == 1) ...[
          _CreateNoticeHero(onTap: _openNewNotice),
          const SizedBox(height: 26),
        ],
        const SizedBox(height: 26),
        const PastorSectionTitle('Próximos avisos publicados'),
        const SizedBox(height: 13),
        const _NoticeRow(
          title: 'Culto de Batismo',
          subtitle: '05 Set · 18h · Templo Principal',
          published: true,
        ),
        const SizedBox(height: 11),
        const _NoticeRow(
          title: 'Almoço de Confraternização',
          subtitle: '06 Set · 12h · Salão Social',
          published: false,
        ),
      ],
    );
  }
}

class _SegmentedControl extends StatelessWidget {
  const _SegmentedControl({
    required this.labels,
    required this.selected,
    required this.onSelected,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: PastorPalette.surfaceStrong,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (var index = 0; index < labels.length; index++)
            Expanded(
              child: Material(
                color: selected == index
                    ? PastorPalette.orange
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () => onSelected(index),
                  borderRadius: BorderRadius.circular(10),
                  child: Center(
                    child: Text(
                      labels[index],
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: selected == index
                            ? PastorPalette.onPrimary
                            : PastorPalette.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _WeekCalendar extends StatelessWidget {
  const _WeekCalendar();

  @override
  Widget build(BuildContext context) {
    const days = [
      ('Seg', '31'),
      ('Ter', '01'),
      ('Qua', '02'),
      ('Qui', '03'),
      ('Sex', '04'),
      ('Sáb', '05'),
      ('Dom', '06'),
    ];
    return Row(
      children: [
        for (var index = 0; index < days.length; index++)
          Expanded(
            child: Container(
              height: 68,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: index == 3 ? PastorPalette.orange : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    days[index].$1,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: index == 3
                          ? PastorPalette.onPrimary
                          : PastorPalette.textMuted,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    days[index].$2,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  if (index == 5 || index == 6) ...[
                    const SizedBox(height: 4),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        color: PastorPalette.orange,
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox(width: 4, height: 4),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _MonthCalendar extends StatelessWidget {
  const _MonthCalendar();

  @override
  Widget build(BuildContext context) {
    const weekdays = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
    final days = List<int>.generate(35, (index) => index - 1);
    return PastorSurfaceCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              for (final day in weekdays)
                Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisExtent: 40,
            ),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final value = days[index];
              final visible = value > 0 && value <= 30;
              final selected = value == 3;
              return Center(
                child: Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? PastorPalette.orange : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    visible ? '$value' : '',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: selected
                          ? PastorPalette.onPrimary
                          : PastorPalette.textSoft,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CreateNoticeHero extends StatelessWidget {
  const _CreateNoticeHero({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PastorSurfaceCard(
      borderColor: PastorPalette.orangeBorder,
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [PastorPalette.orangeSoft, PastorPalette.background],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const PastorIconTile(icon: Icons.campaign_rounded, size: 48),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Criar um aviso',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Comunique toda a igreja ou um grupo',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          PastorActionButton(label: 'Novo aviso ou evento', onPressed: onTap),
        ],
      ),
    );
  }
}

class _AgendaEventCard extends StatelessWidget {
  const _AgendaEventCard({
    required this.time,
    required this.title,
    required this.subtitle,
    this.accent = false,
  });

  final String time;
  final String title;
  final String subtitle;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return PastorSurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 49,
            height: 49,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent
                  ? PastorPalette.orangeSoft
                  : PastorPalette.secondaryButton,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Text(
              time,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: accent ? PastorPalette.orange : PastorPalette.white,
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: PastorPalette.textMuted,
          ),
        ],
      ),
    );
  }
}

class _NoticeRow extends StatelessWidget {
  const _NoticeRow({
    required this.title,
    required this.subtitle,
    required this.published,
  });

  final String title;
  final String subtitle;
  final bool published;

  @override
  Widget build(BuildContext context) {
    return PastorSurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          const PastorIconTile(icon: Icons.campaign_rounded, size: 43),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 3),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          PastorStatusPill(
            label: published ? 'Publicado' : 'Rascunho',
            tone: published ? PastorStatusTone.green : PastorStatusTone.neutral,
          ),
        ],
      ),
    );
  }
}

class PastorNewNoticePage extends StatefulWidget {
  const PastorNewNoticePage({super.key});

  @override
  State<PastorNewNoticePage> createState() => _PastorNewNoticePageState();
}

class _PastorNewNoticePageState extends State<PastorNewNoticePage> {
  var _type = 0;
  var _audience = 0;
  var _pushEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: PastorTheme.data(),
      child: Scaffold(
        backgroundColor: PastorPalette.background,
        body: PastorScreen(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 118),
          children: [
            PastorHeader(
              title: 'Novo Aviso',
              centered: true,
              action: PastorCircleButton(
                icon: Icons.close_rounded,
                semanticLabel: 'Fechar',
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(height: 25),
            const PastorFieldLabel('Tipo'),
            _SegmentedControl(
              labels: const ['Aviso', 'Evento'],
              selected: _type,
              onSelected: (value) => setState(() => _type = value),
            ),
            const SizedBox(height: 25),
            const PastorFieldLabel('Título'),
            const TextField(
              decoration: InputDecoration(hintText: 'Ex: Culto de Batismo'),
            ),
            const SizedBox(height: 22),
            const PastorFieldLabel('Descrição'),
            const TextField(
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Detalhes sobre o aviso ou evento...',
              ),
            ),
            const SizedBox(height: 22),
            const PastorFieldLabel('Data e horário'),
            const Row(
              children: [
                Expanded(
                  child: _DateInput(label: 'Data', value: '05 Set'),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _DateInput(label: 'Horário', value: '18:00'),
                ),
              ],
            ),
            const SizedBox(height: 22),
            const PastorFieldLabel('Local'),
            const TextField(
              decoration: InputDecoration(hintText: 'Ex: Templo Principal'),
            ),
            const SizedBox(height: 22),
            const PastorFieldLabel('Enviar para'),
            PastorFilterBar(
              labels: const [
                'Toda a igreja',
                'Grupo de Jovens',
                'Casais em Aliança',
              ],
              selectedIndex: _audience,
              onSelected: (value) => setState(() => _audience = value),
            ),
            const SizedBox(height: 24),
            PastorSurfaceCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child: Row(
                children: [
                  const PastorIconTile(
                    icon: Icons.notifications_active_outlined,
                    size: 43,
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enviar notificação push',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'Avisar membros imediatamente',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _pushEnabled,
                    onChanged: (value) => setState(() => _pushEnabled = value),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: _FormActionBar(
          secondaryLabel: 'Salvar rascunho',
          primaryLabel: 'Publicar',
          onSecondary: () => Navigator.of(context).pop(),
          onPrimary: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}

class _DateInput extends StatelessWidget {
  const _DateInput({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return PastorSurfaceCard(
      radius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _FormActionBar extends StatelessWidget {
  const _FormActionBar({
    required this.secondaryLabel,
    required this.primaryLabel,
    required this.onSecondary,
    required this.onPrimary,
  });

  final String secondaryLabel;
  final String primaryLabel;
  final VoidCallback onSecondary;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: PastorPalette.background,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: PastorPalette.divider)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 390),
              child: Row(
                children: [
                  Expanded(
                    child: PastorActionButton(
                      label: secondaryLabel,
                      primary: false,
                      onPressed: onSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PastorActionButton(
                      label: primaryLabel,
                      onPressed: onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
