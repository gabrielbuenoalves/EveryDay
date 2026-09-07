import 'package:flutter/material.dart';

import '../theme/pastor_theme.dart';
import '../widgets/pastor_widgets.dart';

class PastorCarePage extends StatefulWidget {
  const PastorCarePage({super.key});

  @override
  State<PastorCarePage> createState() => _PastorCarePageState();
}

class _PastorCarePageState extends State<PastorCarePage> {
  var _filter = 0;

  void _openRequest({String name = 'Lucas Martins'}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PastorCareDetailPage(memberName: name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showUrgent = _filter == 0 || _filter == 1;
    final showPrayer = _filter == 0 || _filter == 2;
    final showAnswered = _filter == 0 || _filter == 3;

    return PastorScreen(
      children: [
        const PastorHeader(
          eyebrow: 'Cuidado Pastoral',
          title: 'Avisos',
          action: PastorCircleButton(
            icon: Icons.notifications_none_rounded,
            semanticLabel: 'Notificações de cuidado',
          ),
        ),
        const SizedBox(height: 25),
        PastorFilterBar(
          labels: const [
            'Todos (11)',
            'Urgentes (3)',
            'Oração (5)',
            'Respondidos',
          ],
          selectedIndex: _filter,
          onSelected: (value) => setState(() => _filter = value),
        ),
        const SizedBox(height: 18),
        const Row(
          children: [
            Expanded(
              child: PastorStatTile(
                value: '3',
                label: 'Urgentes',
                accent: true,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: PastorStatTile(value: '5', label: 'Pedidos oração'),
            ),
            SizedBox(width: 12),
            Expanded(
              child: PastorStatTile(value: '8', label: 'Respondidos hoje'),
            ),
          ],
        ),
        if (showUrgent) ...[
          const SizedBox(height: 28),
          const PastorSectionTitle('Precisam de atenção'),
          const SizedBox(height: 14),
          PastorCareRequestCard(
            name: 'Lucas Martins',
            group: 'Grupo de Jovens',
            time: 'Há 3h',
            initials: 'LM',
            status: 'Angustiado',
            excerpt: '“Estou passando por um momento difícil no trabalho e não sei como lidar...”',
            urgent: true,
            onOpen: () => _openRequest(),
          ),
          const SizedBox(height: 14),
          PastorCareRequestCard(
            name: 'Marta Oliveira',
            group: 'Casais em Aliança',
            time: 'Há 6h',
            initials: 'MO',
            status: 'Doente',
            excerpt: '“Peço oração pela minha recuperação, fiz uma cirurgia essa semana.”',
            urgent: true,
            onOpen: () => _openRequest(name: 'Marta Oliveira'),
          ),
        ],
        if (showPrayer) ...[
          const SizedBox(height: 28),
          const PastorSectionTitle('Pedidos de oração'),
          const SizedBox(height: 14),
          PastorCareRequestCard(
            name: 'Juliana Alves',
            group: 'Grupo de Jovens',
            time: 'Há 1 dia',
            initials: 'JA',
            status: 'Família',
            excerpt:
                '“Oração pela restauração do relacionamento com meus pais.”',
            onOpen: () => _openRequest(name: 'Juliana Alves'),
          ),
        ],
        if (showAnswered) ...[
          const SizedBox(height: 28),
          const PastorSectionTitle('Respondidos'),
          const SizedBox(height: 14),
          const PastorMemberListItem(
            name: 'Pedro Souza',
            subtitle: 'Respondido há 2 dias',
            initials: 'PS',
            trailing: PastorStatusPill(
              label: 'Respondido',
              tone: PastorStatusTone.green,
            ),
          ),
        ],
      ],
    );
  }
}

class PastorCareRequestCard extends StatelessWidget {
  const PastorCareRequestCard({
    super.key,
    required this.name,
    required this.group,
    required this.time,
    required this.initials,
    required this.status,
    required this.excerpt,
    required this.onOpen,
    this.urgent = false,
  });

  final String name;
  final String group;
  final String time;
  final String initials;
  final String status;
  final String excerpt;
  final VoidCallback onOpen;
  final bool urgent;

  @override
  Widget build(BuildContext context) {
    return PastorSurfaceCard(
      borderColor: urgent ? PastorPalette.orangeBorder : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PastorAvatar(
                initials: initials,
                size: 49,
                color: urgent
                    ? PastorPalette.orange
                    : PastorPalette.accentDark,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: Theme.of(context).textTheme.titleMedium),
                    Text(group, style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 7),
                    PastorStatusPill(
                      label: status,
                      tone: urgent
                          ? PastorStatusTone.orange
                          : PastorStatusTone.blue,
                    ),
                  ],
                ),
              ),
              Text(time, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 13),
          Padding(
            padding: const EdgeInsets.only(left: 62),
            child: Text(
              excerpt,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(fontStyle: FontStyle.italic, height: 1.55),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: PastorActionButton(
                  label: 'Ver detalhes',
                  primary: false,
                  onPressed: onOpen,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PastorActionButton(
                  label: 'Responder',
                  onPressed: onOpen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PastorCareDetailPage extends StatefulWidget {
  const PastorCareDetailPage({super.key, required this.memberName});

  final String memberName;

  @override
  State<PastorCareDetailPage> createState() => _PastorCareDetailPageState();
}

class _PastorCareDetailPageState extends State<PastorCareDetailPage> {
  var _responseMode = 0;
  var _editingAnalysis = false;
  var _editingReadings = false;
  var _followUp = false;

  final _analysisController = TextEditingController(
    text: 'Lucas demonstra sinais de estresse ocupacional e ansiedade. Este é o 2º relato similar em 30 dias. Recomenda-se contato pastoral direto e acompanhamento próximo do líder de grupo.',
  );
  final _messageController = TextEditingController();
  final _readings = <(String, String)>[
    ('Filipenses 4:6-7', 'Sobre ansiedade e paz'),
    ('Salmos 55:22', 'Entregar as cargas a Deus'),
  ];

  @override
  void dispose() {
    _analysisController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _sendAndClose() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: PastorTheme.data(),
      child: Scaffold(
        backgroundColor: PastorPalette.background,
        body: PastorScreen(
          children: [
            PastorHeader(
              title: 'Cuidado Pastoral',
              centered: true,
              action: PastorCircleButton(
                icon: Icons.more_horiz_rounded,
                semanticLabel: 'Mais opções',
                onTap: () {},
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Transform.translate(
                offset: const Offset(0, -48),
                child: PastorCircleButton(
                  icon: Icons.arrow_back_rounded,
                  semanticLabel: 'Voltar',
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -28),
              child: Row(
                children: [
                  const PastorAvatar(
                    initials: 'LM',
                    size: 68,
                    color: PastorPalette.orange,
                    highlight: true,
                  ),
                  const SizedBox(width: 17),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.memberName,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Grupo de Jovens · 24 anos',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 9),
                        const PastorStatusPill(label: 'Angustiado'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -10),
              child: PastorSurfaceCard(
                borderColor: PastorPalette.orangeBorder,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Relato enviado · há 3 horas',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '“Estou passando por um momento difícil no trabalho e não sei como lidar com toda essa pressão. Peço oração para ter sabedoria e paz nesse período.”',
                      style: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(fontStyle: FontStyle.italic, height: 1.55),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            PastorSurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const PastorIconTile(
                        icon: Icons.auto_awesome_rounded,
                        size: 42,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Análise da IA',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        tooltip: _editingAnalysis
                            ? 'Salvar análise'
                            : 'Editar análise',
                        onPressed: () => setState(
                          () => _editingAnalysis = !_editingAnalysis,
                        ),
                        icon: Icon(
                          _editingAnalysis
                              ? Icons.check_rounded
                              : Icons.edit_outlined,
                          color: PastorPalette.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_editingAnalysis)
                    TextField(
                      controller: _analysisController,
                      minLines: 4,
                      maxLines: 7,
                      decoration: const InputDecoration(
                        helperText: 'Revise o texto sugerido antes de enviar.',
                      ),
                    )
                  else
                    Text(
                      _analysisController.text,
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(height: 1.55),
                    ),
                  const SizedBox(height: 14),
                  const Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      PastorStatusPill(label: 'Prioridade alta'),
                      PastorStatusPill(
                        label: '2ª ocorrência',
                        tone: PastorStatusTone.neutral,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 27),
            PastorSectionTitle(
              'Leituras recomendadas',
              trailing: TextButton.icon(
                onPressed: () =>
                    setState(() => _editingReadings = !_editingReadings),
                icon: Icon(
                  _editingReadings ? Icons.check_rounded : Icons.edit_outlined,
                  size: 17,
                ),
                label: Text(_editingReadings ? 'Concluir' : 'Editar'),
                style: TextButton.styleFrom(
                  foregroundColor: PastorPalette.orange,
                  minimumSize: const Size(48, 48),
                ),
              ),
            ),
            const SizedBox(height: 12),
            for (var index = 0; index < _readings.length; index++) ...[
              _ReadingRecommendation(
                title: _readings[index].$1,
                subtitle: _readings[index].$2,
                editing: _editingReadings,
                onRemove: () => setState(() => _readings.removeAt(index)),
              ),
              if (index != _readings.length - 1) const SizedBox(height: 11),
            ],
            if (_editingReadings) ...[
              const SizedBox(height: 11),
              PastorActionButton(
                label: 'Adicionar passagem',
                icon: Icons.add_rounded,
                primary: false,
                onPressed: () => setState(
                  () =>
                      _readings.add(('João 14:27', 'A paz que Cristo oferece')),
                ),
              ),
            ],
            const SizedBox(height: 28),
            const PastorSectionTitle('Responder ao pedido'),
            const SizedBox(height: 12),
            PastorSurfaceCard(
              borderColor: PastorPalette.orangeBorder,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PastorFilterBar(
                    labels: const [
                      'Mensagem',
                      'Agendar ligação',
                      'Visita pastoral',
                    ],
                    selectedIndex: _responseMode,
                    onSelected: (value) =>
                        setState(() => _responseMode = value),
                  ),
                  const SizedBox(height: 16),
                  if (_responseMode == 0)
                    _MessageResponse(
                      controller: _messageController,
                      followUp: _followUp,
                      onFollowUpChanged: (value) =>
                          setState(() => _followUp = value),
                      onSend: _sendAndClose,
                    ),
                  if (_responseMode == 1)
                    _ContactResponse(
                      icon: Icons.call_outlined,
                      title: 'Agendar ligação',
                      description:
                          'Defina o melhor horário para falar com o membro.',
                      actionLabel: 'Confirmar ligação',
                      onConfirm: _sendAndClose,
                    ),
                  if (_responseMode == 2)
                    _ContactResponse(
                      icon: Icons.home_work_outlined,
                      title: 'Visita pastoral',
                      description:
                          'Combine uma visita e registre a orientação.',
                      actionLabel: 'Agendar visita',
                      onConfirm: _sendAndClose,
                      showLocation: true,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Center(
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: PastorPalette.textMuted,
                  minimumSize: const Size(48, 48),
                ),
                child: const Text('Encaminhar para equipe de aconselhamento'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadingRecommendation extends StatelessWidget {
  const _ReadingRecommendation({
    required this.title,
    required this.subtitle,
    required this.editing,
    required this.onRemove,
  });

  final String title;
  final String subtitle;
  final bool editing;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return PastorSurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      radius: 17,
      child: Row(
        children: [
          const PastorIconTile(icon: Icons.menu_book_rounded, size: 45),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          if (editing)
            IconButton(
              tooltip: 'Remover leitura',
              onPressed: onRemove,
              icon: const Icon(
                Icons.close_rounded,
                color: PastorPalette.orange,
              ),
            )
          else
            const Icon(
              Icons.chevron_right_rounded,
              color: PastorPalette.textMuted,
            ),
        ],
      ),
    );
  }
}

class _MessageResponse extends StatelessWidget {
  const _MessageResponse({
    required this.controller,
    required this.followUp,
    required this.onFollowUpChanged,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool followUp;
  final ValueChanged<bool> onFollowUpChanged;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          minLines: 4,
          maxLines: 7,
          decoration: const InputDecoration(
            hintText: 'Escreva uma palavra de encorajamento e oração...',
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            PastorChoiceChip(
              label: '“Estou orando por você”',
              selected: false,
              onTap: () => controller.text = 'Estou orando por você.',
            ),
            PastorChoiceChip(
              label: 'Enviar versículo',
              selected: false,
              onTap: () => controller.text =
                  '${controller.text}\n\n“Lancem sobre ele toda a sua ansiedade.” — 1 Pedro 5:7',
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => onFollowUpChanged(!followUp),
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: PastorPalette.secondaryButton,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        followUp
                            ? Icons.check_circle_rounded
                            : Icons.schedule_rounded,
                        color: followUp
                            ? PastorPalette.orange
                            : PastorPalette.white,
                        size: 18,
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          'Marcar follow-up',
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: PastorActionButton(
                label: 'Enviar resposta',
                onPressed: onSend,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ContactResponse extends StatelessWidget {
  const _ContactResponse({
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onConfirm,
    this.showLocation = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onConfirm;
  final bool showLocation;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            PastorIconTile(icon: icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Row(
          children: [
            Expanded(
              child: TextField(decoration: InputDecoration(hintText: '05 Set')),
            ),
            SizedBox(width: 10),
            Expanded(
              child: TextField(decoration: InputDecoration(hintText: '18:00')),
            ),
          ],
        ),
        if (showLocation) ...[
          const SizedBox(height: 10),
          const TextField(
            decoration: InputDecoration(hintText: 'Local da visita'),
          ),
        ],
        const SizedBox(height: 14),
        PastorActionButton(label: actionLabel, onPressed: onConfirm),
      ],
    );
  }
}
