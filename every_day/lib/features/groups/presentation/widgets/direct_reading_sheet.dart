import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/proto.dart';

Future<bool> showDirectReadingSheet(
  BuildContext context, {
  required String groupName,
  required Future<void> Function({
    required String title,
    required List<String> passages,
  })
  onSubmit,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.slate900,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return DirectReadingSheet(groupName: groupName, onSubmit: onSubmit);
    },
  );
  return result == true;
}

class DirectReadingSheet extends StatefulWidget {
  const DirectReadingSheet({
    super.key,
    required this.groupName,
    required this.onSubmit,
  });

  final String groupName;
  final Future<void> Function({
    required String title,
    required List<String> passages,
  })
  onSubmit;

  @override
  State<DirectReadingSheet> createState() => _DirectReadingSheetState();
}

class _DirectReadingSheetState extends State<DirectReadingSheet> {
  final _title = TextEditingController();
  final _passages = TextEditingController();
  var _saving = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _passages.dispose();
    super.dispose();
  }

  List<String> get _parsedPassages {
    return _passages.text
        .split(RegExp(r'[\n,]'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  Future<void> _send() async {
    final passages = _parsedPassages;
    if (passages.isEmpty) {
      setState(() => _error = 'Escreva ao menos uma passagem, uma por linha.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final title = _title.text.trim();
      await widget.onSubmit(
        title: title.isEmpty ? 'Leitura do grupo' : title,
        passages: passages,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = '$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 34,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.slate500,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 15),
            MiniLabel('${widget.groupName} / Direcionar leitura'),
            const SizedBox(height: 6),
            const Text(
              'Novo desafio de leitura',
              style: TextStyle(
                color: AppColors.slate100,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Defina a sequência que entra no plano ativo do grupo. Uma passagem por linha.',
              style: TextStyle(color: AppColors.slate400, fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _title,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Título do plano'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passages,
              minLines: 4,
              maxLines: 8,
              decoration: const InputDecoration(
                labelText: 'Passagens',
                hintText: 'Salmos 23',
                helperText: 'Uma passagem por linha. Ex.: Salmos 23 e João 14.',
                helperMaxLines: 2,
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(color: Color(0xFFF87171), fontSize: 12),
              ),
            ],
            const SizedBox(height: 12),
            EmberButton(
              label: _saving ? 'Enviando…' : 'Enviar ao grupo',
              expand: true,
              onPressed: _saving ? null : _send,
            ),
          ],
        ),
      ),
    );
  }
}
