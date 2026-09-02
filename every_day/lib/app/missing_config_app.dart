import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/app_logo.dart';
import 'phone_viewport.dart';

class MissingConfigApp extends StatelessWidget {
  const MissingConfigApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      builder: (context, child) =>
          PhoneViewport(child: child ?? const SizedBox.shrink()),
      home: const Scaffold(
        backgroundColor: AppColors.cream,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppWordmark(),
                SizedBox(height: 20),
                Text(
                  'Falta o Supabase',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.slate100,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  '1. Crie um projeto em supabase.com\n'
                  '2. Rode every_day/supabase/schema.sql no SQL Editor\n'
                  '3. Em Authentication → Providers, desative Confirm email para testar\n'
                  '4. Rode o app com a URL e a anon key:\n\n'
                  'flutter run --dart-define=SUPABASE_URL=https://SEU.supabase.co --dart-define=SUPABASE_ANON_KEY=eyJ...',
                  style: TextStyle(height: 1.45, color: AppColors.mutedDark),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
