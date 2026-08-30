import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/proto.dart';
import '../../domain/entities/feed_home.dart';

class CarePlanCard extends StatelessWidget {
  const CarePlanCard({
    super.key,
    required this.plan,
    required this.onOpen,
    this.onFinish,
  });

  final MemberCarePlan plan;
  final void Function(int index) onOpen;
  final VoidCallback? onFinish;

  @override
  Widget build(BuildContext context) {
    final total = plan.readings.length;
    final done = plan.doneCount;
    final next = plan.readings.indexWhere((item) => !item.completed);
    return ProtoCard(
      challenge: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MiniLabel(
            total == 0
                ? plan.sourceLabel
                : '${plan.sourceLabel} · $done de $total',
          ),
          const SizedBox(height: 6),
          Text(
            plan.title,
            style: const TextStyle(
              color: AppColors.slate100,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (plan.message != null && plan.message!.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              plan.message!,
              style: const TextStyle(
                color: AppColors.slate300,
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 12),
          EmberProgress(value: total == 0 ? 0 : done / total),
          const SizedBox(height: 12),
          for (var i = 0; i < plan.readings.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _ReadingRow(
              index: i,
              item: plan.readings[i],
              onOpen: () => onOpen(i),
            ),
          ],
          if (next >= 0) ...[
            const SizedBox(height: 12),
            EmberButton(
              label: 'Continuar leitura',
              onPressed: () => onOpen(next),
            ),
          ] else if (onFinish != null) ...[
            const SizedBox(height: 12),
            EmberButton(label: 'Encerrar plano', onPressed: onFinish),
          ],
        ],
      ),
    );
  }
}

class _ReadingRow extends StatelessWidget {
  const _ReadingRow({
    required this.index,
    required this.item,
    required this.onOpen,
  });

  final int index;
  final CareReading item;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: item.completed ? const Color(0x3322C55E) : AppColors.slate800,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                item.completed ? Icons.check_circle : Icons.menu_book_outlined,
                size: 18,
                color: item.completed
                    ? const Color(0xFF4ADE80)
                    : AppColors.ember,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${index + 1}. ${item.passageLabel}',
                  style: TextStyle(
                    color: AppColors.slate100,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    decoration: item.completed
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.slate400,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
