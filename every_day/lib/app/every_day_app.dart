import 'package:flutter/material.dart';

import '../core/domain/user_role.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/pages/login_page.dart';
import 'di/app_dependencies.dart';
import 'di/app_scope.dart';
import 'phone_viewport.dart';
import 'shell/app_shell.dart';
import 'shell/pastor_shell.dart';

class EveryDayApp extends StatelessWidget {
  const EveryDayApp({
    super.key,
    required this.dependencies,
    this.skipAuth = false,
  });

  final AppDependencies dependencies;
  final bool skipAuth;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      dependencies: dependencies,
      child: MaterialApp(
        title: 'EveryDay',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        builder: (context, child) =>
            PhoneViewport(child: child ?? const SizedBox.shrink()),
        home: skipAuth
            ? const RoleShell(askFeeling: false)
            : AuthGate(auth: dependencies.auth, home: const RoleShell()),
      ),
    );
  }
}

class RoleShell extends StatefulWidget {
  const RoleShell({super.key, this.askFeeling = true});

  final bool askFeeling;

  @override
  State<RoleShell> createState() => _RoleShellState();
}

class _RoleShellState extends State<RoleShell> {
  UserRole? _role;
  var _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _load();
  }

  Future<void> _load() async {
    try {
      final profile = await AppScope.of(context).getProfile();
      if (!mounted) return;
      setState(() => _role = profile.role);
    } catch (_) {
      if (!mounted) return;
      setState(() => _role = UserRole.member);
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = _role;
    if (role == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (role.isPastor) return const PastorShell();
    return AppShell(askFeeling: widget.askFeeling);
  }
}
