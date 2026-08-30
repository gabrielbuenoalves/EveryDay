import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/time_ago.dart';
import '../../../../core/widgets/proto.dart';
import '../../domain/entities/care_models.dart';

class MemberInsightsPage extends StatelessWidget {
  const MemberInsightsPage({
    super.key,
    required this.memberName,
    required this.insights,
  });

  final String memberName;
  final List<CarePlanInsight> insights;

  @override
  Widget build(BuildContext context) {
    final latest = insights.isEmpty ? null : insights.first;
    return Scaffold(
      backgroundColor: AppColors.slate900,
      appBar: AppBar(title: Text(memberName)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          const MiniLabel('Como essa ovelha lê'),
          const SizedBox(height: 8),
          if (latest == null)
            const ProtoCard(
              child: Text(
                'Ainda não há um plano concluído com quiz. Quando ela encerrar uma leitura, as métricas aparecem aqui.',
                style: TextStyle(color: AppColors.slate300, height: 1.4),
              ),
            )
          else ...[
            ProtoCard(
              challenge: true,
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
                    style: const TextStyle(color: AppColors.slate300, fontSize: 12),
                  ),
                ],
              ),
            ),
            const ProtoSection(title: 'Métricas do último plano'),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 9,
              crossAxisSpacing: 9,
              childAspectRatio: 1.45,
              children: [
                _Metric('Compreensão', latest.understandingLabel, '${latest.understanding}/5'),
                _Metric('Tempo', '${latest.minutes} min', 'nesta leitura'),
                _Metric('Olhar sobre o texto', latest.receptionLabel, 'como encontrou'),
                _Metric('Planos', '${insights.length}', 'já concluídos'),
              ],
            ),
            if ((latest.takeaway ?? '').trim().isNotEmpty) ...[
              const ProtoSection(title: 'O que ficou para ela'),
              ProtoCard(
                child: Text(
                  latest.takeaway!,
                  style: const TextStyle(color: AppColors.slate100, height: 1.4),
                ),
              ),
            ],
            if ((latest.comment ?? '').trim().isNotEmpty) ...[
              const ProtoSection(title: 'Comentário para você'),
              ProtoCard(
                child: Text(
                  latest.comment!,
                  style: const TextStyle(color: AppColors.slate100, height: 1.4),
                ),
              ),
            ],
            const ProtoSection(title: 'Histórico'),
            for (final item in insights) ...[
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
                      style: const TextStyle(color: AppColors.slate400, fontSize: 11),
                    ),
                    if ((item.takeaway ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        item.takeaway!,
                        style: const TextStyle(color: AppColors.slate300, fontSize: 12, height: 1.35),
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
          Text(hint, style: const TextStyle(color: AppColors.slate400, fontSize: 9)),
        ],
      ),
    );
  }
}
