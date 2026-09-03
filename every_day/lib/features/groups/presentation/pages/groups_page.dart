import 'package:flutter/material.dart';

import '../../../../app/di/app_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/proto.dart';
import '../../domain/entities/reading_group.dart';
import '../../domain/usecases/get_groups.dart';
import '../widgets/direct_reading_sheet.dart';
import 'group_detail_page.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key, this.pastor = false, bool? canDirect})
    : canDirect = canDirect ?? pastor;

  final bool pastor;
  final bool canDirect;

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
    final visibleGroups = groups
        ?.where((group) => _filter == 0 || group.weekProgress < 0.55)
        .toList();
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
                            : 'Grupos que participo',
                        trailing:
                            '${visibleGroups!.length} de ${groups.length}',
                      ),
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: AppColors.slate850,
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(color: AppColors.slate700),
                        ),
                        child: Row(
                          children: [
                            _FilterButton(
                              label: 'Todos',
                              selected: _filter == 0,
                              onTap: () => setState(() => _filter = 0),
                            ),
                            _FilterButton(
                              label: 'Precisa de atenção',
                              selected: _filter == 1,
                              onTap: () => setState(() => _filter = 1),
                            ),
                          ],
                        ),
                      ),
                      if (visibleGroups.isEmpty)
                        const ProtoCard(
                          child: Text(
                            'Nenhum grupo ainda. Peça um convite à liderança.',
                            style: TextStyle(color: AppColors.slate300),
                          ),
                        ),
                      for (final group in visibleGroups) ...[
                        InkWell(
                          onTap: () async {
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
                              await _load(AppScope.of(context).getGroups);
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

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.ember : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? AppColors.slate950 : AppColors.slate400,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
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
