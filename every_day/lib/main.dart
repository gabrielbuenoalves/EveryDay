import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/di/app_dependencies.dart';
import 'app/every_day_app.dart';
import 'app/missing_config_app.dart';
import 'core/config/local_env.dart';
import 'core/config/supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final url = kSupabaseUrlFromDefine.isNotEmpty
      ? kSupabaseUrlFromDefine
      : kSupabaseUrlOverride;
  final anonKey = kSupabaseAnonKeyFromDefine.isNotEmpty
      ? kSupabaseAnonKeyFromDefine
      : kSupabaseAnonKeyOverride;
  final config = SupabaseConfig.fromEnvironment(url: url, anonKey: anonKey);

  if (!config.isConfigured) {
    runApp(const MissingConfigApp());
    return;
  }

  await Supabase.initialize(url: config.url, publishableKey: config.anonKey);
  runApp(
    EveryDayApp(
      dependencies: AppDependencies.fromSupabase(Supabase.instance.client),
    ),
  );
}
