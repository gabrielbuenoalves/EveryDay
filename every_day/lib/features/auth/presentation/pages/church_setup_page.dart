import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/domain/user_role.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_logo.dart';
import '../../../../core/widgets/proto.dart';
import '../../domain/repositories/auth_repository.dart';
import '../widgets/auth_form_style.dart';

class ChurchSetupPage extends StatefulWidget {
  const ChurchSetupPage({
    super.key,
    required this.auth,
    required this.onDone,
    this.role = UserRole.member,
  });

  final AuthRepository auth;
  final VoidCallback onDone;
  final UserRole role;

  @override
  State<ChurchSetupPage> createState() => _ChurchSetupPageState();
}

class _ChurchSetupPageState extends State<ChurchSetupPage> {
  final _churchName = TextEditingController();
  final _churchBio = TextEditingController();
  final _churchMembers = TextEditingController();
  final _churchCity = TextEditingController();
  final _code = TextEditingController();
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    _churchName.dispose();
    _churchBio.dispose();
    _churchMembers.dispose();
    _churchCity.dispose();
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const fieldStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: AppColors.slate100,
    );

    return Scaffold(
      backgroundColor: AppColors.slate900,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.slate850,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.slate700),
                      ),
                      child: const AppLogo(size: 44),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      widget.role.setupTitle,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontSize: 28, height: 1.1),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.role.setupCopy,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.slate400,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 28),
                    if (widget.role.isPastor) ...[
                      TextField(
                        controller: _churchName,
                        textCapitalization: TextCapitalization.words,
                        style: fieldStyle,
                        decoration: AuthFormStyle.decoration(
                          'Nome da igreja',
                        ).copyWith(hintText: 'Ex.: Comunidade da Ponte'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _churchBio,
                        maxLines: 4,
                        maxLength: 280,
                        style: fieldStyle,
                        decoration: AuthFormStyle.decoration('Bio da igreja').copyWith(
                          hintText:
                              'Conte brevemente a missão, a visão e como a comunidade acolhe as pessoas.',
                          helperText:
                              'Esta apresentação ficará visível no perfil da igreja · até 280 caracteres.',
                          helperMaxLines: 2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _churchMembers,
                        keyboardType: TextInputType.number,
                        style: fieldStyle,
                        decoration: AuthFormStyle.decoration(
                          'Quantidade de membros',
                        ).copyWith(hintText: 'Ex.: 280'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _churchCity,
                        textCapitalization: TextCapitalization.words,
                        style: fieldStyle,
                        decoration: AuthFormStyle.decoration(
                          'Cidade',
                        ).copyWith(hintText: 'Cidade e estado'),
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: _busy ? null : _createChurch,
                        style: AuthFormStyle.filled(),
                        child: const Text('Criar igreja como pastor'),
                      ),
                    ] else ...[
                      Text(
                        widget.role.isLeader
                            ? 'Código do grupo ou da igreja'
                            : 'Código de convite da igreja',
                        style: const TextStyle(
                          color: AppColors.slate300,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _CodeBoxes(controller: _code, enabled: !_busy),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _busy ? null : _join,
                        style: AuthFormStyle.filled(),
                        child: Text(
                          widget.role.isLeader
                              ? 'Entrar como líder'
                              : 'Entrar como membro',
                        ),
                      ),
                      const OrDivider(),
                      OutlinedButton(
                        onPressed: _busy ? null : _scanQr,
                        style: AuthFormStyle.outlined(),
                        child: const Text('▦  Escanear QR Code do culto'),
                      ),
                    ],
                    if (_error != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.fromLTRB(9, 7, 9, 7),
                        decoration: const BoxDecoration(
                          color: Color(0x4DB8501F),
                          border: Border(
                            left: BorderSide(color: AppColors.ember, width: 3),
                          ),
                        ),
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            color: AppColors.slate100,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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

  Future<void> _createChurch() async {
    if (_churchName.text.trim().isEmpty) {
      setState(() => _error = 'Informe o nome da igreja.');
      return;
    }
    await _run(() => widget.auth.createChurch(_churchName.text));
  }

  Future<void> _join() async {
    final code = _code.text.trim();
    if (code.length != 6) {
      setState(() => _error = 'Preencha os 6 caracteres do convite.');
      return;
    }
    await _run(() async {
      if (widget.role.isLeader) {
        await widget.auth.joinAsLeader(code);
        return;
      }
      try {
        await widget.auth.joinChurch(code);
      } catch (_) {
        await widget.auth.joinGroup(code);
      }
    });
  }

  Future<void> _scanQr() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.slate900,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: AppColors.slate700),
          ),
          title: const Text('Escanear QR Code'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Posicione o código do culto dentro da área.',
                style: TextStyle(color: AppColors.slate400, fontSize: 12),
              ),
              const SizedBox(height: 16),
              Container(
                width: 210,
                height: 210,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.slate950,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.ember, width: 2),
                ),
                child: const Text('▦', style: TextStyle(fontSize: 58)),
              ),
              const SizedBox(height: 12),
              const Text(
                'A câmera entra na versão nativa do aplicativo. Por enquanto, use o código de 6 caracteres.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.slate300, fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
    if (ok == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR Code reconhecido. Entrada concluída!'),
        ),
      );
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
      widget.onDone();
    } catch (e) {
      final message = e.toString();
      if (message.contains('already in a church')) {
        widget.onDone();
        return;
      }
      setState(() => _error = message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _CodeBoxes extends StatefulWidget {
  const _CodeBoxes({required this.controller, required this.enabled});

  final TextEditingController controller;
  final bool enabled;

  @override
  State<_CodeBoxes> createState() => _CodeBoxesState();
}

class _CodeBoxesState extends State<_CodeBoxes> {
  late final List<TextEditingController> _boxes;
  late final List<FocusNode> _nodes;

  @override
  void initState() {
    super.initState();
    _boxes = List.generate(6, (_) => TextEditingController());
    _nodes = List.generate(6, (_) => FocusNode());
    for (var i = 0; i < 6; i++) {
      final index = i;
      _nodes[index].onKeyEvent = (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace &&
            _boxes[index].text.isEmpty &&
            index > 0) {
          _nodes[index - 1].requestFocus();
          _boxes[index - 1].clear();
          _sync();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      };
    }
  }

  @override
  void dispose() {
    for (final box in _boxes) {
      box.dispose();
    }
    for (final node in _nodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _sync() {
    widget.controller.text = _boxes.map((box) => box.text).join();
  }

  void _apply(String raw, int start) {
    final chars = raw.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
    if (chars.length > 1) {
      for (var i = 0; i < 6; i++) {
        _boxes[i].text = i < chars.length ? chars[i] : '';
      }
      _sync();
      _nodes[(chars.length.clamp(1, 6)) - 1].requestFocus();
      return;
    }
    final index = start;
    _boxes[index].text = chars;
    _sync();
    if (chars.isNotEmpty && index < 5) {
      _nodes[index + 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < 6; i++) ...[
          if (i > 0) const SizedBox(width: 7),
          Expanded(
            child: SizedBox(
              height: 56,
              child: TextField(
                controller: _boxes[i],
                focusNode: _nodes[i],
                enabled: widget.enabled,
                maxLength: 1,
                textAlign: TextAlign.center,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                ],
                style: const TextStyle(
                  color: AppColors.slate100,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
                decoration: const InputDecoration(
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (value) => _apply(value, i),
                onTap: () => _boxes[i].selection = TextSelection(
                  baseOffset: 0,
                  extentOffset: _boxes[i].text.length,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
