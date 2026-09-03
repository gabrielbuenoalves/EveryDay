import 'package:flutter/material.dart';

import '../../../../app/di/app_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/proto.dart';
import '../../domain/entities/reading_group.dart';
import '../../domain/usecases/get_groups.dart';
import '../widgets/direct_reading_sheet.dart';
import '../models/group_capabilities.dart';
import 'group_detail_page.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({
    super.key,
    this.pastor = false,
    bool? canDirect,
    this.capabilities = const GroupCapabilities(),
  }) : canDirect = canDirect ?? pastor;

  final bool pastor;
  final bool canDirect;
  final GroupCapabilities capabilities;

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  List<ReadingGroup>? _groups;
  var _filter = 0;
  var _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _load(AppScope.of(context).getGroups);
  }

  Future<void> _load(GetGroups getGroups) async {
    final groups = await getGroups();
    if (!mounted) return;
    setState(() => _groups = groups);
  }

  Future<void> _directReading(ReadingGroup group) async {
    final sent = await showDirectReadingSheet(
      context,
      groupName: group.name,
      onSubmit: ({required title, required passages}) {
        return AppScope.of(
          context,
        ).createGroupPlan(groupId: group.id, title: title, passages: passages);
      },
    );
    if (!sent || !mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Leitura enviada a ${group.name}')));
    await _load(AppScope.of(context).getGroups);
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groups;
    final visibleGroups = widget.pastor
        ? _filter == 0
              ? groups
              : _filter == 1
              ? groups?.where((group) => group.weekProgress < .5).toList()
              : null
        : _filter == 0
        ? groups
        : _filter == 1
        ? widget.capabilities.explore?.map((item) => item.group).toList()
        : widget.capabilities.history?.map((item) => item.group).toList();
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          AppScreenHeader(
            kicker: widget.pastor ? 'Gestão' : 'Comunidade',
            title: widget.pastor ? 'Todos os grupos' : 'Grupos',
          ),
          Expanded(
            child: groups == null
                ? const _GroupsLoading()
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 104),
                    children: [
                      ProtoSection(
                        title: widget.pastor
                            ? 'Todos os grupos'
                            : _filter == 0
                            ? 'Grupos que participo'
                            : _filter == 1
                            ? 'Explorar grupos'
                            : 'Histórico',
                        trailing: visibleGroups == null
                            ? 'indisponível'
                            : '${visibleGroups.length}',
                      ),
                      ProtoFilterBar(
                        labels: widget.pastor
                            ? const [
                                'Todos',
                                'Precisam atenção',
                                'Desafio ativo',
                              ]
                            : const ['Ativos', 'Explorar', 'Histórico'],
                        selected: _filter,
                        onSelected: (value) => setState(() => _filter = value),
                        disabledIndices: widget.pastor
                            ? const <int>{2}
                            : const <int>{},
                      ),
                      const SizedBox(height: 10),
                      if (visibleGroups == null)
                        const ProtoEmptyState(
                          icon: Icons.cloud_off_outlined,
                          title: 'Dados indisponíveis',
                          copy:
                              'Esta visão aguarda integração com a comunidade.',
                        )
                      else if (visibleGroups.isEmpty)
                        ProtoEmptyState(
                          icon: Icons.groups_outlined,
                          title: _filter == 0
                              ? 'Você ainda não participa de grupos'
                              : 'Nenhum grupo nesta visão',
                          copy: _filter == 0
                              ? 'Seus grupos ativos aparecem aqui.'
                              : 'Quando este recurso estiver disponível, os grupos aparecem aqui.',
                        ),
                      for (final group
                          in visibleGroups ?? const <ReadingGroup>[]) ...[
                        InkWell(
                          onTap: () async {
                            final getGroups = AppScope.of(context).getGroups;
                            await Navigator.of(context).push<void>(
                              MaterialPageRoute(
                                builder: (_) => GroupDetailPage(
                                  group: group,
                                  pastor: widget.pastor,
                                  canDirect: widget.canDirect,
                                ),
                              ),
                            );
                            if (mounted) {
                              await _load(getGroups);
                            }
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: ProtoCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MiniLabel(
                                  widget.pastor
                                      ? participationLabel(group.weekProgress)
                                      : group.planLabel,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  group.name,
                                  style: const TextStyle(
                                    color: AppColors.slate100,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.pastor
                                      ? '${group.memberCount} pessoas · ${(group.weekProgress * 100).round()}% acompanhando o desafio'
                                      : '${group.memberCount} pessoas',
                                  style: const TextStyle(
                                    color: AppColors.slate300,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                EmberProgress(value: group.weekProgress),
                                if (group.inviteCode != null &&
                                    group.inviteCode!.isNotEmpty &&
                                    widget.canDirect) ...[
                                  const SizedBox(height: 12),
                                  const MiniLabel('Código do grupo'),
                                  const SizedBox(height: 4),
                                  Text(
                                    group.inviteCode!,
                                    style: const TextStyle(
                                      color: AppColors.slate100,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ],
                                if (widget.canDirect) ...[
                                  const SizedBox(height: 12),
                                  EmberButton(
                                    label: 'Direcionar leitura',
                                    onPressed: () => _directReading(group),
                                  ),
                                ],
                                if (!widget.pastor && _filter == 1) ...[
                                  const SizedBox(height: 10),
                                  EmberButton(
                                    label: widget.capabilities.onJoin == null
                                        ? 'Entrada aguarda integração'
                                        : 'Entrar no grupo',
                                    onPressed:
                                        widget.capabilities.onJoin == null
                                        ? null
                                        : () => widget.capabilities.onJoin!(
                                            group,
                                          ),
                                  ),
                                ],
                                if (!widget.pastor && _filter == 0) ...[
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed:
                                        widget.capabilities.onLeave == null
                                        ? null
                                        : () => widget.capabilities.onLeave!(
                                            group,
                                          ),
                                    child: Text(
                                      widget.capabilities.onLeave == null
                                          ? 'Saída aguarda integração'
                                          : 'Sair do grupo',
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _GroupsLoading extends StatelessWidget {
  const _GroupsLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      children: [
        Container(
          height: 12,
          width: 90,
          decoration: BoxDecoration(
            color: AppColors.slate800,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 28,
          width: 170,
          decoration: BoxDecoration(
            color: AppColors.slate800,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 28),
        for (var i = 0; i < 3; i++) ...[
          const ProtoCard(child: SizedBox(height: 112)),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}
