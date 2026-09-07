import 'package:flutter/material.dart';

import '../theme/pastor_theme.dart';
import '../widgets/pastor_widgets.dart';

class PastorDashboardPage extends StatelessWidget {
  const PastorDashboardPage({
    super.key,
    required this.onOpenCare,
    required this.onCreateChallenge,
    required this.onCreateNotice,
  });

  final VoidCallback onOpenCare;
  final VoidCallback onCreateChallenge;
  final VoidCallback onCreateNotice;

  @override
  Widget build(BuildContext context) {
    return PastorScreen(
      children: [
        Row(
          children: [
            const PastorAvatar(
              initials: 'ER',
              size: 50,
              color: PastorPalette.accentDark,
              highlight: true,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bem-vindo,',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Pr. Eduardo',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                const PastorCircleButton(
                  icon: Icons.notifications_none_rounded,
                  semanticLabel: 'Notificações',
                ),
                Positioned(
                  right: 10,
                  top: 9,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: PastorPalette.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        PastorSurfaceCard(
          borderColor: PastorPalette.orangeBorder,
          padding: const EdgeInsets.all(22),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [PastorPalette.orangeSoft, PastorPalette.background],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const PastorStatusPill(label: 'Reflexão do dia'),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Visível para todos',
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                '“A fé é a certeza daquilo que esperamos e a prova das coisas que não vemos.”',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Hebreus 11:1',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  PastorActionButton(
                    label: 'Publicar',
                    onPressed: () {},
                    expand: false,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 124,
                child: PastorMetricCard(
                  value: '247',
                  label: 'Pessoas conectadas',
                  icon: Icons.people_alt_rounded,
                  onTap: onOpenCare,
                ),
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: SizedBox(
                height: 124,
                child: PastorMetricCard(
                  value: '12',
                  label: 'Grupos ativos',
                  icon: Icons.groups_rounded,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            const Expanded(
              child: SizedBox(
                height: 124,
                child: PastorMetricCard(
                  value: '78%',
                  label: 'Participação leitura',
                  icon: Icons.auto_stories_rounded,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: SizedBox(
                height: 124,
                child: PastorMetricCard(
                  value: '8',
                  label: 'Pedidos de oração',
                  icon: Icons.volunteer_activism_rounded,
                  onTap: onOpenCare,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        const _WeeklyOverviewCard(),
        const SizedBox(height: 26),
        PastorSurfaceCard(
          onTap: onOpenCare,
          borderColor: PastorPalette.orangeBorder,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
          child: Row(
            children: [
              const PastorIconTile(icon: Icons.favorite_rounded, size: 46),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '3 membros precisam de atenção',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Sentimentos identificados nas últimas 48h',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: PastorPalette.textMuted,
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const PastorSectionTitle('Ações rápidas'),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _QuickAction(
                icon: Icons.menu_book_rounded,
                label: 'Novo desafio',
                onTap: onCreateChallenge,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _QuickAction(
                icon: Icons.campaign_rounded,
                label: 'Criar aviso',
                onTap: onCreateNotice,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WeeklyOverviewCard extends StatelessWidget {
  const _WeeklyOverviewCard();

  static const _values = [40.0, 55.0, 48.0, 70.0, 62.0, 85.0, 78.0];
  static const _days = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

  @override
  Widget build(BuildContext context) {
    return PastorSurfaceCard(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Visão da semana',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                '+14% vs semana passada',
                style: Theme.of(context).textTheme.labelMedium
                    ?.copyWith(color: PastorPalette.orange),
              ),
            ],
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 176,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < _values.length; i++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: FractionallySizedBox(
                                heightFactor: _values[i] / 100,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: PastorPalette.orange,
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _days[i],
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PastorSurfaceCard(
      onTap: onTap,
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PastorIconTile(icon: icon, size: 42),
          const SizedBox(height: 14),
          Text(label, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}
