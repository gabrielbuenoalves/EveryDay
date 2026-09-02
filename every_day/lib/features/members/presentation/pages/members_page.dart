import 'package:flutter/material.dart';

import '../../../../app/di/app_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/proto.dart';
import '../../../care/domain/entities/care_models.dart';
import '../../../care/presentation/pages/member_insights_page.dart';
import '../../../groups/domain/entities/reading_group.dart';

class MembersPage extends StatefulWidget {
  const MembersPage({super.key});

  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  List<ReadingGroup> _groups = const [];
  List<CareInboxItem> _careItems = const [];
  ChurchPulse? _pulse;
  var _query = '';
  var _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _load();
  }

  Future<void> _load() async {
    final deps = AppScope.of(context);
    final groups = await deps.getGroups();
    var careItems = const <CareInboxItem>[];
    try {
      careItems = await deps.getCareInbox();
    } catch (_) {}
    var pulse = const ChurchPulse(
      minutesWeek: 0,
      readingsWeek: 0,
      commentsWeek: 0,
      completionsWeek: 0,
    );
    try {
      pulse = await deps.getChurchPulse();
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _groups = groups;
      _careItems = careItems;
      _pulse = pulse;
    });
  }

  @override
  Widget build(BuildContext context) {
    final people = {
      for (final group in _groups)
        for (final member in group.members) member.id: (member, group),
    }.values.toList();
    final filtered = people.where((entry) {
      if (_query.trim().isEmpty) return true;
      final q = _query.toLowerCase();
      return entry.$1.displayName.toLowerCase().contains(q) ||
          entry.$2.name.toLowerCase().contains(q);
    }).toList();
    final avg = _groups.isEmpty
        ? 0.0
        : _groups.map((group) => group.weekProgress).reduce((a, b) => a + b) /
            _groups.length;
    final attention = people.where((entry) => entry.$2.weekProgress < 0.5).length;
    final active = people.length - attention;
    final pending = _careItems.length;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        children: [
          const AppScreenHeader(kicker: 'Igreja', title: 'Membros'),
          ProtoSection(
            title: 'Membros da igreja',
            trailing: '${people.length} cadastrados',
          ),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 9,
            crossAxisSpacing: 9,
            childAspectRatio: 1.4,
            children: [
              _MiniMetric('Tempo', '${_pulse?.minutesWeek ?? 0} min', 'leitura nesta semana'),
              _MiniMetric('Leituras', '${_pulse?.readingsWeek ?? 0}', 'registros na semana'),
              _MiniMetric('Comentários', '${_pulse?.commentsWeek ?? 0}', 'no plano e no feed'),
              _MiniMetric('Planos', '${_pulse?.completionsWeek ?? 0}', 'encerrados na semana'),
              _MiniMetric('Ativos', '$active', 'nos últimos 7 dias'),
              _MiniMetric('Precisam de atenção', '$attention', 'sem atividade recente'),
              _MiniMetric(
                'Leitura semanal',
                '${(avg * 100).round()}%',
                'participação geral',
              ),
              _MiniMetric('Check-ins', '$pending', 'pedidos de cuidado'),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Buscar membro',
            style: TextStyle(
              color: AppColors.slate300,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          TextField(
            onChanged: (value) => setState(() => _query = value),
            maxLines: 1,
            textInputAction: TextInputAction.search,
            decoration: const InputDecoration(
              hintText: 'Nome ou grupo',
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),
          for (final entry in filtered) ...[
            Material(
              color: AppColors.slate800,
              borderRadius: BorderRadius.circular(13),
              child: InkWell(
                borderRadius: BorderRadius.circular(13),
                onTap: () async {
                  final deps = AppScope.of(context);
                  final insights = await deps.getCareReflections(
                    userId: entry.$1.id,
                  );
                  MemberEngagement? engagement;
                  try {
                    engagement = await deps.getMemberEngagement(entry.$1.id);
                  } catch (_) {}
                  if (!context.mounted) return;
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => MemberInsightsPage(
                        memberId: entry.$1.id,
                        memberName: entry.$1.displayName,
                        insights: insights,
                        engagement: engagement,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: AppColors.slate700),
                  ),
                  child: Row(
                    children: [
                      AppAvatar(
                        initials: entry.$1.initials,
                        color: AppColors.slate800,
                        foregroundColor: AppColors.slate100,
                        size: 34,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.$1.displayName,
                              style: const TextStyle(
                                color: AppColors.slate100,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              '${entry.$2.name} · ${(entry.$2.weekProgress * 100).round()}% de participação',
                              style: const TextStyle(
                                color: AppColors.slate400,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: entry.$2.weekProgress < 0.5
                              ? AppColors.slate400
                              : AppColors.ember,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric(this.label, this.value, this.hint);

  final String label;
  final String value;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return ProtoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MiniLabel(label),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.slate100,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(hint, style: const TextStyle(color: AppColors.slate400, fontSize: 9)),
        ],
      ),
    );
  }
}
