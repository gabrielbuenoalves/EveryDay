import 'package:flutter/material.dart';

import '../../../app/state/community_scope.dart';
import '../../../app/state/community_state.dart';
import '../../../core/theme/app_colors.dart';

class _Page extends StatelessWidget {
  const _Page({required this.title, required this.child, this.action});

  final String title;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                // ignore: use_null_aware_elements
                if (action != null) action!,
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              children: [child],
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.color});

  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: color ?? AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.divider),
    ),
    child: child,
  );
}

class _Button extends StatelessWidget {
  const _Button({
    required this.text,
    required this.onTap,
    this.outline = false,
  });

  final String text;
  final VoidCallback onTap;
  final bool outline;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: outline ? AppColors.surfaceHigh : AppColors.orange,
        foregroundColor: AppColors.white,
        side: outline ? const BorderSide(color: AppColors.divider) : null,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(text),
    ),
  );
}

void _feedback(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(backgroundColor: AppColors.surfaceHigh, content: Text(message)),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = CommunityScope.of(context);
    final pastor = state.role == CommunityRole.pastor;
    return _Page(
      title: pastor ? 'Boa noite, Pr. Eduardo' : 'Boa noite, Mateus',
      action: PopupMenuButton<CommunityRole>(
        icon: const Icon(Icons.swap_horiz_rounded, color: AppColors.orange),
        onSelected: state.switchRole,
        itemBuilder: (_) => const [
          PopupMenuItem(
            value: CommunityRole.member,
            child: Text('Visão Membro'),
          ),
          PopupMenuItem(
            value: CommunityRole.pastor,
            child: Text('Visão Pastor'),
          ),
        ],
      ),
      child: pastor ? _PastorHome() : _MemberHome(),
    );
  }
}

class _MemberHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = CommunityScope.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Card(
          color: AppColors.orangeSoft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'VERSÍCULO DO DIA',
                style: TextStyle(
                  color: AppColors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '“A tua palavra é lâmpada para os meus pés.”',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'Salmos 119:105',
                style: TextStyle(color: AppColors.muted),
              ),
            ],
          ),
        ),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SEU DESAFIO ATUAL',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Evangelho de João',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: state.readToday ? .43 : .4,
                color: AppColors.orange,
                backgroundColor: AppColors.surfaceHigh,
              ),
              const SizedBox(height: 8),
              Text(
                state.readToday
                    ? 'Leitura de hoje concluída'
                    : 'Dia 12 de 30  ·  12 capítulos',
                style: const TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 14),
              _Button(
                text: state.readToday
                    ? 'LEITURA CONCLUÍDA'
                    : 'MARCAR LEITURA DE HOJE',
                outline: false,
                onTap: () {
                  state.markReading();
                  _feedback(context, 'Leitura registrada.');
                },
              ),
            ],
          ),
        ),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'REFLEXÃO DO PASTOR',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Permaneça no caminho',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 5),
              const Text(
                'Pequenos encontros diários com Deus mudam a direção de uma vida.',
                style: TextStyle(color: AppColors.muted),
              ),
            ],
          ),
        ),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DO SEU CÍRCULO',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              Text(
                'Ana pediu oração por sua mãe  ·  ${state.prayers} pessoas oraram',
                style: const TextStyle(color: AppColors.muted),
              ),
              TextButton(
                onPressed: () {
                  state.pray();
                  _feedback(context, 'Sua oração foi registrada.');
                },
                child: const Text(
                  'EU OREI POR ISSO',
                  style: TextStyle(color: AppColors.orange),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PastorHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _Card(
        color: AppColors.orangeSoft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'REFLEXÃO DO DIA',
              style: TextStyle(
                color: AppColors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'A presença começa no cuidado.',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _Button(
              text: 'PUBLICAR REFLEXÃO',
              onTap: () =>
                  _feedback(context, 'Reflexão publicada para a comunidade.'),
            ),
          ],
        ),
      ),
      const Text(
        'VISÃO DA COMUNIDADE',
        style: TextStyle(
          color: AppColors.muted,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 10),
      const Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _Metric('124', 'Pessoas conectadas'),
          _Metric('8', 'Grupos ativos'),
          _Metric('72%', 'Participação'),
          _Metric('6', 'Pedidos de oração'),
        ],
      ),
      const SizedBox(height: 14),
      _Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'VISÃO DA SEMANA',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Bar(32),
                _Bar(54),
                _Bar(41),
                _Bar(70),
                _Bar(58),
                _Bar(78),
                _Bar(67),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Leituras concluídas · +12% esta semana',
              style: TextStyle(color: AppColors.muted),
            ),
          ],
        ),
      ),
      _Card(
        color: const Color(0xFF36211F),
        child: Row(
          children: [
            const Icon(Icons.priority_high_rounded, color: AppColors.orange),
            const SizedBox(width: 10),
            const Expanded(child: Text('6 membros precisam de atenção')),
            TextButton(
              onPressed: () => _feedback(context, 'Fila de cuidado aberta'),
              child: const Text(
                'VER',
                style: TextStyle(color: AppColors.orange),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _Metric extends StatelessWidget {
  const _Metric(this.value, this.label);
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 155,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(color: AppColors.orange),
          ),
          Text(
            label,
            style: const TextStyle(color: AppColors.muted, fontSize: 11),
          ),
        ],
      ),
    ),
  );
}

class _Bar extends StatelessWidget {
  const _Bar(this.height);
  final double height;
  @override
  Widget build(BuildContext context) => Container(
    height: height,
    width: 18,
    decoration: BoxDecoration(
      color: AppColors.orange,
      borderRadius: BorderRadius.circular(4),
    ),
  );
}

class GroupsHubPage extends StatelessWidget {
  const GroupsHubPage({super.key});
  @override
  Widget build(BuildContext context) => _Page(
    title: 'Grupos',
    action: IconButton(
      onPressed: () => _feedback(context, 'Novo desafio criado.'),
      icon: const Icon(Icons.add_circle_outline, color: AppColors.orange),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Wrap(
          spacing: 8,
          children: [
            Chip(label: Text('Ativos')),
            Chip(label: Text('Explorar')),
            Chip(label: Text('Histórico')),
          ],
        ),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Jornada em João',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Text(
                '18 membros  ·  desafio ativo',
                style: TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 16),
              const LinearProgressIndicator(
                value: .62,
                color: AppColors.orange,
                backgroundColor: AppColors.surfaceHigh,
              ),
              const SizedBox(height: 12),
              _Button(
                text: 'ABRIR GRUPO',
                onTap: () => _feedback(context, 'Grupo aberto.'),
              ),
            ],
          ),
        ),
        const _Card(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: AppColors.surfaceHigh,
              child: Icon(Icons.groups, color: AppColors.orange),
            ),
            title: Text('Casa Norte'),
            subtitle: Text(
              'Quintas · 20h',
              style: TextStyle(color: AppColors.muted),
            ),
          ),
        ),
      ],
    ),
  );
}

class CarePage extends StatelessWidget {
  const CarePage({super.key});
  @override
  Widget build(BuildContext context) {
    final state = CommunityScope.of(context);
    return _Page(
      title: state.role == CommunityRole.pastor
          ? 'Cuidado pastoral'
          : 'Respostas',
      action: IconButton(
        onPressed: () {
          state.addCare('Novo pedido enviado pela comunidade.');
          _feedback(context, 'Pedido enviado com cuidado.');
        },
        icon: const Icon(Icons.add_circle_outline, color: AppColors.orange),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Wrap(
            spacing: 8,
            children: [
              Chip(label: Text('Todos')),
              Chip(label: Text('Urgente')),
              Chip(label: Text('Oração')),
            ],
          ),
          for (final request in state.careRequests)
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PEDIDO DE ORAÇÃO',
                    style: TextStyle(
                      color: AppColors.orange,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(request),
                  const Divider(color: AppColors.divider),
                  const Text(
                    'Resposta pastoral: estamos com você em oração.',
                    style: TextStyle(color: AppColors.muted),
                  ),
                  TextButton(
                    onPressed: () => _feedback(context, 'Marcado como lido.'),
                    child: const Text('AGRADECER E MARCAR COMO LIDO'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class AgendaPage extends StatelessWidget {
  const AgendaPage({super.key});
  @override
  Widget build(BuildContext context) {
    final state = CommunityScope.of(context);
    return _Page(
      title: 'Agenda',
      action: IconButton(
        onPressed: () => _feedback(context, 'Novo aviso publicado.'),
        icon: const Icon(Icons.add_circle_outline, color: AppColors.orange),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Card(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Date('SEG', '12'),
                _Date('TER', '13'),
                _Date('QUA', '14'),
                _Date('QUI', '15'),
                _Date('SEX', '16'),
              ],
            ),
          ),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Culto de celebração',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Text(
                  'Hoje · 19:30 · Auditório principal',
                  style: TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 12),
                _Button(
                  text: 'VOU',
                  onTap: () {
                    state.rsvp('Culto', 'vou');
                    _feedback(context, 'Presença confirmada.');
                  },
                ),
              ],
            ),
          ),
          const Text(
            'AVISOS DA SEMANA',
            style: TextStyle(color: AppColors.muted, fontSize: 11),
          ),
          const SizedBox(height: 8),
          for (final notice in state.notices) _Card(child: Text(notice)),
        ],
      ),
    );
  }
}

class _Date extends StatelessWidget {
  const _Date(this.day, this.date);
  final String day;
  final String date;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(day, style: const TextStyle(color: AppColors.muted, fontSize: 10)),
      const SizedBox(height: 5),
      CircleAvatar(
        radius: 16,
        backgroundColor: date == '14'
            ? AppColors.orange
            : AppColors.surfaceHigh,
        child: Text(date),
      ),
    ],
  );
}

class ProfileHubPage extends StatelessWidget {
  const ProfileHubPage({super.key});
  @override
  Widget build(BuildContext context) {
    final state = CommunityScope.of(context);
    final pastor = state.role == CommunityRole.pastor;
    return _Page(
      title: pastor ? 'Perfil pastoral' : 'Perfil',
      child: Column(
        children: [
          _Card(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 34,
                  backgroundColor: AppColors.orange,
                  child: Icon(Icons.person, color: AppColors.white, size: 36),
                ),
                const SizedBox(height: 10),
                Text(
                  pastor ? 'Pr. Eduardo Alves' : 'Mateus Silva',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  pastor ? 'Igreja Batista do Centro' : 'Jornada em João',
                  style: const TextStyle(color: AppColors.muted),
                ),
              ],
            ),
          ),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pastor ? 'FERRAMENTAS DO MINISTÉRIO' : 'SEU RITMO',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 14),
                Text(
                  pastor
                      ? 'Relatórios da comunidade\nConfigurações da igreja\nEquipe de aconselhamento'
                      : '12 dias seguidos  ·  46 capítulos  ·  78% consistência',
                  style: const TextStyle(color: AppColors.muted, height: 2),
                ),
              ],
            ),
          ),
          if (!pastor)
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LENDO AGORA',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Evangelho de João · 12 de 21 capítulos',
                    style: TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 8),
                  const LinearProgressIndicator(
                    value: .57,
                    color: AppColors.orange,
                    backgroundColor: AppColors.surfaceHigh,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
