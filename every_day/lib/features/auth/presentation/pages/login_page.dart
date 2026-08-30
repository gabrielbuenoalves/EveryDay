import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/domain/user_role.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../domain/repositories/auth_repository.dart';
import '../widgets/auth_form_style.dart';
import 'church_setup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.auth});

  final AuthRepository auth;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  var _register = false;
  var _busy = false;
  var _role = UserRole.member;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate900,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AppWordmark(),
                    const SizedBox(height: 20),
                    Text(
                      _register
                          ? 'Escolha como você entra na comunidade.'
                          : 'Fé vivida em comunidade. Escolha o seu perfil.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.slate400,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 20),
                    for (final role in UserRole.values) ...[
                      _RoleChoice(
                        role: role,
                        selected: _role == role,
                        onTap: () => setState(() {
                          _role = role;
                          _error = null;
                        }),
                      ),
                      const SizedBox(height: 8),
                    ],
                    const SizedBox(height: 20),
                    if (_register) ...[
                      TextField(
                        controller: _name,
                        textCapitalization: TextCapitalization.words,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.slate100,
                        ),
                        decoration: AuthFormStyle.decoration('Seu nome'),
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.slate100,
                      ),
                      decoration: AuthFormStyle.decoration('E-mail'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _password,
                      obscureText: true,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.slate100,
                      ),
                      decoration: AuthFormStyle.decoration('Senha'),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        _error!,
                        style: const TextStyle(
                          color: AppColors.orange,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _busy ? null : _submit,
                      style: AuthFormStyle.filled(),
                      child: Text(
                        _busy
                            ? 'Aguarde...'
                            : (_register
                                ? 'Criar conta de ${_role.label.toLowerCase()}'
                                : 'Entrar como ${_role.label.toLowerCase()}'),
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () => setState(() {
                              _register = !_register;
                              _error = null;
                            }),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.slate100,
                        minimumSize: const Size(double.infinity, 44),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      child: Text(_register ? 'Já tenho conta' : 'Criar conta'),
                    ),
                    if (widget.auth.youVersionSignInEnabled) ...[
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: _busy ? null : _signInWithYouVersion,
                        style: AuthFormStyle.outlined(),
                        child: const Text('Entrar com YouVersion'),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    widget.auth.intendedRole = _role;
    try {
      if (_register) {
        await widget.auth.signUp(
          email: _email.text,
          password: _password.text,
          displayName: _name.text,
        );
      } else {
        await widget.auth.signIn(email: _email.text, password: _password.text);
      }
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signInWithYouVersion() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    widget.auth.intendedRole = _role;
    try {
      await widget.auth.signInWithYouVersion();
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _RoleChoice extends StatelessWidget {
  const _RoleChoice({
    required this.role,
    required this.selected,
    required this.onTap,
  });

  final UserRole role;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0x26E3703A) : AppColors.slate800,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.ember : AppColors.slate700,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(_icon, color: selected ? AppColors.ember : AppColors.slate400, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      role.label,
                      style: TextStyle(
                        color: selected ? AppColors.slate100 : AppColors.slate300,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      role.loginBlurb,
                      style: const TextStyle(
                        color: AppColors.slate400,
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData get _icon => switch (role) {
    UserRole.member => Icons.menu_book_outlined,
    UserRole.leader => Icons.groups_outlined,
    UserRole.pastor => Icons.account_balance_outlined,
  };
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.auth, required this.home});

  final AuthRepository auth;
  final Widget home;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: auth.authChanges,
      initialData: auth.isSignedIn,
      builder: (context, snapshot) {
        if (snapshot.data != true) {
          return LoginPage(auth: auth);
        }
        return ChurchGate(auth: auth, home: home);
      },
    );
  }
}

class ChurchGate extends StatefulWidget {
  const ChurchGate({super.key, required this.auth, required this.home});

  final AuthRepository auth;
  final Widget home;

  @override
  State<ChurchGate> createState() => _ChurchGateState();
}

class _ChurchGateState extends State<ChurchGate> {
  late Future<bool> _future = widget.auth.hasChurch();

  void _reload() {
    final next = widget.auth.hasChurch();
    setState(() {
      _future = next;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: AppColors.slate900,
            body: Center(child: CircularProgressIndicator(color: AppColors.ember)),
          );
        }
        if (snapshot.data == true) return widget.home;
        return ChurchSetupPage(
          auth: widget.auth,
          onDone: _reload,
          role: widget.auth.intendedRole,
        );
      },
    );
  }
}
