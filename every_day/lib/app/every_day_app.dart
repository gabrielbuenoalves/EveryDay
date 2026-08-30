import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'di/app_dependencies.dart';
import 'di/app_scope.dart';
import 'phone_viewport.dart';
import 'shell/app_shell.dart';

class EveryDayApp extends StatelessWidget {
  const EveryDayApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      dependencies: dependencies,
      child: MaterialApp(
        title: 'EveryDay',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        builder: (context, child) => PhoneViewport(child: child ?? const SizedBox.shrink()),
        home: const AppShell(),
      ),
    );
  }
}
