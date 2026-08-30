import 'package:flutter/material.dart';

import '../../../../core/domain/daily_reading.dart';
import '../../../../core/theme/app_colors.dart';

class ReadingPage extends StatelessWidget {
  const ReadingPage({super.key, required this.reading});

  final DailyReading reading;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.charcoal,
      appBar: AppBar(
        backgroundColor: AppColors.charcoal,
        foregroundColor: AppColors.white,
        title: Text(
          reading.passageLabel,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LEITURA DE HOJE',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: const Color(0xFFC8C2B8),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              reading.passageLabel,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Abra este trecho na sua Bíblia, leia com calma e registre quando terminar. A leitura fica no seu feed para a comunidade acompanhar.',
              style: TextStyle(
                fontFamily: 'Georgia',
                color: Color(0xFFD7D0C5),
                fontSize: 18,
                height: 1.5,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).maybePop(),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  'Concluir leitura',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
