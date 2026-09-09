import 'package:flutter/material.dart';

import '../../../../app/di/app_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/proto.dart';
import '../../../care/presentation/pages/plan_reflection_page.dart';
import '../../../feed/domain/entities/feed_home.dart';
import '../../../feed/presentation/widgets/care_plan_card.dart';
import '../../../reading/presentation/pages/reading_page.dart';
import '../../domain/entities/reading_group.dart';
import '../widgets/direct_reading_sheet.dart';

class GroupDetailPage extends StatefulWidget {
  const GroupDetailPage({
    super.key,
    required this.group,
    this.pastor = false,
    bool? canDirect,
  }) : canDirect = canDirect ?? pastor;

  final ReadingGroup group;
  final bool pastor;
  final bool canDirect;

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  var _loading = true;
  var _started = false;
  List<MemberCarePlan> _plans = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _load();
  }

  Future<void> _load() async {
    try {
      final plans = await AppScope.of(context).listGroupPlans(widget.group.id);
      if (!mounted) return;
      setState(() {
        _plans = plans;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _openPlan(MemberCarePlan plan, int index) async {
    final changed = await ReadingPage.open(
      context,
      reading: plan.readings[index].reading,
      playlist: plan.playlist,
      index: index,
      completedLabels: plan.completedLabels,
      daily: false,
      planId: plan.isPastoral ? plan.id : null,
      planTitle: plan.title,
      groupId: plan.groupId,
      readingPlanId: plan.readingPlanId,
      allowArchive: !plan.isArchived,
    );
    if (changed && mounted) await _load();
  }

  Future<void> _finish(MemberCarePlan plan) async {
    final archived = await finishDirectedPlan(context, plan: plan);
    if (archived && mounted) await _load();
  }

  @override
  Widget build(BuildContext context) {
    final active = _plans.where((plan) => !plan.isArchived).toList();
    final done = _plans.where((plan) => plan.isArchived).toList();
    return Scaffold(
      backgroundColor: AppColors.slate900,
      appBar: AppBar(
        title: Text(widget.group.name),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${widget.group.memberCount}',
                style: const TextStyle(
                  color: AppColors.ember,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? const _DetailLoading()
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                ProtoCard(
                  challenge: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MiniLabel(
                        '${widget.group.memberCount} ${widget.group.memberCount == 1 ? 'pessoa' : 'pessoas'}',
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.group.name,
                        style: const TextStyle(
                          color: AppColors.slate100,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(widget.group.weekProgress * 100).round()}% do grupo acompanhou a leitura nesta semana.',
                        style: const TextStyle(
                          color: AppColors.slate300,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 13),
                      EmberProgress(value: widget.group.weekProgress),
                      if (widget.canDirect &&
                          widget.group.inviteCode != null &&
                          widget.group.inviteCode!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const MiniLabel('Código do grupo'),
                        const SizedBox(height: 4),
                        Text(
                          widget.group.inviteCode!,
                          style: const TextStyle(
                            color: AppColors.slate100,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (widget.canDirect) ...[
                  const SizedBox(height: 12),
                  EmberButton(
                    label: 'Direcionar leitura',
                    expand: true,
                    onPressed: () => _directReading(),
                  ),
                ],
                if (!widget.canDirect) ...[
                  const SizedBox(height: 12),
                  const ProtoCard(
                    child: Row(
                      children: [
                        Icon(
                          Icons.forum_outlined,
                          color: AppColors.ember,
                          size: 19,
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Tópicos e pedidos de oração deste grupo aparecerão aqui quando esse recurso estiver disponível.',
                            style: TextStyle(
                              color: AppColors.slate400,
                              fontSize: 11,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                ProtoSection(
                  title: 'Em andamento',
                  trailing: '${active.length}',
                ),
                if (active.isEmpty)
                  const ProtoCard(
                    child: Text(
                      'Nenhuma leitura em andamento neste grupo.',
                      style: TextStyle(color: AppColors.slate300),
                    ),
                  )
                else
                  for (final plan in active) ...[
                    CarePlanCard(
                      plan: plan,
                      onOpen: (index) => _openPlan(plan, index),
                      onFinish: plan.isComplete ? () => _finish(plan) : null,
                    ),
                    const SizedBox(height: 8),
                  ],
                ProtoSection(title: 'Concluídas', trailing: '${done.length}'),
                if (done.isEmpty)
                  const ProtoCard(
                    child: Text(
                      'Quando você encerrar uma leitura daqui, ela aparece nesta lista.',
                      style: TextStyle(color: AppColors.slate300),
                    ),
                  )
                else
                  for (final plan in done) ...[
                    ArchivedPlanCard(
                      plan: plan,
                      onOpen: () => _openPlan(plan, 0),
                    ),
                    const SizedBox(height: 8),
                  ],
              ],
            ),
    );
  }

  Future<void> _directReading() async {
    final sent = await showDirectReadingSheet(
      context,
      groupName: widget.group.name,
      onSubmit: ({required title, required passages}) {
        return AppScope.of(context).createGroupPlan(
          groupId: widget.group.id,
          title: title,
          passages: passages,
        );
      },
    );
    if (!sent || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Leitura enviada a ${widget.group.name}')),
    );
    await _load();
  }
}

class _DetailLoading extends StatelessWidget {
  const _DetailLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        const ProtoCard(child: SizedBox(height: 100)),
        const SizedBox(height: 14),
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.slate800,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        const SizedBox(height: 28),
        for (var i = 0; i < 2; i++) ...[
          const ProtoCard(child: SizedBox(height: 92)),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}
