import 'package:flutter/material.dart';

import '../../../../app/di/app_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/time_ago.dart';
import '../../../../core/widgets/proto.dart';
import '../../domain/entities/care_models.dart';

class MemberInsightsPage extends StatefulWidget {
  const MemberInsightsPage({
    super.key,
    required this.memberId,
    required this.memberName,
    required this.insights,
    this.engagement,
  });

  final String memberId;
  final String memberName;
  final List<CarePlanInsight> insights;
  final MemberEngagement? engagement;

  @override
  State<MemberInsightsPage> createState() => _MemberInsightsPageState();
}

class _MemberInsightsPageState extends State<MemberInsightsPage> {
  MemberAiReport? _report;
  List<MoodCheckin> _checkins = const [];
  var _loadingReport = true;
  var _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _loadPastoral();
  }

  Future<void> _loadPastoral() async {
    final deps = AppScope.of(context);
    var checkins = const <MoodCheckin>[];
    MemberAiReport? report;
    try {
      checkins = await deps.getMemberCheckins(widget.memberId);
    } catch (_) {}
    try {
      report = await deps.generateMemberBriefing(widget.memberId);
    } catch (_) {
      report = _localBriefing(checkins);
    }
    if (!mounted) return;
    setState(() {
      _checkins = checkins;
      _report = report;
      _loadingReport = false;
    });
  }

  MemberAiReport _localBriefing(List<MoodCheckin> checkins) {
    final stats = widget.engagement;
    final prayers = checkins
        .where(
          (item) =>
              (item.body ?? '').toLowerCase().contains('pedido de oração'),
        )
        .toList();
    final hard = checkins.any((item) => item.score <= 2 || item.crisis);
    return MemberAiReport(
      summary:
          '${widget.memberName} tem ${stats?.readingCount ?? 0} leituras registradas '
          '(${stats?.minutesTotal ?? 0} min no total, ${stats?.minutesWeek ?? 0} min nesta semana). '
          '${widget.insights.isEmpty ? 'Ainda sem quiz de plano.' : '${widget.insights.length} quiz(zes) concluídos.'}',
      prayerAttention: prayers.isEmpty
          ? 'Nenhum pedido de oração recente neste perfil.'
          : prayers.map((item) => item.body ?? '').join('\n'),
      readingPulse:
          'Última passagem: ${stats?.lastPassage ?? 'ainda sem registro'}. '
          '${stats?.commentCount ?? 0} comentários.',
      nextStep: hard
          ? 'Priorize um contato pastoral breve e uma leitura curta de acolhimento.'
          : 'Afirme a constância e avance com calma na próxima leitura.',
      urgency: hard ? 'high' : 'medium',
    );
  }

  @override
  Widget build(BuildContext context) {
    final latest = widget.insights.isEmpty ? null : widget.insights.first;
    final stats = widget.engagement;
    final prayers = _checkins
        .where((item) => (item.body ?? '').trim().isNotEmpty)
        .toList();
    return Scaffold(
      backgroundColor: AppColors.slate900,
      appBar: AppBar(title: Text(widget.memberName)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 36),
        children: [
          const MiniLabel('RELATÓRIO PASTORAL'),
          const SizedBox(height: 8),
          if (_loadingReport)
            const ProtoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 180,
                    height: 10,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.slate700,
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'A IA está lendo o quiz, o tempo de leitura e os pedidos de oração…',
                    style: TextStyle(color: AppColors.slate300, height: 1.4),
                  ),
                ],
              ),
            )
          else if (_report != null)
            ProtoCard(
              challenge: _report!.needsAttention,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MiniLabel(
                    _report!.needsAttention
                        ? 'Atenção pastoral'
                        : 'Briefing da IA',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _report!.summary,
                    style: const TextStyle(
                      color: AppColors.slate100,
                      height: 1.45,
                      fontSize: 14,
                    ),
                  ),
                  const ProtoSection(title: 'Pedidos de oração'),
                  Text(
                    _report!.prayerAttention,
                    style: const TextStyle(
                      color: AppColors.slate300,
                      height: 1.4,
                      fontSize: 13,
                    ),
                  ),
                  const ProtoSection(title: 'Pulso de leitura'),
                  Text(
                    _report!.readingPulse,
                    style: const TextStyle(
                      color: AppColors.slate300,
                      height: 1.4,
                      fontSize: 13,
                    ),
                  ),
                  const ProtoSection(title: 'Próximo passo'),
                  Text(
                    _report!.nextStep,
                    style: const TextStyle(
                      color: AppColors.slate100,
                      height: 1.4,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          if (prayers.isNotEmpty) ...[
            const ProtoSection(title: 'Formulários e oração'),
            for (final item in prayers) ...[
              ProtoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MiniLabel(
                      item.crisis
                          ? 'Crise · nota ${item.score}'
                          : 'Check-in · nota ${item.score}',
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.body!,
                      style: const TextStyle(
                        color: AppColors.slate100,
                        height: 1.4,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ],
          const MiniLabel('COMO ESSA OVELHA LÊ'),
          const SizedBox(height: 8),
          if (stats != null) ...[
            ProtoCard(
              challenge: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MiniLabel('Engajamento'),
                  const SizedBox(height: 6),
                  Text(
                    stats.lastPassage == null
                        ? 'Ainda não há uma leitura registrada.'
                        : 'Última leitura: ${stats.lastPassage}'
                              '${stats.lastReadAt == null ? '' : ' · ${timeAgo(stats.lastReadAt!)}'}',
                    style: const TextStyle(
                      color: AppColors.slate100,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${stats.activeDaysWeek} ${stats.activeDaysWeek == 1 ? 'dia ativo' : 'dias ativos'} nesta semana · ${stats.plansCompleted} planos concluídos',
                    style: const TextStyle(
                      color: AppColors.slate300,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const ProtoSection(title: 'Tempo, comentários e presença'),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 9,
              crossAxisSpacing: 9,
              childAspectRatio: 1.45,
              children: [
                _Metric(
                  'Tempo total',
                  '${stats.minutesTotal} min',
                  'em todas as leituras',
                ),
                _Metric(
                  'Nesta semana',
                  '${stats.minutesWeek} min',
                  '${stats.readingCountWeek} registros',
                ),
                _Metric(
                  'Leituras',
                  '${stats.readingCount}',
                  'passagens registradas',
                ),
                _Metric(
                  'Comentários',
                  '${stats.commentCount}',
                  '${stats.commentCountWeek} nesta semana',
                ),
                _Metric('Check-ins', '${stats.checkinCount}', 'humor enviado'),
                _Metric('Planos', '${stats.plansCompleted}', 'já encerrados'),
              ],
            ),
          ],
          if (latest == null)
            const ProtoCard(
              child: Text(
                'Ainda não há um plano concluído com quiz. Tempo de leitura e comentários já aparecem acima quando houver atividade.',
                style: TextStyle(color: AppColors.slate300, height: 1.4),
              ),
            )
          else ...[
            const ProtoSection(title: 'Quiz da última leitura'),
            ProtoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MiniLabel('Próxima leitura'),
                  const SizedBox(height: 6),
                  Text(
                    latest.nextReadingHint,
                    style: const TextStyle(
                      color: AppColors.slate100,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Último plano: ${latest.planTitle}',
                    style: const TextStyle(
                      color: AppColors.slate300,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 9),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 9,
              crossAxisSpacing: 9,
              childAspectRatio: 1.45,
              children: [
                _Metric(
                  'Compreensão',
                  latest.understandingLabel,
                  '${latest.understanding}/5',
                ),
                _Metric(
                  'Tempo do plano',
                  '${latest.minutes} min',
                  'nesta leitura',
                ),
                _Metric(
                  'Olhar sobre o texto',
                  latest.receptionLabel,
                  'como encontrou',
                ),
                _Metric(
                  'Quizzes',
                  '${widget.insights.length}',
                  'já concluídos',
                ),
              ],
            ),
            if ((latest.takeaway ?? '').trim().isNotEmpty) ...[
              const ProtoSection(title: 'O que ficou para ela'),
              ProtoCard(
                child: Text(
                  latest.takeaway!,
                  style: const TextStyle(
                    color: AppColors.slate100,
                    height: 1.4,
                  ),
                ),
              ),
            ],
            if ((latest.comment ?? '').trim().isNotEmpty) ...[
              const ProtoSection(title: 'Comentário para você'),
              ProtoCard(
                child: Text(
                  latest.comment!,
                  style: const TextStyle(
                    color: AppColors.slate100,
                    height: 1.4,
                  ),
                ),
              ),
            ],
            const ProtoSection(title: 'Histórico de quizzes'),
            for (final item in widget.insights) ...[
              ProtoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.planTitle,
                      style: const TextStyle(
                        color: AppColors.slate100,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.understandingLabel} · ${item.receptionLabel} · ${item.minutes} min · ${timeAgo(item.completedAt)}',
                      style: const TextStyle(
                        color: AppColors.slate400,
                        fontSize: 11,
                      ),
                    ),
                    if ((item.takeaway ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        item.takeaway!,
                        style: const TextStyle(
                          color: AppColors.slate300,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.label, this.value, this.hint);

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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.slate100,
              fontSize: 16,
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
