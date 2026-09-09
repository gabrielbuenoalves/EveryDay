import 'package:flutter/material.dart';

import '../theme/pastor_theme.dart';
import '../widgets/pastor_widgets.dart';

class PastorGroupsPage extends StatefulWidget {
  const PastorGroupsPage({super.key});

  @override
  State<PastorGroupsPage> createState() => _PastorGroupsPageState();
}

class _PastorGroupsPageState extends State<PastorGroupsPage> {
  var _filter = 0;

  void _openChallenge() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const PastorNewChallengePage()),
    );
  }

  void _openGroup(String name) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PastorGroupDetailPage(groupName: name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PastorScreen(
      children: [
        PastorHeader(
          eyebrow: 'Igreja Vida Nova',
          title: 'Grupos',
          action: PastorCircleButton(
            icon: Icons.add_rounded,
            filled: true,
            semanticLabel: 'Adicionar grupo',
            onTap: _openChallenge,
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          decoration: const InputDecoration(
            hintText: 'Buscar grupo ou líder...',
            prefixIcon: Icon(
              Icons.search_rounded,
              color: PastorPalette.textMuted,
            ),
          ),
        ),
        const SizedBox(height: 16),
        PastorFilterBar(
          labels: const [
            'Todos (12)',
            'Precisam atenção (3)',
            'Desafio ativo (8)',
          ],
          selectedIndex: _filter,
          onSelected: (value) => setState(() => _filter = value),
        ),
        const SizedBox(height: 18),
        const Row(
          children: [
            Expanded(
              child: PastorStatTile(value: '12', label: 'Grupos ativos'),
            ),
            SizedBox(width: 12),
            Expanded(
              child: PastorStatTile(
                value: '247',
                label: 'Membros',
                accent: true,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: PastorStatTile(value: '78%', label: 'Engajamento'),
            ),
          ],
        ),
        const SizedBox(height: 26),
        PastorSurfaceCard(
          borderColor: PastorPalette.orangeBorder,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [PastorPalette.orangeSoft, PastorPalette.background],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  PastorStatusPill(
                    label: 'Novo desafio',
                    icon: Icons.schedule_rounded,
                  ),
                  Spacer(),
                  PastorIconTile(icon: Icons.menu_book_rounded, size: 52),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Lance um desafio de leitura para seus grupos',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(height: 1.35),
              ),
              const SizedBox(height: 8),
              Text(
                'Escolha um livro da Bíblia, defina a meta e engaje toda a comunidade.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              PastorActionButton(
                label: 'Criar novo desafio',
                icon: Icons.arrow_forward_rounded,
                onPressed: _openChallenge,
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        PastorSectionTitle(
          'Seus grupos',
          trailing: Text(
            'Ordenar⌄',
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
        const SizedBox(height: 14),
        _GroupCard(
          name: 'Grupo de Jovens',
          leader: 'Marcos Silva',
          code: '#JOV2024',
          challenge: 'Provérbios',
          progress: .68,
          attention: '3 precisam de atenção',
          icon: Icons.local_fire_department_rounded,
          iconColor: PastorPalette.orange,
          onTap: () => _openGroup('Grupo de Jovens'),
        ),
        const SizedBox(height: 14),
        _GroupCard(
          name: 'Casais em Aliança',
          leader: 'Renata Costa',
          code: '#CAS2024',
          challenge: 'Cânticos',
          progress: .92,
          attention: 'Tudo em dia',
          icon: Icons.favorite_rounded,
          iconColor: PastorPalette.blue,
          healthy: true,
          onTap: () => _openGroup('Casais em Aliança'),
        ),
        const SizedBox(height: 14),
        _GroupCard(
          name: 'Líderes em Formação',
          leader: 'Você',
          code: '#LID2024',
          challenge: 'Tiago',
          progress: .45,
          attention: 'Inicia em 2 dias',
          icon: Icons.workspace_premium_rounded,
          iconColor: PastorPalette.purple,
          onTap: () => _openGroup('Líderes em Formação'),
        ),
        const SizedBox(height: 14),
        PastorMemberListItem(
          name: 'Novos Convertidos',
          subtitle: 'Sem líder designado',
          initials: 'NC',
          trailing: PastorStatusPill(label: 'Definir líder'),
          onTap: () => _openGroup('Novos Convertidos'),
        ),
      ],
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({
    required this.name,
    required this.leader,
    required this.code,
    required this.challenge,
    required this.progress,
    required this.attention,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    this.healthy = false,
  });

  final String name;
  final String leader;
  final String code;
  final String challenge;
  final double progress;
  final String attention;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  final bool healthy;

  @override
  Widget build(BuildContext context) {
    return PastorSurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PastorIconTile(
                icon: icon,
                color: PastorPalette.onPrimary,
                background: iconColor,
                size: 58,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 3),
                    Text(
                      'Líder: $leader',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 7),
                    PastorStatusPill(label: code),
                  ],
                ),
              ),
              const Icon(
                Icons.more_vert_rounded,
                color: PastorPalette.textMuted,
              ),
            ],
          ),
          const SizedBox(height: 17),
          Row(
            children: [
              Text('Desafio: ', style: Theme.of(context).textTheme.bodySmall),
              Expanded(
                child: Text(
                  challenge,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: Theme.of(context).textTheme.labelLarge
                    ?.copyWith(color: PastorPalette.orange),
              ),
            ],
          ),
          const SizedBox(height: 10),
          PastorProgressBar(value: progress),
          const SizedBox(height: 17),
          Row(
            children: [
              const SizedBox(
                width: 80,
                height: 28,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      child: PastorAvatar(initials: 'MS', size: 28),
                    ),
                    Positioned(
                      left: 20,
                      child: PastorAvatar(initials: 'JA', size: 28),
                    ),
                    Positioned(
                      left: 40,
                      child: PastorAvatar(initials: 'PS', size: 28),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Icon(
                healthy ? Icons.check_circle_rounded : Icons.circle,
                size: 11,
                color: healthy ? PastorPalette.success : PastorPalette.orange,
              ),
              const SizedBox(width: 5),
              Text(
                attention,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: healthy ? PastorPalette.success : PastorPalette.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PastorGroupDetailPage extends StatefulWidget {
  const PastorGroupDetailPage({super.key, required this.groupName});

  final String groupName;

  @override
  State<PastorGroupDetailPage> createState() => _PastorGroupDetailPageState();
}

class _PastorGroupDetailPageState extends State<PastorGroupDetailPage> {
  var _tab = 0;

  void _openChallenge() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const PastorNewChallengePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: PastorTheme.data(),
      child: Scaffold(
        backgroundColor: PastorPalette.background,
        body: PastorScreen(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [PastorPalette.plum, PastorPalette.background],
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      PastorCircleButton(
                        icon: Icons.arrow_back_rounded,
                        semanticLabel: 'Voltar',
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      const Spacer(),
                      const PastorCircleButton(
                        icon: Icons.more_horiz_rounded,
                        semanticLabel: 'Mais opções',
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      const PastorIconTile(
                        icon: Icons.local_fire_department_rounded,
                        color: PastorPalette.onPrimary,
                        background: PastorPalette.orange,
                        size: 72,
                      ),
                      const SizedBox(width: 17),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.groupName,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Líder: Marcos Silva · 21 membros',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 8),
                            const PastorStatusPill(label: '#JOV2024'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Row(
                    children: [
                      Expanded(
                        child: PastorStatTile(value: '21', label: 'Membros'),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: PastorStatTile(
                          value: '68%',
                          label: 'Progresso',
                          accent: true,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: PastorStatTile(value: '12d', label: 'Restantes'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                children: [
                  _DetailTabs(
                    selected: _tab,
                    onSelected: (value) => setState(() => _tab = value),
                  ),
                  const SizedBox(height: 22),
                  if (_tab == 0) _ChallengeTab(onNewChallenge: _openChallenge),
                  if (_tab == 1) const _MembersTab(),
                  if (_tab == 2) const _ActivityTab(),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _DetailTabs extends StatelessWidget {
  const _DetailTabs({required this.selected, required this.onSelected});

  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    const labels = ['Desafio', 'Membros', 'Atividade'];
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: PastorPalette.divider)),
      ),
      child: Row(
        children: [
          for (var index = 0; index < labels.length; index++)
            InkWell(
              onTap: () => onSelected(index),
              child: Container(
                constraints: const BoxConstraints(minHeight: 48),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: selected == index
                          ? PastorPalette.orange
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
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
        ],
      ),
    );
  }
}

class _ChallengeTab extends StatelessWidget {
  const _ChallengeTab({required this.onNewChallenge});

  final VoidCallback onNewChallenge;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PastorSurfaceCard(
          child: Column(
            children: [
              Row(
                children: [
                  const PastorIconTile(icon: Icons.menu_book_rounded, size: 48),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Desafio ativo',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          'Livro de Provérbios',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                  const PastorStatusPill(label: '12 dias'),
                ],
              ),
              const SizedBox(height: 19),
              Row(
                children: [
                  Text(
                    'Progresso do grupo',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Text('68%', style: Theme.of(context).textTheme.labelLarge),
                ],
              ),
              const SizedBox(height: 9),
              const PastorProgressBar(value: .68),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: PastorActionButton(
                      label: 'Editar meta',
                      primary: false,
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: PastorActionButton(
                      label: 'Novo desafio',
                      onPressed: onNewChallenge,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 27),
        const PastorSectionTitle('Ranking do grupo'),
        const SizedBox(height: 13),
        const _RankingCard(),
        const SizedBox(height: 27),
        const PastorSectionTitle('Precisam de atenção'),
        const SizedBox(height: 13),
        const PastorMemberListItem(
          name: 'Lucas Martins',
          subtitle: 'Sem atividade há 6 dias',
          initials: 'LM',
          needsAttention: true,
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: PastorPalette.orange,
          ),
        ),
        const SizedBox(height: 27),
        const PastorSectionTitle('Atividade recente'),
        const SizedBox(height: 13),
        const _ActivityTab(),
      ],
    );
  }
}

class _RankingCard extends StatelessWidget {
  const _RankingCard();

  @override
  Widget build(BuildContext context) {
    const entries = [
      ('1º', 'Marcos Silva', '18 capítulos lidos', 'MS'),
      ('2º', 'Juliana Alves', '16 capítulos lidos', 'JA'),
      ('3º', 'Pedro Souza', '14 capítulos lidos', 'PS'),
    ];
    return PastorSurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < entries.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child: Row(
                children: [
                  SizedBox(
                    width: 35,
                    child: Text(
                      entries[i].$1,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: i == 0
                            ? PastorPalette.orange
                            : PastorPalette.textMuted,
                      ),
                    ),
                  ),
                  PastorAvatar(initials: entries[i].$4, size: 39),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entries[i].$2,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          entries[i].$3,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (i != entries.length - 1)
              const Divider(height: 1, color: PastorPalette.divider),
          ],
        ],
      ),
    );
  }
}

class _MembersTab extends StatelessWidget {
  const _MembersTab();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        PastorMemberListItem(
          name: 'Marcos Silva',
          subtitle: 'Líder · 18 capítulos lidos',
          initials: 'MS',
        ),
        SizedBox(height: 12),
        PastorMemberListItem(
          name: 'Juliana Alves',
          subtitle: 'Membro · 16 capítulos lidos',
          initials: 'JA',
        ),
        SizedBox(height: 12),
        PastorMemberListItem(
          name: 'Lucas Martins',
          subtitle: 'Precisa de atenção',
          initials: 'LM',
          needsAttention: true,
        ),
      ],
    );
  }
}

class _ActivityTab extends StatelessWidget {
  const _ActivityTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PastorMemberListItem(
          name: 'Juliana Alves',
          subtitle: 'Completou o capítulo 12 · Há 2 horas',
          initials: 'JA',
        ),
        const SizedBox(height: 12),
        PastorMemberListItem(
          name: 'Pedro Souza',
          subtitle: 'Deixou um comentário · Há 5 horas',
          initials: 'PS',
        ),
      ],
    );
  }
}

class PastorNewChallengePage extends StatefulWidget {
  const PastorNewChallengePage({super.key});

  @override
  State<PastorNewChallengePage> createState() => _PastorNewChallengePageState();
}

class _PastorNewChallengePageState extends State<PastorNewChallengePage> {
  static const _books = ['Tiago', 'Provérbios', 'Salmos', 'Filipenses'];
  var _book = 0;
  var _dailyGoal = 1;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: PastorTheme.data(),
      child: Scaffold(
        backgroundColor: PastorPalette.background,
        body: PastorScreen(
          children: [
            PastorHeader(
              title: 'Novo Desafio',
              centered: true,
              action: PastorCircleButton(
                icon: Icons.close_rounded,
                semanticLabel: 'Fechar',
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(height: 25),
            const PastorFieldLabel('Grupo'),
            const PastorMemberListItem(
              name: 'Grupo de Jovens',
              subtitle: '21 membros',
              initials: 'GJ',
              trailing: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: PastorPalette.textMuted,
              ),
            ),
            const SizedBox(height: 25),
            const PastorFieldLabel('Livro da Bíblia'),
            TextFormField(
              initialValue: _books[_book],
              decoration: const InputDecoration(
                suffixIcon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: PastorPalette.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 13),
            PastorFilterBar(
              labels: _books,
              selectedIndex: _book,
              onSelected: (value) => setState(() => _book = value),
            ),
            const SizedBox(height: 25),
            const PastorFieldLabel('Período do desafio'),
            Row(
              children: [
                Expanded(
                  child: _DateCard(label: 'Início', value: '05 Set'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateCard(label: 'Término', value: '17 Set'),
                ),
              ],
            ),
            const SizedBox(height: 25),
            const PastorFieldLabel('Meta diária'),
            PastorSurfaceCard(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              radius: 17,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Capítulos por dia',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  _GoalButton(
                    icon: Icons.remove_rounded,
                    onTap: () => setState(
                      () => _dailyGoal = (_dailyGoal - 1).clamp(1, 9),
                    ),
                  ),
                  SizedBox(
                    width: 45,
                    child: Text(
                      '$_dailyGoal',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(color: PastorPalette.orange),
                    ),
                  ),
                  _GoalButton(
                    icon: Icons.add_rounded,
                    primary: true,
                    onTap: () => setState(
                      () => _dailyGoal = (_dailyGoal + 1).clamp(1, 9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            const PastorFieldLabel('Mensagem de motivação (opcional)'),
            const TextField(
              minLines: 3,
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    'Escreva uma palavra para engajar o grupo nesse desafio...',
              ),
            ),
            const SizedBox(height: 25),
            const PastorFieldLabel('Prévia'),
            PastorSurfaceCard(
              borderColor: PastorPalette.orangeBorder,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PastorIconTile(icon: Icons.menu_book_rounded),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Desafio: ${_books[_book]}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '05 – 17 Set · $_dailyGoal cap/dia',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Visível para os 21 membros do Grupo de Jovens.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 34),
            PastorActionButton(
              label: 'Lançar desafio para o grupo',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateCard extends StatelessWidget {
  const _DateCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return PastorSurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      radius: 17,
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

class _GoalButton extends StatelessWidget {
  const _GoalButton({
    required this.icon,
    required this.onTap,
    this.primary = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: primary ? PastorPalette.orange : PastorPalette.secondaryButton,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            icon,
            color: primary ? PastorPalette.onPrimary : PastorPalette.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}
