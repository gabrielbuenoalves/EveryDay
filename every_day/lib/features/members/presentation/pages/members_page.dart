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
  var _filter = 0;
  var _loading = true;
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
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final people = {
      for (final group in _groups)
        for (final member in group.members) member.id: (member, group),
    }.values.toList();
    final filtered = people
        .where((entry) {
          if (_query.trim().isEmpty) return true;
          final q = _query.toLowerCase();
          return entry.$1.displayName.toLowerCase().contains(q) ||
              entry.$2.name.toLowerCase().contains(q);
        })
        .where((entry) => _filter == 0 || entry.$2.weekProgress < 0.5)
        .toList();
    final avg = _groups.isEmpty
        ? 0.0
        : _groups.map((group) => group.weekProgress).reduce((a, b) => a + b) /
              _groups.length;
    final attention = people
        .where((entry) => entry.$2.weekProgress < 0.5)
        .length;
    final active = people.length - attention;
    final pending = _careItems.length;

    return SafeArea(
      bottom: false,
      child: _loading
          ? const _MembersLoading()
          : ListView(
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
                    _MiniMetric(
                      'Tempo',
                      '${_pulse?.minutesWeek ?? 0} min',
                      'leitura nesta semana',
                    ),
                    _MiniMetric(
                      'Leituras',
                      '${_pulse?.readingsWeek ?? 0}',
                      'registros na semana',
                    ),
                    _MiniMetric(
                      'Comentários',
                      '${_pulse?.commentsWeek ?? 0}',
                      'no plano e no feed',
                    ),
                    _MiniMetric(
                      'Planos',
                      '${_pulse?.completionsWeek ?? 0}',
                      'encerrados na semana',
                    ),
                    _MiniMetric('Ativos', '$active', 'nos últimos 7 dias'),
                    _MiniMetric(
                      'Precisam de atenção',
                      '$attention',
                      'sem atividade recente',
                    ),
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
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.slate850,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.slate700),
                  ),
                  child: Row(
                    children: [
                      _MemberFilter(
                        label: 'Todos',
                        selected: _filter == 0,
                        onTap: () => setState(() => _filter = 0),
                      ),
                      _MemberFilter(
                        label: 'Precisam de atenção',
                        selected: _filter == 1,
                        onTap: () => setState(() => _filter = 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (filtered.isEmpty)
                  const ProtoCard(
                    child: Text(
                      'Nenhum membro encontrado.',
                      style: TextStyle(color: AppColors.slate300),
                    ),
                  ),
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
                          engagement = await deps.getMemberEngagement(
                            entry.$1.id,
                          );
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

class _MemberFilter extends StatelessWidget {
  const _MemberFilter({
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
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.ember : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
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

class _MembersLoading extends StatelessWidget {
  const _MembersLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
      children: [
        Container(
          height: 12,
          width: 60,
          decoration: BoxDecoration(
            color: AppColors.slate800,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 28,
          width: 150,
          decoration: BoxDecoration(
            color: AppColors.slate800,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 24),
        const ProtoCard(child: SizedBox(height: 120)),
        const SizedBox(height: 12),
        for (var i = 0; i < 4; i++) ...[
          const ProtoCard(child: SizedBox(height: 42)),
          const SizedBox(height: 8),
        ],
      ],
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
          Text(
            hint,
            style: const TextStyle(color: AppColors.slate400, fontSize: 9),
          ),
        ],
      ),
    );
  }
}
