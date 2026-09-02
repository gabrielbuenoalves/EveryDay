import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'di/app_dependencies.dart';
import 'di/app_scope.dart';
import 'phone_viewport.dart';
import 'shell/app_shell.dart';
import 'state/community_scope.dart';
import 'state/community_state.dart';

class EveryDayApp extends StatefulWidget {
  const EveryDayApp({super.key, required this.dependencies});

  final AppDependencies dependencies;
  @override
  State<EveryDayApp> createState() => _EveryDayAppState();
}

class _EveryDayAppState extends State<EveryDayApp> {
  final CommunityState _state = CommunityState();

  @override
  Widget build(BuildContext context) {
    return AppScope(
      dependencies: widget.dependencies,
      child: CommunityScope(
        state: _state,
        child: MaterialApp(
          title: 'EveryDay',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          builder: (context, child) =>
              PhoneViewport(child: child ?? const SizedBox.shrink()),
          home: const AppShell(),
        ),
      ),
    );
  }
}
