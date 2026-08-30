import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/reading_log.dart';
import '../../domain/usecases/log_reading.dart';

Future<bool> showLogReadingSheet(
  BuildContext context, {
  required LogReading logReading,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: _LogReadingForm(logReading: logReading),
      );
    },
  );
  return result ?? false;
}

class _LogReadingForm extends StatefulWidget {
  const _LogReadingForm({required this.logReading});

  final LogReading logReading;

  @override
  State<_LogReadingForm> createState() => _LogReadingFormState();
}

class _LogReadingFormState extends State<_LogReadingForm> {
  final _passage = TextEditingController(text: 'Salmos 28–30');
  final _note = TextEditingController();
  var _minutes = 15;
  var _saving = false;

  @override
  void dispose() {
    _passage.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Registrar leitura',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _passage,
              decoration: _fieldDecoration('Passagem'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              maxLines: 3,
              decoration: _fieldDecoration('Nota (opcional)'),
            ),
            const SizedBox(height: 16),
            Text(
              'Tempo de leitura: $_minutes min',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Slider(
              value: _minutes.toDouble(),
              min: 5,
              max: 60,
              divisions: 11,
              activeColor: AppColors.orange,
              onChanged: (value) => setState(() => _minutes = value.round()),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  _saving ? 'Salvando...' : 'Registrar',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppColors.cream,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _saving = true);
    await widget.logReading(
      ReadingLog(
        passageLabel: _passage.text.trim(),
        minutes: _minutes,
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }
}
