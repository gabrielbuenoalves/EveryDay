import 'package:flutter/material.dart';

import '../../../../app/di/app_scope.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/proto.dart';
import '../../../feed/domain/entities/feed_home.dart';
import '../../domain/entities/care_models.dart';

Future<bool> showPlanReflectionSheet(
  BuildContext context, {
  required String planTitle,
  required int minutes,
  required Future<void> Function(PlanReflection reflection) onSubmit,
  String commentTitle = 'Comentário para o pastor',
}) async {
  final result = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) => PlanReflectionPage(
        planTitle: planTitle,
        minutes: minutes,
        onSubmit: onSubmit,
        commentTitle: commentTitle,
      ),
    ),
  );
  return result ?? false;
}

Future<bool> finishDirectedPlan(
  BuildContext context, {
  required MemberCarePlan plan,
  int? minutes,
}) async {
  final deps = AppScope.of(context);
  final time =
      minutes ??
      await deps.minutesForPassages(
        plan.readings.map((item) => item.passageLabel).toList(),
      );
  if (!context.mounted) return false;
  final archived = await showPlanReflectionSheet(
    context,
    planTitle: plan.title,
    minutes: time,
    commentTitle: plan.isPastoral ? 'Comentário para o pastor' : 'Comentário',
    onSubmit: (reflection) async {
      if (plan.isPastoral) {
        await deps.completeCarePlan(planId: plan.id, reflection: reflection);
      } else {
        final groupId = plan.groupId;
        final readingPlanId = plan.readingPlanId;
        if (groupId == null || readingPlanId == null) {
          throw StateError('plano de grupo inválido');
        }
        await deps.completeGroupPlan(
          groupId: groupId,
          planId: readingPlanId,
          reflection: reflection,
        );
      }
    },
  );
  if (archived) deps.feedReload.ping();
  return archived;
}

Future<bool> finishCarePlan(
  BuildContext context, {
  required String planId,
  required String planTitle,
  int minutes = 1,
}) {
  return finishDirectedPlan(
    context,
    plan: MemberCarePlan(id: planId, title: planTitle, readings: const []),
    minutes: minutes,
  );
}

class PlanReflectionPage extends StatefulWidget {
  const PlanReflectionPage({
    super.key,
    required this.planTitle,
    required this.minutes,
    required this.onSubmit,
    this.commentTitle = 'Comentário para o pastor',
  });

  final String planTitle;
  final int minutes;
  final Future<void> Function(PlanReflection reflection) onSubmit;
  final String commentTitle;

  @override
  State<PlanReflectionPage> createState() => _PlanReflectionPageState();
}

class _PlanReflectionPageState extends State<PlanReflectionPage> {
  final _takeaway = TextEditingController();
  final _comment = TextEditingController();
  var _understanding = 3;
  var _reception = 'paz';
  var _saving = false;

  @override
  void dispose() {
    _takeaway.dispose();
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate900,
      appBar: AppBar(title: const Text('Como foi essa leitura')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 36),
        children: [
          ProtoCard(
            challenge: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MiniLabel('Plano concluído'),
                const SizedBox(height: 6),
                Text(
                  widget.planTitle,
                  style: const TextStyle(
                    color: AppColors.slate100,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tempo aproximado: ${widget.minutes} min. Seu pastor usa isso para a próxima leitura.',
                  style: const TextStyle(
                    color: AppColors.slate300,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const ProtoSection(title: 'Seu check-out'),
          const Text(
            'Não existe resposta certa. Essas notas ajudam a próxima conversa e a sua caminhada.',
            style: TextStyle(
              color: AppColors.slate400,
              fontSize: 11,
              height: 1.35,
            ),
          ),
          const ProtoSection(title: 'Quanto você entendeu o texto?'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var score = 1; score <= 5; score++)
                _ChoiceChip(
                  label:
                      '$score · ${switch (score) {
                        1 => 'Confuso',
                        2 => 'Pouco',
                        3 => 'Razoável',
                        4 => 'Bom',
                        _ => 'Claro',
                      }}',
                  selected: _understanding == score,
                  onTap: () => setState(() => _understanding = score),
                ),
            ],
          ),
          const ProtoSection(title: 'Como o texto te encontrou?'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final choice in kReceptionChoices)
                _ChoiceChip(
                  label: choice.label,
                  selected: _reception == choice.id,
                  onTap: () => setState(() => _reception = choice.id),
                ),
            ],
          ),
          const ProtoSection(title: 'O que ficou para você?'),
          TextField(
            controller: _takeaway,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Uma frase, uma imagem, um versículo…',
            ),
          ),
          ProtoSection(title: widget.commentTitle),
          TextField(
            controller: _comment,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText:
                  'O que você quer que ele saiba sobre esse tempo de leitura.',
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: _saving ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.ember,
                foregroundColor: AppColors.slate950,
              ),
              child: Text(
                _saving ? 'Arquivando…' : 'Encerrar e arquivar o plano',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _saving = true);
    try {
      await widget.onSubmit(
        PlanReflection(
          comment: _comment.text.trim(),
          takeaway: _takeaway.text.trim(),
          understanding: _understanding,
          reception: _reception,
          minutes: widget.minutes,
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.ember : AppColors.slate800,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: selected ? AppColors.ember : AppColors.slate700,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.slate950 : AppColors.slate100,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
