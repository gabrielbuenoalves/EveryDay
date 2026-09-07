import 'package:flutter/material.dart';

import '../theme/pastor_theme.dart';
import '../widgets/pastor_widgets.dart';

class PastorProfilePage extends StatefulWidget {
  const PastorProfilePage({super.key});

  @override
  State<PastorProfilePage> createState() => _PastorProfilePageState();
}

class _PastorProfilePageState extends State<PastorProfilePage> {
  var _careNotifications = true;

  void _openMembers() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const PastorMembersPage()));
  }

  Future<void> _showEditProfile() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: PastorPalette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Theme(
        data: PastorTheme.data(),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              14,
              20,
              MediaQuery.viewInsetsOf(sheetContext).bottom + 22,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: PastorPalette.textMuted,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Editar dados pessoais',
                    style: Theme.of(sheetContext).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 22),
                  const PastorFieldLabel('Nome'),
                  const TextField(
                    decoration: InputDecoration(hintText: 'Pr. Eduardo Ramos'),
                  ),
                  const SizedBox(height: 16),
                  const PastorFieldLabel('E-mail'),
                  const TextField(
                    decoration: InputDecoration(
                      hintText: 'eduardo@vidanova.org',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const PastorFieldLabel('Telefone'),
                  const TextField(
                    decoration: InputDecoration(hintText: '(11) 99999-0000'),
                  ),
                  const SizedBox(height: 24),
                  PastorActionButton(
                    label: 'Salvar alterações',
                    onPressed: () => Navigator.of(sheetContext).pop(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PastorScreen(
      padding: EdgeInsets.zero,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [PastorPalette.orangeSoft, PastorPalette.background],
            ),
          ),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Perfil',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 28),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  const PastorAvatar(
                    initials: 'ER',
                    size: 88,
                    color: PastorPalette.textMuted,
                    highlight: true,
                  ),
                  Positioned(
                    right: -2,
                    bottom: 2,
                    child: Container(
                      width: 31,
                      height: 31,
                      decoration: BoxDecoration(
                        color: PastorPalette.orange,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: PastorPalette.background,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.verified_rounded,
                        size: 16,
                        color: PastorPalette.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Pr. Eduardo Ramos',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 5),
              Text(
                'Pastor titular · Igreja Vida Nova',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              const PastorStatusPill(label: 'Liderança sênior'),
              const SizedBox(height: 16),
              PastorActionButton(
                label: 'Editar perfil',
                onPressed: _showEditProfile,
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 34),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Expanded(
                    child: PastorStatTile(value: '247', label: 'Membros'),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: PastorStatTile(
                      value: '12',
                      label: 'Grupos',
                      accent: true,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: PastorStatTile(
                      value: '6 anos',
                      label: 'De liderança',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 27),
              const PastorSectionTitle('Igreja'),
              const SizedBox(height: 10),
              const _InfoPanel(
                rows: [
                  _InfoRow(
                    icon: Icons.church_outlined,
                    value: 'Igreja Vida Nova',
                    label: 'Nome da congregação',
                  ),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    value: 'Av. das Palmeiras, 450',
                    label: 'Endereço',
                  ),
                  _InfoRow(
                    icon: Icons.mail_outline_rounded,
                    value: 'eduardo@vidanova.org',
                    label: 'E-mail de contato',
                  ),
                ],
              ),
              const SizedBox(height: 27),
              const PastorSectionTitle('Ferramentas do ministério'),
              const SizedBox(height: 12),
              _MinistryTools(onOpenMembers: _openMembers),
              const SizedBox(height: 27),
              const PastorSectionTitle('Preferências'),
              const SizedBox(height: 12),
              PastorSurfaceCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _PreferenceRow(
                      icon: Icons.notifications_active_outlined,
                      label: 'Notificações de cuidado',
                      trailing: Switch(
                        value: _careNotifications,
                        onChanged: (value) =>
                            setState(() => _careNotifications = value),
                      ),
                    ),
                    const Divider(height: 1, color: PastorPalette.divider),
                    const _PreferenceRow(
                      icon: Icons.shield_outlined,
                      label: 'Privacidade e segurança',
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: PastorPalette.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: const Text('Sair da conta'),
                  style: TextButton.styleFrom(
                    foregroundColor: PastorPalette.orange,
                    minimumSize: const Size(48, 48),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.rows});

  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    return PastorSurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var index = 0; index < rows.length; index++) ...[
            rows[index],
            if (index != rows.length - 1)
              const Divider(height: 1, color: PastorPalette.divider),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: PastorPalette.textMuted),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: Theme.of(context).textTheme.bodyLarge),
                Text(label, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MinistryTools extends StatelessWidget {
  const _MinistryTools({required this.onOpenMembers});

  final VoidCallback onOpenMembers;

  @override
  Widget build(BuildContext context) {
    final tools = <(IconData, String, VoidCallback?)>[
      (Icons.people_alt_outlined, 'Diretório de membros', onOpenMembers),
      (Icons.lightbulb_outline_rounded, 'Reflexões publicadas', null),
      (Icons.menu_book_outlined, 'Desafios criados', null),
      (Icons.badge_outlined, 'Equipe de liderança', onOpenMembers),
      (Icons.insert_chart_outlined_rounded, 'Relatórios da igreja', null),
    ];
    return PastorSurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var index = 0; index < tools.length; index++) ...[
            InkWell(
              onTap: tools[index].$3,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 58),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 11,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        tools[index].$1,
                        size: 21,
                        color: index == 0
                            ? PastorPalette.orange
                            : PastorPalette.textMuted,
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Text(
                          tools[index].$2,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: PastorPalette.textMuted,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (index != tools.length - 1)
              const Divider(height: 1, color: PastorPalette.divider),
          ],
        ],
      ),
    );
  }
}

class _PreferenceRow extends StatelessWidget {
  const _PreferenceRow({
    required this.icon,
    required this.label,
    required this.trailing,
  });

  final IconData icon;
  final String label;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 60),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(icon, size: 21, color: PastorPalette.textMuted),
            const SizedBox(width: 13),
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

class PastorMembersPage extends StatefulWidget {
  const PastorMembersPage({super.key});

  @override
  State<PastorMembersPage> createState() => _PastorMembersPageState();
}

class _PastorMembersPageState extends State<PastorMembersPage> {
  var _filter = 0;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: PastorTheme.data(),
      child: Scaffold(
        backgroundColor: PastorPalette.background,
        body: PastorScreen(
          children: [
            PastorHeader(
              eyebrow: 'Igreja Vida Nova',
              title: 'Membros',
              action: PastorCircleButton(
                icon: Icons.close_rounded,
                semanticLabel: 'Fechar diretório',
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(height: 24),
            const TextField(
              decoration: InputDecoration(
                hintText: 'Buscar membro...',
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: PastorPalette.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 16),
            PastorFilterBar(
              labels: const [
                'Todos (247)',
                'Novos (30d)',
                'Sem grupo',
                'Líderes',
              ],
              selectedIndex: _filter,
              onSelected: (value) => setState(() => _filter = value),
            ),
            const SizedBox(height: 18),
            const Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 124,
                    child: PastorMetricCard(
                      value: '247',
                      label: 'Total de membros',
                      icon: Icons.people_alt_rounded,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 124,
                    child: PastorMetricCard(
                      value: '14',
                      label: 'Novos este mês',
                      icon: Icons.person_add_alt_1_rounded,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 124,
                    child: PastorMetricCard(
                      value: '19',
                      label: 'Sem grupo',
                      icon: Icons.person_search_rounded,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 124,
                    child: PastorMetricCard(
                      value: '12',
                      label: 'Líderes ativos',
                      icon: Icons.workspace_premium_outlined,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            PastorSectionTitle(
              'Lista de membros',
              trailing: Text(
                'A–Z',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
            const SizedBox(height: 13),
            const PastorMemberListItem(
              name: 'Marcos Silva',
              subtitle: 'Grupo de Jovens · Líder',
              initials: 'MS',
            ),
            const SizedBox(height: 11),
            const PastorMemberListItem(
              name: 'Juliana Alves',
              subtitle: 'Grupo de Jovens · Membro',
              initials: 'JA',
            ),
            const SizedBox(height: 11),
            const PastorMemberListItem(
              name: 'Lucas Martins',
              subtitle: 'Precisa de atenção',
              initials: 'LM',
              needsAttention: true,
            ),
            const SizedBox(height: 11),
            const PastorMemberListItem(
              name: 'Marta Oliveira',
              subtitle: 'Casais em Aliança · Membro',
              initials: 'MO',
            ),
            const SizedBox(height: 11),
            const PastorMemberListItem(
              name: 'Pedro Souza',
              subtitle: 'Líderes em Formação · Membro',
              initials: 'PS',
            ),
            const SizedBox(height: 11),
            const PastorMemberListItem(
              name: 'Rafael Nunes',
              subtitle: 'Sem grupo · Novo membro',
              initials: 'RN',
              trailing: PastorStatusPill(label: 'Adicionar'),
            ),
          ],
        ),
      ),
    );
  }
}
