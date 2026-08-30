import 'package:flutter/material.dart';

import '../../../../core/care/crisis_keywords.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/usecases/care_usecases.dart';

class DailyFeeling {
  const DailyFeeling({
    required this.emoji,
    required this.label,
    required this.score,
    required this.needsPrayer,
  });

  final String emoji;
  final String label;
  final int score;
  final bool needsPrayer;
}

const dailyFeelings = [
  DailyFeeling(emoji: '🤩', label: 'Grato', score: 5, needsPrayer: false),
  DailyFeeling(emoji: '😢', label: 'Sozinho', score: 2, needsPrayer: true),
  DailyFeeling(emoji: '😭', label: 'Triste', score: 2, needsPrayer: true),
  DailyFeeling(emoji: '😩', label: 'Com pouca fé', score: 2, needsPrayer: true),
  DailyFeeling(emoji: '😇', label: 'Abençoado', score: 5, needsPrayer: false),
  DailyFeeling(emoji: '🤢', label: 'Doente', score: 2, needsPrayer: true),
  DailyFeeling(emoji: '😀', label: 'Feliz', score: 5, needsPrayer: false),
    DailyFeeling(emoji: '😍', label: 'Cuidadoso', score: 4, needsPrayer: false),
  DailyFeeling(emoji: '😟', label: 'Angustiado', score: 1, needsPrayer: true),
];

Future<void> showMoodCheckinSheet(
  BuildContext context, {
  required SubmitMoodCheckin submit,
  required AnalyzeCheckin analyze,
}) {
  return showDailyFeelingDialog(context, submit: submit, analyze: analyze);
}

Future<void> showDailyFeelingDialog(
  BuildContext context, {
  required SubmitMoodCheckin submit,
  required AnalyzeCheckin analyze,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: const Color(0xCC0F172A),
    builder: (context) {
      return _FeelingDialog(submit: submit, analyze: analyze);
    },
  );
}

class _FeelingDialog extends StatefulWidget {
  const _FeelingDialog({required this.submit, required this.analyze});

  final SubmitMoodCheckin submit;
  final AnalyzeCheckin analyze;

  @override
  State<_FeelingDialog> createState() => _FeelingDialogState();
}

class _FeelingDialogState extends State<_FeelingDialog> {
  DailyFeeling? _feeling;
  var _saving = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.slate850,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: AppColors.slate700),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Como está se sentindo hoje?',
                    style: TextStyle(
                      color: AppColors.slate100,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _saving ? null : () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.slate400),
                ),
              ],
            ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.95,
              children: [
                for (final feeling in dailyFeelings)
                  _FeelingTile(
                    feeling: feeling,
                    selected: _feeling == feeling,
                    onTap: () => setState(() {
                      _feeling = feeling;
                      _error = null;
                    }),
                  ),
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: AppColors.ember, fontSize: 12)),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _feeling == null || _saving ? null : _send,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.ember,
                  foregroundColor: AppColors.slate950,
                  disabledBackgroundColor: AppColors.slate700,
                  disabledForegroundColor: AppColors.slate400,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                child: Text(_saving ? 'Enviando...' : 'Enviar'),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Future<void> _send() async {
    final feeling = _feeling;
    if (feeling == null) return;
    setState(() {
      _saving = true;
      _error = null;
    });

    var prayer = '';
    var whatsapp = false;
    if (feeling.needsPrayer && mounted) {
      final result = await showDialog<_PrayerResult>(
        context: context,
        barrierDismissible: false,
        barrierColor: const Color(0xCC0F172A),
        builder: (context) => const _PrayerDialog(),
      );
      if (result != null) {
        prayer = result.text;
        whatsapp = result.whatsapp;
      }
    }

    final parts = <String>[
      'Sentimento: ${feeling.label}',
      if (prayer.isNotEmpty) 'Pedido de oração: $prayer',
      if (whatsapp) 'Permitiu contato via WhatsApp.',
    ];

    try {
      final id = await widget.submit(
        score: feeling.score,
        body: parts.join('\n'),
        lgpdAccepted: feeling.score > 2 || feeling.needsPrayer,
      );
      if (feeling.score <= 2) {
        try {
          await widget.analyze(id);
        } catch (_) {}
      }
      if (!mounted) return;
      Navigator.pop(context);
      if (feeling.score <= 2 && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'O pastor vai receber um relatório da IA e pode te enviar uma leitura depois de revisar.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'Não foi possível salvar agora. Tente de novo.';
      });
    }
  }
}

class _FeelingTile extends StatelessWidget {
  const _FeelingTile({
    required this.feeling,
    required this.selected,
    required this.onTap,
  });

  final DailyFeeling feeling;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0x33E3703A) : AppColors.slate800,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.ember : AppColors.slate700,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(feeling.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 4),
              Text(
                feeling.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected ? AppColors.slate100 : AppColors.slate300,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrayerResult {
  const _PrayerResult({required this.text, required this.whatsapp});

  final String text;
  final bool whatsapp;
}

class _PrayerDialog extends StatefulWidget {
  const _PrayerDialog();

  @override
  State<_PrayerDialog> createState() => _PrayerDialogState();
}

class _PrayerDialogState extends State<_PrayerDialog> {
  final _text = TextEditingController();
  var _whatsapp = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final crisis = containsCrisisLanguage(_text.text);
    return Dialog(
      backgroundColor: AppColors.slate850,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: AppColors.slate700),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: Padding(
        padding: EdgeInsets.only(
          left: 18,
          right: 18,
          top: 18,
          bottom: 18 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text('😟', style: TextStyle(fontSize: 28)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Pedido de oração',
                      style: TextStyle(
                        color: AppColors.slate100,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Obrigado por compartilhar seu sentimento! Vamos orar juntos! Se desejar, compartilhe seu pedido de oração para que possamos orar por você.',
                style: TextStyle(color: AppColors.slate300, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _text,
                maxLines: 4,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Escreva seu pedido de oração...',
                ),
              ),
              if (crisis) ...[
                const SizedBox(height: 8),
                const Text(
                  'Vamos priorizar este pedido. Você não está sozinho.',
                  style: TextStyle(color: AppColors.ember, fontWeight: FontWeight.w700, fontSize: 12),
                ),
              ],
              const SizedBox(height: 8),
              SwitchListTile(
                value: _whatsapp,
                onChanged: (value) => setState(() => _whatsapp = value),
                contentPadding: EdgeInsets.zero,
                activeThumbColor: AppColors.slate950,
                activeTrackColor: AppColors.ember,
                title: const Text(
                  'Permitir contato via WhatsApp',
                  style: TextStyle(color: AppColors.slate100, fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () => Navigator.pop(
                    context,
                    _PrayerResult(text: _text.text.trim(), whatsapp: _whatsapp),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.ember,
                    foregroundColor: AppColors.slate950,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Enviar', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(
                    context,
                    const _PrayerResult(text: '', whatsapp: false),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.slate100,
                    side: const BorderSide(color: AppColors.slate500),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Não, obrigado', style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
