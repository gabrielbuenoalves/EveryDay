import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/proto.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../domain/entities/care_models.dart';
import '../../domain/usecases/care_usecases.dart';

class CareReportPage extends StatefulWidget {
  const CareReportPage({
    super.key,
    required this.item,
    required this.approvePlan,
    required this.scheduleContact,
  });

  final CareInboxItem item;
  final ApproveCarePlan approvePlan;
  final ScheduleCareContact scheduleContact;

  @override
  State<CareReportPage> createState() => _CareReportPageState();
}

class _CareReportPageState extends State<CareReportPage> {
  late final TextEditingController _title;
  late final TextEditingController _message;
  late final TextEditingController _passages;
  late final TextEditingController _when;
  var _busy = false;
  var _planSent = false;
  var _contactScheduled = false;

  PastoralReport? get _report => widget.item.report;

  String get _sheepName {
    final parts = widget.item.member.displayName.trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? 'este membro' : parts.first;
  }

  @override
  void initState() {
    super.initState();
    final report = _report;
    _title = TextEditingController(
      text: report?.theme == null || report!.theme!.trim().isEmpty
          ? 'Uma leitura para você'
          : report.theme!,
    );
    _message = TextEditingController(
      text:
          '$_sheepName, oramos por você. Seu pastor revisou uma leitura para este momento. Não precisa responder — só receber.',
    );
    _passages = TextEditingController(
      text: (report?.passages ?? const <String>[]).join('\n'),
    );
    _when = TextEditingController();
  }

  @override
  void dispose() {
    _title.dispose();
    _message.dispose();
    _passages.dispose();
    _when.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final report = _report;

    return Scaffold(
      backgroundColor: AppColors.slate900,
      appBar: AppBar(title: const Text('Cuidado Pastoral')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.violet,
                child: Text(
                  _sheepName.substring(0, 1),
                  style: const TextStyle(
                    color: AppColors.slate100,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.member.displayName,
                      style: const TextStyle(
                        color: AppColors.slate100,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Text(
                      'RELATO RECEBIDO',
                      style: TextStyle(
                        color: AppColors.slate400,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const MiniLabel('RELATO DO MEMBRO'),
          const SizedBox(height: 8),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nota ${item.checkin.score}'
                  '${item.checkin.crisis ? ' · alerta de crise' : ''}',
                  style: const TextStyle(
                    color: AppColors.slate400,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.checkin.body?.trim().isNotEmpty == true
                      ? item.checkin.body!
                      : 'O membro pediu cuidado, sem texto extra.',
                  style: const TextStyle(
                    color: AppColors.slate100,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const MiniLabel('ANÁLISE DA IA · SÓ VOCÊ VÊ'),
          const SizedBox(height: 8),
          SurfaceCard(
            color: AppColors.violetSoft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.pastoralBriefing,
                  style: const TextStyle(
                    color: AppColors.slate100,
                    height: 1.4,
                  ),
                ),
                if (report != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Urgência: ${report.urgency.label}'
                    '${report.theme == null ? '' : ' · ${report.theme}'}',
                    style: const TextStyle(color: AppColors.slate300),
                  ),
                  if (report.approachNotes.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Por que estas leituras',
                      style: TextStyle(
                        color: AppColors.slate100,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    for (final note in report.approachNotes)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          '• $note',
                          style: const TextStyle(
                            color: AppColors.slate300,
                            height: 1.35,
                          ),
                        ),
                      ),
                  ],
                ],
                const SizedBox(height: 10),
                const Text(
                  'Isto não vai para o membro. É briefing para a sua auditoria.',
                  style: TextStyle(color: AppColors.slate400, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          MiniLabel('RESPONDER PARA $_sheepName'),
          const SizedBox(height: 8),
          const Text(
            'A ovelha vê todas as leituras de uma vez e navega entre elas. Sem a sua aprovação, ela não recebe nada.',
            style: TextStyle(
              color: AppColors.slate400,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _title,
            decoration: _decoration('Título que o membro vê'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _message,
            maxLines: 4,
            decoration: _decoration('Mensagem sua, não da IA'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _passages,
            maxLines: 5,
            decoration: _decoration(
              'Leituras (uma por linha) — a ovelha vê todas',
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: _busy || _planSent ? null : _approve,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.ember,
                foregroundColor: AppColors.slate950,
              ),
              child: Text(
                _planSent
                    ? 'Leitura enviada a $_sheepName'
                    : 'Aprovar e enviar a $_sheepName',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(height: 22),
          const MiniLabel('OPCIONAL · CONTATO HUMANO'),
          const SizedBox(height: 8),
          TextField(
            controller: _when,
            decoration: _decoration('Quando (ex.: amanhã 19h)'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _busy || _contactScheduled ? null : _schedule,
            child: Text(
              _contactScheduled
                  ? 'Conversa marcada'
                  : 'Marcar conversa com $_sheepName',
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  Future<void> _approve() async {
    final report = _report;
    if (report == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Ainda não há relatório para auditar. Atualize a fila.',
          ),
        ),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final passages = _passages.text
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      await widget.approvePlan(
        reportId: report.id,
        title: _title.text,
        message: _message.text,
        passages: passages.isEmpty ? report.passages : passages,
        durationDays: passages.isEmpty ? 1 : passages.length,
      );
      if (!mounted) return;
      setState(() => _planSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Leitura aprovada. $_sheepName verá as passagens na Home e poderá navegar entre elas.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _schedule() async {
    final report = _report;
    if (report == null) return;
    setState(() => _busy = true);
    try {
      await widget.scheduleContact(
        reportId: report.id,
        whenLabel: _when.text.trim().isEmpty ? 'a combinar' : _when.text.trim(),
      );
      if (!mounted) return;
      setState(() => _contactScheduled = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Contato com $_sheepName agendado')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
