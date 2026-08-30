import 'package:flutter/material.dart';

import '../../../../app/di/app_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/proto.dart';
import '../../domain/entities/reading_group.dart';
import '../../domain/usecases/get_groups.dart';
import '../widgets/direct_reading_sheet.dart';
import 'group_detail_page.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({
    super.key,
    this.pastor = false,
    bool? canDirect,
  }) : canDirect = canDirect ?? pastor;

  final bool pastor;
  final bool canDirect;

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  List<ReadingGroup>? _groups;
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
        return AppScope.of(context).createGroupPlan(
          groupId: group.id,
          title: title,
          passages: passages,
        );
      },
    );
    if (!sent || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Leitura enviada a ${group.name}')),
    );
    await _load(AppScope.of(context).getGroups);
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groups;
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
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.ember),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                    children: [
                      ProtoSection(
                        title: widget.pastor
                            ? 'Todos os grupos'
                            : 'Grupos que participo',
                        trailing:
                            '${groups.length} ${widget.pastor ? (groups.length == 1 ? 'grupo' : 'grupos') : (groups.length == 1 ? 'ativo' : 'ativos')}',
                      ),
                      if (groups.isEmpty)
                        const ProtoCard(
                          child: Text(
                            'Nenhum grupo ainda. Peça um convite à liderança.',
                            style: TextStyle(color: AppColors.slate300),
                          ),
                        ),
                      for (final group in groups) ...[
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
                          borderRadius: BorderRadius.circular(17),
                          child: ProtoCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MiniLabel(
                                widget.pastor
                                    ? participationLabel(group.weekProgress)
                                    : group.planLabel,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                group.name,
                                style: const TextStyle(
                                  color: AppColors.slate100,
                                  fontSize: 15,
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
                              const SizedBox(height: 13),
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
